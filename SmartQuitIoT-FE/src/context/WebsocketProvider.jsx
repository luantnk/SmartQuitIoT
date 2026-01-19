// src/context/WebsocketProvider.jsx
import React, {
  createContext,
  useContext,
  useEffect,
  useRef,
  useState,
} from "react";
import { createStompClient } from "@/lib/stompClient";
import useAuth from "@/hooks/useAuth";

const WebsocketContext = createContext(null);
export function useWebsocket() {
  return useContext(WebsocketContext);
}

export default function WebsocketProvider({
  children,
  wsPath = "/ws",
  autoConnect = true,
}) {
  const clientRef = useRef(null);
  const subscriptionRef = useRef(null);
  const presenceSubscriptionRef = useRef(null);
  const [connected, setConnected] = useState(false);

  // prefer hook if exists
  const auth = useAuth?.() ?? {
    getToken: () => localStorage.getItem("accessToken"),
    getAccountId: () => {
      try {
        const a = localStorage.getItem("account");
        return a ? JSON.parse(a).id : null;
      } catch {
        return null;
      }
    },
  };

  // stable tokenProvider compatible with createStompClient
  const tokenProvider = async () =>
    auth.getToken?.() ?? localStorage.getItem("accessToken");

  // Subscribe to notifications topic
  const subscribeToNotifications = (client) => {
    // Unsubscribe existing subscription if any
    if (subscriptionRef.current) {
      try {
        subscriptionRef.current.unsubscribe();
      } catch (e) {
        console.warn(
          "[WS] error unsubscribing old notification subscription",
          e
        );
      }
      subscriptionRef.current = null;
    }

    const accountId =
      auth.getAccountId?.() ??
      (() => {
        try {
          const a = localStorage.getItem("account");
          return a ? JSON.parse(a).id : null;
        } catch {
          return null;
        }
      })();

    if (!accountId) {
      console.debug(
        "[WS] accountId missing - skipping /topic/notifications subscribe"
      );
      return;
    }

    const topic = `/topic/notifications/${accountId}`;
    try {
      const subscription = client.subscribe(topic, (m) => {
        if (!m || !m.body) {
          console.warn("[WS] received empty notification message");
          return;
        }
        try {
          const payload = JSON.parse(m.body);
          console.debug("[WS] received notification", payload);
          window.dispatchEvent(
            new CustomEvent("ws:notification", { detail: payload })
          );
        } catch (e) {
          console.warn("[WS] invalid notification payload", e, m.body);
        }
      });
      subscriptionRef.current = subscription;
      console.debug("[WS] subscribed to", topic);
    } catch (e) {
      console.error("[WS] subscribe notifications failed", e);
    }
  };

  // Subscribe to presence topic
  const subscribeToPresence = (client) => {
    // Unsubscribe existing subscription if any
    if (presenceSubscriptionRef.current) {
      try {
        presenceSubscriptionRef.current.unsubscribe();
      } catch (e) {
        console.warn("[WS] error unsubscribing old presence subscription", e);
      }
      presenceSubscriptionRef.current = null;
    }

    try {
      const subscription = client.subscribe("/topic/presence/coach", (m) => {
        if (!m || !m.body) return;
        try {
          const p = JSON.parse(m.body);
          window.dispatchEvent(new CustomEvent("ws:presence", { detail: p }));
        } catch (e) {
          console.warn("[WS] invalid presence payload", e);
        }
      });
      presenceSubscriptionRef.current = subscription;
      console.debug("[WS] subscribed to /topic/presence/coach");
    } catch (e) {
      console.warn("[WS] subscribe presence failed", e);
    }
  };

  useEffect(() => {
    if (!autoConnect) return;

    const rawEnv = import.meta.env.VITE_WS_URL;
    const fallback = (() => {
      const proto = window.location.protocol === "https:" ? "wss:" : "ws:";
      return `${proto}//${window.location.host}${wsPath}`;
    })();

    const wsRaw =
      rawEnv ||
      (import.meta.env.VITE_API_BASE
        ? `${import.meta.env.VITE_API_BASE}/ws`
        : fallback);
    console.debug("[WS] provider init. raw env:", rawEnv, " -> wsRaw:", wsRaw);

    let mounted = true;
    (async () => {
      try {
        const client = await createStompClient({
          wsUrl: wsRaw,
          tokenProvider,
          debug: false,
          onConnect: (frame, cl) => {
            if (!mounted) {
              console.debug("[WS] onConnect called but component unmounted");
              return;
            }
            console.debug("[WS] onConnect frame", frame?.headers);
            setConnected(true);

            // Subscribe to notifications and presence
            // This will be called on every reconnect, ensuring subscriptions are always active
            subscribeToNotifications(cl);
            subscribeToPresence(cl);
          },
          onStompError: (frame) => {
            console.error("[WS] broker error", frame);
            setConnected(false);
          },
        });

        // Handle WebSocket close - STOMP client will auto-reconnect
        // Note: STOMP client has built-in reconnect, subscriptions will be recreated in onConnect
        if (client) {
          const originalOnClose = client.onWebSocketClose;
          client.onWebSocketClose = (evt) => {
            console.warn("[WS] WebSocket closed", evt?.code);
            setConnected(false);
            // Clear subscription refs on close (will be recreated on reconnect)
            subscriptionRef.current = null;
            presenceSubscriptionRef.current = null;
            if (originalOnClose && typeof originalOnClose === "function") {
              originalOnClose(evt);
            }
          };
        }

        clientRef.current = client;
      } catch (e) {
        console.error("[WS] init failed", e);
        setConnected(false);
      }
    })();

    return () => {
      mounted = false;
      (async () => {
        try {
          // Unsubscribe before deactivating
          if (subscriptionRef.current) {
            try {
              subscriptionRef.current.unsubscribe();
            } catch {
              // Ignore unsubscribe errors
            }
            subscriptionRef.current = null;
          }
          if (presenceSubscriptionRef.current) {
            try {
              presenceSubscriptionRef.current.unsubscribe();
            } catch {
              // Ignore unsubscribe errors
            }
            presenceSubscriptionRef.current = null;
          }

          if (clientRef.current) {
            await clientRef.current.deactivate?.();
          }
        } catch (e) {
          console.warn("[WS] cleanup error", e);
        }
        clientRef.current = null;
        setConnected(false);
      })();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const value = {
    client: clientRef.current,
    connected,
    subscribe: (dest, cb) => clientRef.current?.subscribe(dest, cb),
    publish: (dest, headers = {}, body = "") => {
      if (!clientRef.current || !clientRef.current.connected) return;
      clientRef.current.publish({ destination: dest, headers, body });
    },
  };

  return (
    <WebsocketContext.Provider value={value}>
      {children}
    </WebsocketContext.Provider>
  );
}
