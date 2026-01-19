// src/hooks/useAuth.js
import { useCallback, useEffect, useState } from "react";
import { readAccessToken, getAccountIdFromToken, parseJwt } from "@/utils/auth";

export default function useAuth() {
  const [token, setTokenState] = useState(() => readAccessToken());
  const [accountId, setAccountId] = useState(() => {
    const t = readAccessToken();
    return t ? getAccountIdFromToken() : null;
  });

  // keep in sync with other tabs
  useEffect(() => {
    const onStorage = (e) => {
      if (!e) return;
      if (["accessToken", "access_token", "token", "jwt"].includes(e.key)) {
        const newToken = readAccessToken();
        setTokenState(newToken);
        setAccountId(getAccountIdFromToken());
      }
    };
    window.addEventListener("storage", onStorage);
    return () => window.removeEventListener("storage", onStorage);
  }, []);

  const getToken = useCallback(() => token, [token]);
  const getAccountId = useCallback(() => {
    // prefer token claim; fallback to stored account object
    const id = getAccountIdFromToken();
    if (id) return id;
    try {
      const a = localStorage.getItem("account");
      return a ? JSON.parse(a).id : null;
    } catch {
      return null;
    }
  }, [token]);

  const setToken = useCallback((newToken) => {
    if (newToken) {
      localStorage.setItem("accessToken", newToken);
      setTokenState(newToken);
      setAccountId(getAccountIdFromToken());
    } else {
      localStorage.removeItem("accessToken");
      setTokenState(null);
      setAccountId(null);
    }
  }, []);

  const logout = useCallback(() => {
    // remove tokens & user info (customize as needed)
    localStorage.removeItem("accessToken");
    localStorage.removeItem("account");
    setTokenState(null);
    setAccountId(null);
  }, []);

  const isAuthenticated = useCallback(() => {
    const t = getToken();
    if (!t) return false;
    const p = parseJwt(t);
    return !!p && (!p.exp || p.exp * 1000 > Date.now());
  }, [token]);

  return {
    getToken,
    getAccountId,
    setToken,
    logout,
    isAuthenticated,
    rawToken: token,
  };
}
