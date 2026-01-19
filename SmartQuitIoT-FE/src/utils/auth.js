// src/utils/auth.js
export const ACCESS_TOKEN_KEYS = [
  "accessToken",
  "access_token",
  "token",
  "jwt",
];

export function readAccessToken() {
  for (const k of ACCESS_TOKEN_KEYS) {
    const t = localStorage.getItem(k);
    if (t) return t;
  }
  return null;
}

export function parseJwt(token) {
  if (!token) return null;
  try {
    const parts = token.split(".");
    if (parts.length < 2) return null;
    const payload = parts[1];
    // browser atob is fine; in SSR use Buffer
    const json = decodeURIComponent(
      atob(payload)
        .split("")
        .map((c) => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2))
        .join("")
    );
    return JSON.parse(json);
  } catch (e) {
    console.warn("parseJwt failed", e);
    return null;
  }
}

export function getAccountIdFromToken() {
  const token = readAccessToken();
  const p = parseJwt(token);
  if (!p) return null;
  // try common claim names
  return p.accountId ?? p.account_id ?? p.sub ?? p.accountID ?? null;
}

export function getTokenExpiry() {
  const token = readAccessToken();
  const p = parseJwt(token);
  if (!p) return null;
  // exp is usually seconds since epoch
  return p.exp ? Number(p.exp) : null;
}
