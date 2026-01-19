// src/lib/stompClient.js

let _singleton = null; // holds { client, wsUrl, tokenProvider, debug, tokenMonitor, _lastToken, onConnect, onStompError }

function parseJwtPayload(token) {
  if (!token) return null;
  try {
    const parts = token.split(".");
    if (parts.length < 2) return null;
    const payload = JSON.parse(
      atob(parts[1].replace(/-/g, "+").replace(/_/g, "/"))
    );
    return payload;
  } catch (e) {
    return null;
  }
}

function isTokenExpired(token) {
  const payload = parseJwtPayload(token);
  if (!payload) return true;
  if (!payload.exp) return true;
  const nowSeconds = Math.floor(Date.now() / 1000);
  const bufferSeconds = 30;
  return payload.exp <= nowSeconds + bufferSeconds;
}

function normalizeToWsUrl(raw) {
  if (!raw) return raw;
  // already ws/wss
  if (/^wss?:\/\//i.test(raw)) return raw;
  // http(s) -> ws(s)
  if (/^https?:\/\//i.test(raw)) {
    return raw.replace(/^https:/i, "wss:").replace(/^http:/i, "ws:");
  }
  // relative path like "/ws" -> use current origin
  if (raw.startsWith("/")) {
    const proto = window.location.protocol === "https:" ? "wss" : "ws";
    return `${proto}://${window.location.host}${raw}`;
  }
  // fallback: treat as ws
  return raw;
}

async function importStomp() {
  const { Client } = await import("@stomp/stompjs");
  return { Client };
}

async function _createClientInstance({
  wsUrl,
  token,
  onConnect,
  onStompError,
  debug,
}) {
  const { Client } = await importStomp();

  const brokerURL = normalizeToWsUrl(wsUrl || "/ws");

  const connectHeaders = token ? { Authorization: `Bearer ${token}` } : {};

  // Create STOMP client (brokerURL uses native WebSocket under the hood)
  const client = new Client({
    brokerURL,
    connectHeaders,
    reconnectDelay: 5000,
    heartbeatIncoming: 4000,
    heartbeatOutgoing: 4000,
    debug: debug ? (msg) => console.debug("[STOMP]", msg) : () => {},
  });

  client._meta = {
    connectHeaders,
    activeByWrapper: false,
    lastConnectedAt: null,
  };

  client.onConnect = (frame) => {
    client._meta.lastConnectedAt = Date.now();
    client._meta.activeByWrapper = true;
    console.info(
      "[STOMP] connected (server STOMP frame)",
      frame ? frame.headers?.server : undefined
    );
    if (onConnect) {
      try {
        onConnect(frame, client);
      } catch (e) {
        console.error("[STOMP] onConnect handler error", e);
      }
    }
  };

  client.onStompError = (frame) => {
    console.warn("[STOMP] broker reported error", frame);
    if (onStompError) onStompError(frame);
  };

  client.onWebSocketClose = (evt) => {
    console.warn(
      "[STOMP] WebSocket closed",
      evt && evt.code ? `${evt.code}` : evt
    );
  };

  return client;
}

/**
 * createOrReconnect
 */
export async function createOrReconnect({
  wsUrl = "/ws",
  tokenProvider = null,
  onConnect = null,
  onStompError = null,
  debug = false,
  token = null, // backwards-compatible: allow passing token directly
} = {}) {
  // reuse existing singleton if same wsUrl + tokenProvider reference and client active
  if (
    _singleton &&
    _singleton.wsUrl === wsUrl &&
    _singleton.tokenProvider === tokenProvider
  ) {
    const { client } = _singleton;
    if (client && client.active) {
      try {
        const maybeToken = tokenProvider ? await tokenProvider() : token;
        if (maybeToken) updateStompToken(maybeToken);
      } catch (e) {}
      return client;
    }
    try {
      await disconnectStompClient();
    } catch (e) {}
  } else {
    if (_singleton && _singleton.client) {
      try {
        await disconnectStompClient();
      } catch (e) {}
    }
  }

  // get token (sync or async)
  let tok = token || null;
  try {
    if (!tok && tokenProvider) tok = await tokenProvider();
  } catch (e) {
    console.warn("[STOMP] tokenProvider threw", e);
    tok = tok || null;
  }

  if (!_singleton) _singleton = {};
  _singleton._lastToken = tok || null;

  const client = await _createClientInstance({
    wsUrl,
    token: tok,
    onConnect,
    onStompError,
    debug,
  });

  _singleton = {
    client,
    wsUrl,
    tokenProvider,
    debug,
    _lastToken: _singleton._lastToken,
    tokenMonitor: _singleton.tokenMonitor || null,
    onConnect,
    onStompError,
  };

  // helper to update connect headers (used before next connect)
  client.updateConnectHeaders = (newToken) => {
    try {
      if (!client._meta || !client._meta.connectHeaders)
        client._meta.connectHeaders = {};
      const ch = client._meta.connectHeaders;
      if (newToken) ch.Authorization = `Bearer ${newToken}`;
      else delete ch.Authorization;
      client.connectHeaders = ch;
      if (debug)
        console.debug(
          "[STOMP] connectHeaders updated (len=%d) tokenPresent=%s",
          (newToken || "").length,
          !!newToken
        );
    } catch (e) {
      console.warn("[STOMP] failed to update connect headers", e);
    }
  };

  if (tok) client.updateConnectHeaders(tok);

  if (debug) {
    try {
      console.debug(
        "[STOMP] activating client wsUrl=%s connectHeaders=%o",
        normalizeToWsUrl(wsUrl),
        client._meta?.connectHeaders
      );
    } catch (e) {}
  }

  client.activate();

  // token monitor (optional)
  if (tokenProvider) {
    if (_singleton.tokenMonitor) {
      clearInterval(_singleton.tokenMonitor);
      _singleton.tokenMonitor = null;
    }
    _singleton.tokenMonitor = setInterval(async () => {
      try {
        const t = await tokenProvider();
        if (!t) return;
        const changed = _singleton._lastToken !== t;
        const soonExpired = isTokenExpired(t);
        if (changed) {
          client.updateConnectHeaders(t);
          if (debug)
            console.debug("[STOMP] token changed -> updated connect headers");
        } else if (soonExpired) {
          const maybeFresh = await tokenProvider();
          if (maybeFresh && maybeFresh !== _singleton._lastToken) {
            client.updateConnectHeaders(maybeFresh);
            _singleton._lastToken = maybeFresh;
            if (debug)
              console.debug(
                "[STOMP] token refreshed by provider and updated headers"
              );
          }
        }
        _singleton._lastToken = t;
      } catch (e) {
        if (debug) console.debug("[STOMP] token monitor error", e);
      }
    }, 10000);
  }

  return client;
}

export function updateStompToken(newToken) {
  if (!_singleton || !_singleton.client) return;
  try {
    _singleton.client.updateConnectHeaders(newToken);
    _singleton._lastToken = newToken || null;
  } catch (e) {
    console.warn("[STOMP] updateStompToken failed", e);
  }
}

export async function forceReconnect() {
  if (!_singleton) return null;
  const { wsUrl, tokenProvider, onConnect, onStompError, debug } = _singleton;
  try {
    await disconnectStompClient();
  } catch (e) {}
  return createOrReconnect({
    wsUrl,
    tokenProvider,
    onConnect,
    onStompError,
    debug,
  });
}

export async function disconnectStompClient() {
  if (!_singleton && !_singleton?.client) return;
  try {
    const { client } = _singleton;
    if (client && client.active) {
      await new Promise((resolve) => {
        try {
          client.deactivate();
          setTimeout(resolve, 200);
        } catch (e) {
          resolve();
        }
      });
    }
  } catch (e) {
    console.warn("[STOMP] disconnect error", e);
  } finally {
    try {
      if (_singleton?.tokenMonitor) {
        clearInterval(_singleton.tokenMonitor);
        _singleton.tokenMonitor = null;
      }
    } catch (ee) {}
    _singleton = null;
  }
}

export function getClient() {
  return _singleton ? _singleton.client : null;
}

export { createOrReconnect as createStompClient };
