// src/pages/coach/CoachChatPage.jsx
import React, {
  useEffect,
  useRef,
  useMemo,
  useState,
  useCallback,
} from "react";
import { useSearchParams } from "react-router-dom";
import { Send } from "lucide-react";
import styles from "../../styles/CoachChatPage.module.css";
import conversationsApi from "@/api/conversations";
import { createStompClient } from "@/lib/stompClient";
import { safePublish, waitConnected } from "@/utils/stompHelpers";

const FALLBACK_USER = { id: 9999, name: "Bạn (Coach)" };

const KNOWN_TOKEN_KEYS = [
  "accessToken",
  "access_token",
  "token",
  "jwt",
  "accessTokenLocal",
];

function readAccessTokenFromStorage() {
  for (const k of KNOWN_TOKEN_KEYS) {
    const t = localStorage.getItem(k);
    if (t) return t;
  }
  const alt =
    localStorage.getItem("Authorization") || localStorage.getItem("auth_token");
  if (alt) return alt;
  return null;
}

function safeParseJwt(token) {
  if (!token) return null;
  try {
    const raw =
      token && token.startsWith && token.startsWith("Bearer ")
        ? token.split(" ")[1]
        : token;
    if (!raw) return null;
    const parts = raw.split(".");
    if (parts.length < 2) return null;
    const payload = parts[1];
    const b64 = payload.replace(/-/g, "+").replace(/_/g, "/");
    const jsonStr = decodeURIComponent(
      atob(b64)
        .split("")
        .map((c) => "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2))
        .join("")
    );
    return JSON.parse(jsonStr);
  } catch (e) {
    return null;
  }
}

function getAccountIdFromToken() {
  const token = readAccessTokenFromStorage();
  const parsed = safeParseJwt(token);
  if (!parsed) return null;
  const candid =
    parsed.accountId ??
    parsed.account_id ??
    parsed.accountID ??
    parsed.sub ??
    parsed.userId ??
    parsed.user_id;
  const maybeNum = Number(candid);
  if (!Number.isNaN(maybeNum) && maybeNum > 0) return maybeNum;
  return null;
}

export default function CoachChatPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const currentAccountId = useMemo(
    () => getAccountIdFromToken() || FALLBACK_USER.id,
    []
  );

  // token read on-demand via tokenProvider (stable)
  const token = readAccessTokenFromStorage();

  const [conversations, setConversations] = useState([]);
  const [selectedConvId, setSelectedConvId] = useState(null);
  const [messages, setMessages] = useState({});
  const [input, setInput] = useState("");
  const [status, setStatus] = useState("init"); // init | connecting | connected | nosocket
  const [typingMap, setTypingMap] = useState({});

  const stompRef = useRef(null);
  const convSubRef = useRef(null);
  const userErrSubRef = useRef(null);
  const conversationsSubRef = useRef(null); // Subscribe to all conversations updates
  const listRef = useRef(null);
  const typingTimeoutRef = useRef(null);

  // stable tokenProvider so createStompClient won't re-create client often
  const tokenProvider = useCallback(async () => {
    return readAccessTokenFromStorage();
  }, []);

  function formatShortTime(isoOrTs) {
    if (!isoOrTs) return "";
    try {
      const t = new Date(isoOrTs);
      return t.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
    } catch {
      return "";
    }
  }

  const normalizeServerMessage = (m, curAccountId = currentAccountId) => {
    // ensure id always string (server may send number)
    const rawId = m.id ?? m.messageId ?? `m-${Date.now()}`;
    const id =
      rawId !== undefined && rawId !== null ? String(rawId) : `m-${Date.now()}`;
    const convId = (
      m.conversationId ??
      m.conversation_id ??
      m.convId ??
      ""
    ).toString();
    const content = m.content ?? m.text ?? m.body ?? "";
    const rawSender =
      m.senderId ??
      m.sender_id ??
      m.accountId ??
      m.sender?.id ??
      m.sender?.accountId ??
      null;
    const senderId = rawSender == null ? null : Number(rawSender);
    const sentAt = m.sentAt ?? m.createdAt ?? new Date().toISOString();
    const from = senderId === curAccountId ? "coach" : "member";
    const senderAvatar =
      m.senderAvatar ?? m.avatarUrl ?? m.sender?.avatarUrl ?? null;
    return {
      id,
      conversationId: convId,
      from,
      senderId,
      text: content,
      createdAt: sentAt,
      senderAvatar,
    };
  };

  // Mark conversation as read
  const markConversationAsRead = useCallback(async (convId) => {
    if (!convId) return;
    try {
      await conversationsApi.markConversationRead(convId);
      // Update unreadCount to 0 in conversations list
      setConversations((prev) =>
        prev.map((c) =>
          c.id === convId || c.rawId?.toString() === convId
            ? { ...c, unreadCount: 0 }
            : c
        )
      );
    } catch (e) {
      console.warn("markConversationAsRead failed", e);
    }
  }, []);

  // Load inbox function (reusable)
  const loadInbox = useCallback(
    async (skipAutoSelect = false) => {
      try {
        const data = await conversationsApi.fetchConversations({
          page: 0,
          size: 50,
        });
        const mapped = (data || []).map((it) => {
          const idRaw =
            it.conversationId ??
            it.id ??
            it.conversation_id ??
            it.convId ??
            null;
          let name = it.title ?? null;
          let avatar = null;
          let online = Boolean(it.online ?? it.isOnline ?? false);
          let unreadCount = it.unreadCount ?? it.unread_count ?? 0;

          if (
            !name &&
            Array.isArray(it.participants) &&
            it.participants.length
          ) {
            const other = it.participants.find((p) => {
              const pid = p?.id ?? p?.accountId ?? p?.participantId ?? null;
              const parsed = pid ? Number(pid) : null;
              return parsed !== currentAccountId;
            });
            const choose = other ?? it.participants[0];

            name =
              choose?.fullName ??
              choose?.name ??
              choose?.displayName ??
              `User ${choose?.id ?? ""}`;
            avatar =
              choose?.avatarUrl ??
              choose?.avatar ??
              choose?.profile?.avatarUrl ??
              choose?.picture ??
              null;

            online =
              online || Boolean(choose?.online ?? choose?.isOnline ?? false);
            unreadCount =
              choose?.unreadCount ?? choose?.unread_count ?? unreadCount;
          } else if (it.participants && it.participants.length) {
            const p = it.participants[0];
            avatar =
              p?.avatarUrl ??
              p?.avatar ??
              p?.profile?.avatarUrl ??
              p?.picture ??
              null;
          }

          const lastMsgObj = it.lastMessage ?? it.last_message ?? null;
          const lastMessageContent =
            (lastMsgObj &&
              (typeof lastMsgObj === "string"
                ? lastMsgObj
                : lastMsgObj.content ?? lastMsgObj.text)) ??
            it.lastMessageContent ??
            "";
          const lastMessageTime =
            (lastMsgObj &&
              (lastMsgObj.createdAt ??
                lastMsgObj.sentAt ??
                lastMsgObj.updatedAt)) ??
            it.lastMessageTime ??
            it.lastUpdatedAt ??
            null;

          return {
            id: idRaw?.toString() ?? Math.random().toString(36).slice(2),
            rawId: idRaw,
            name: name ?? `Conversation ${idRaw ?? ""}`,
            avatar,
            lastMessage: lastMessageContent,
            lastMessageTime,
            online,
            unreadCount,
          };
        });

        setConversations(mapped);

        // Only auto-select on initial load, not on refresh
        if (!skipAutoSelect) {
          // Check for conversationId in query params first
          const queryConvId = searchParams.get("conversationId");
          if (queryConvId) {
            const found = mapped.find(
              (c) => c.id === queryConvId || c.rawId?.toString() === queryConvId
            );
            if (found) {
              setSelectedConvId(found.id);
              // loadMessagesForConv will be called in useEffect when selectedConvId changes
              // Clear query param after using it
              setSearchParams({});
              return;
            }
          }

          if (mapped.length > 0 && !selectedConvId) {
            setSelectedConvId(mapped[0].id);
            // loadMessagesForConv will be called in useEffect when selectedConvId changes
          }
        }
      } catch (e) {
        console.warn("loadInbox failed", e);
        setConversations([]);
      }
    },
    [currentAccountId, searchParams, setSearchParams, selectedConvId]
  );

  // Initial load inbox
  useEffect(() => {
    loadInbox(false);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentAccountId]);

  // Auto-refresh conversations every 30 seconds
  useEffect(() => {
    const interval = setInterval(() => {
      // Only refresh if tab is visible
      if (!document.hidden) {
        loadInbox(true); // Skip auto-select on refresh
      }
    }, 3000); // 30 seconds

    return () => clearInterval(interval);
  }, [loadInbox]);

  // Refresh when tab becomes visible (user switches back to tab)
  useEffect(() => {
    const handleVisibilityChange = () => {
      if (!document.hidden) {
        // Tab is now visible, refresh conversations
        loadInbox(true); // Skip auto-select on refresh
      }
    };

    document.addEventListener("visibilitychange", handleVisibilityChange);

    return () => {
      document.removeEventListener("visibilitychange", handleVisibilityChange);
    };
  }, [loadInbox]);

  // STOMP connect
  useEffect(() => {
    let mounted = true;
    let client = null;

    const init = async () => {
      try {
        setStatus("connecting");
        function buildWsUrl(raw) {
          if (!raw) return raw;
          if (raw.startsWith("ws://") || raw.startsWith("wss://")) return raw;
          if (raw.startsWith("http://")) return raw.replace(/^http:/, "ws:");
          if (raw.startsWith("https://")) return raw.replace(/^https:/, "wss:");
          if (raw.startsWith("/")) {
            const proto = location.protocol === "https:" ? "wss" : "ws";
            return `${proto}://${location.host}${raw}`;
          }
          return raw;
        }

        const WS_RAW =
          import.meta.env.VITE_WS_URL ||
          (import.meta.env.VITE_API_BASE
            ? `${import.meta.env.VITE_API_BASE}/ws`
            : "/ws");
        const WS_URL = buildWsUrl(WS_RAW);

        // guard: already have active client — avoid creating duplicate in StrictMode/dev
        if (stompRef.current && stompRef.current.active) {
          client = stompRef.current;
          setStatus("connected");
          return;
        }

        client = await createStompClient({
          wsUrl: WS_URL,
          tokenProvider, // <- pass stable provider (not raw token)
          debug: true,
          onConnect: (frame, cl) => {
            if (!mounted) return;
            setStatus("connected");
            // cleanup previous user error sub
            try {
              if (userErrSubRef.current) {
                userErrSubRef.current.unsubscribe();
                userErrSubRef.current = null;
              }
              userErrSubRef.current = cl.subscribe(
                "/user/queue/errors",
                (m) => {
                  try {
                    const body = m.body ? JSON.parse(m.body) : m;
                    console.warn("WS user error:", body);
                  } catch (e) {
                    console.warn("WS user error (raw):", m.body || m);
                  }
                }
              );

              // Subscribe to conversations updates to receive new conversations
              try {
                if (conversationsSubRef.current) {
                  conversationsSubRef.current.unsubscribe();
                  conversationsSubRef.current = null;
                }
                conversationsSubRef.current = cl.subscribe(
                  "/user/queue/conversations",
                  async (m) => {
                    try {
                      const body = m.body ? JSON.parse(m.body) : m;
                      // Handle new conversation or conversation update
                      if (body.conversationId || body.id) {
                        const convId = (
                          body.conversationId || body.id
                        ).toString();
                        // Check if conversation already exists
                        setConversations((prev) => {
                          const exists = prev.find(
                            (c) =>
                              c.id === convId || c.rawId?.toString() === convId
                          );
                          if (exists) {
                            // Update existing conversation
                            return prev.map((c) =>
                              c.id === convId || c.rawId?.toString() === convId
                                ? {
                                    ...c,
                                    lastMessage:
                                      body.lastMessage ||
                                      body.content ||
                                      c.lastMessage,
                                    lastMessageTime:
                                      body.lastMessageTime ||
                                      body.createdAt ||
                                      c.lastMessageTime,
                                    unreadCount:
                                      body.unreadCount ?? c.unreadCount,
                                  }
                                : c
                            );
                          } else {
                            // New conversation - fetch full details
                            loadConversationDetails(convId);
                            return prev;
                          }
                        });
                      }
                    } catch (e) {
                      console.warn("failed to parse conversation update", e);
                    }
                  }
                );
              } catch (e) {
                console.warn("subscribe conversations updates failed", e);
              }
            } catch (e) {
              console.warn("subscribe user errors failed", e);
            }
          },
          onStompError: (frame) => {
            console.error("STOMP ERR", frame);
            setStatus("nosocket");
          },
        });

        stompRef.current = client;
      } catch (err) {
        console.warn("stomp init failed", err);
        setStatus("nosocket");
        stompRef.current = null;
      }
    };

    init();

    return () => {
      mounted = false;
      try {
        if (convSubRef.current) {
          convSubRef.current.unsubscribe();
          convSubRef.current = null;
        }
      } catch {}
      try {
        if (userErrSubRef.current) {
          userErrSubRef.current.unsubscribe();
          userErrSubRef.current = null;
        }
      } catch {}
      try {
        if (conversationsSubRef.current) {
          conversationsSubRef.current.unsubscribe();
          conversationsSubRef.current = null;
        }
      } catch {}
      try {
        if (stompRef.current) {
          stompRef.current.deactivate && stompRef.current.deactivate();
          stompRef.current = null;
        }
      } catch {}
    };
    // only depend on currentAccountId (tokenProvider is stable)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [currentAccountId]);

  // subscribe to chosen conversation (subscribe only after connected)
  useEffect(() => {
    const client = stompRef.current;
    if (!client || !selectedConvId) return;

    let mounted = true;

    const subscribeConv = async () => {
      try {
        await waitConnected(client, 8000);
      } catch (e) {
        console.warn("subscribe: stomp not connected, abort subscribe", e);
        setStatus("nosocket");
        return;
      }

      try {
        if (convSubRef.current) {
          convSubRef.current.unsubscribe();
          convSubRef.current = null;
        }
      } catch {}

      try {
        convSubRef.current = client.subscribe(
          `/topic/conversations/${selectedConvId}`,
          (m) => {
            try {
              const payload = m.body ? JSON.parse(m.body) : m;
              const normalized = normalizeServerMessage(
                payload,
                currentAccountId
              );

              // Check if this is a message from a conversation not in our list
              const messageConvId = normalized.conversationId?.toString();
              if (messageConvId && messageConvId !== selectedConvId) {
                // Message from different conversation - check if it exists in list
                setConversations((prev) => {
                  const exists = prev.find(
                    (c) =>
                      c.id === messageConvId ||
                      c.rawId?.toString() === messageConvId
                  );
                  if (!exists) {
                    // New conversation - fetch details and add to list
                    loadConversationDetails(messageConvId);
                  } else {
                    // Update existing conversation
                    return prev.map((c) =>
                      c.id === messageConvId ||
                      c.rawId?.toString() === messageConvId
                        ? {
                            ...c,
                            lastMessage: normalized.text || "",
                            lastMessageTime: normalized.createdAt,
                            unreadCount: (c.unreadCount || 0) + 1,
                          }
                        : c
                    );
                  }
                  return prev;
                });
              }

              // Dedupe: if message id already present -> ignore
              setMessages((prev) => {
                const list = prev[messageConvId || selectedConvId] || [];
                // if server sends duplicate id, ignore
                if (list.find((x) => String(x.id) === String(normalized.id))) {
                  return prev;
                }
                // handle tmp-id replacement: if exist tmp message with same clientMessageId text, replace
                const maybeDup = list.find(
                  (x) =>
                    x.id &&
                    String(x.id).startsWith("tmp-") &&
                    x.text === normalized.text
                );
                if (maybeDup) {
                  return {
                    ...prev,
                    [messageConvId || selectedConvId]: list.map((it) =>
                      String(it.id) === String(maybeDup.id)
                        ? { ...normalized }
                        : it
                    ),
                  };
                }
                return {
                  ...prev,
                  [messageConvId || selectedConvId]: [
                    ...(prev[messageConvId || selectedConvId] || []),
                    normalized,
                  ],
                };
              });

              // Update conversation in list if this is the selected one
              if (messageConvId === selectedConvId || !messageConvId) {
                setConversations((prev) =>
                  prev.map((c) =>
                    c.id === selectedConvId
                      ? {
                          ...c,
                          lastMessage: normalized.text || "",
                          lastMessageTime: normalized.createdAt,
                        }
                      : c
                  )
                );
                // Mark as read when receiving message in selected conversation
                if (selectedConvId) {
                  markConversationAsRead(selectedConvId);
                }
              }
            } catch (e) {
              console.warn("failed to parse incoming stomp message", e, m);
            }
          }
        );
      } catch (e) {
        console.warn("subscribe conv failed", e);
      }
    };

    subscribeConv();
    loadMessagesForConv(selectedConvId);

    return () => {
      mounted = false;
      try {
        if (convSubRef.current) {
          convSubRef.current.unsubscribe();
          convSubRef.current = null;
        }
      } catch {}
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedConvId, currentAccountId, markConversationAsRead]);

  useEffect(() => {
    const el = listRef.current;
    if (!el) return;
    setTimeout(() => (el.scrollTop = el.scrollHeight), 60);
  }, [messages, selectedConvId]);

  // Load conversation details and add to list
  const loadConversationDetails = useCallback(
    async (convId) => {
      if (!convId) return;
      try {
        // Fetch conversations list to get the new one
        const data = await conversationsApi.fetchConversations({
          page: 0,
          size: 100,
        });
        const mapped = (data || []).map((it) => {
          const idRaw =
            it.conversationId ??
            it.id ??
            it.conversation_id ??
            it.convId ??
            null;
          let name = it.title ?? null;
          let avatar = null;
          let online = Boolean(it.online ?? it.isOnline ?? false);
          let unreadCount = it.unreadCount ?? it.unread_count ?? 0;

          if (
            !name &&
            Array.isArray(it.participants) &&
            it.participants.length
          ) {
            const other = it.participants.find((p) => {
              const pid = p?.id ?? p?.accountId ?? p?.participantId ?? null;
              const parsed = pid ? Number(pid) : null;
              return parsed !== currentAccountId;
            });
            const choose = other ?? it.participants[0];

            name =
              choose?.fullName ??
              choose?.name ??
              choose?.displayName ??
              `User ${choose?.id ?? ""}`;
            avatar =
              choose?.avatarUrl ??
              choose?.avatar ??
              choose?.profile?.avatarUrl ??
              choose?.picture ??
              null;

            online =
              online || Boolean(choose?.online ?? choose?.isOnline ?? false);
            unreadCount =
              choose?.unreadCount ?? choose?.unread_count ?? unreadCount;
          } else if (it.participants && it.participants.length) {
            const p = it.participants[0];
            avatar =
              p?.avatarUrl ??
              p?.avatar ??
              p?.profile?.avatarUrl ??
              p?.picture ??
              null;
          }

          const lastMsgObj = it.lastMessage ?? it.last_message ?? null;
          const lastMessageContent =
            (lastMsgObj &&
              (typeof lastMsgObj === "string"
                ? lastMsgObj
                : lastMsgObj.content ?? lastMsgObj.text)) ??
            it.lastMessageContent ??
            "";
          const lastMessageTime =
            (lastMsgObj &&
              (lastMsgObj.createdAt ??
                lastMsgObj.sentAt ??
                lastMsgObj.updatedAt)) ??
            it.lastMessageTime ??
            it.lastUpdatedAt ??
            null;

          return {
            id: idRaw?.toString() ?? Math.random().toString(36).slice(2),
            rawId: idRaw,
            name: name ?? `Conversation ${idRaw ?? ""}`,
            avatar,
            lastMessage: lastMessageContent,
            lastMessageTime,
            online,
            unreadCount,
          };
        });

        const targetConv = mapped.find(
          (c) => c.id === convId || c.rawId?.toString() === convId
        );

        if (targetConv) {
          setConversations((prev) => {
            const exists = prev.find(
              (c) => c.id === targetConv.id || c.rawId?.toString() === convId
            );
            if (!exists) {
              // Add new conversation at the top
              return [targetConv, ...prev];
            }
            // Update existing
            return prev.map((c) =>
              c.id === targetConv.id || c.rawId?.toString() === convId
                ? targetConv
                : c
            );
          });
        }
      } catch (e) {
        console.warn("loadConversationDetails failed", e);
      }
    },
    [currentAccountId]
  );

  // load messages (REST)
  const loadMessagesForConv = async (convId) => {
    const key = convId?.toString();
    if (!key) return;
    // Don't skip if messages exist - allow refresh
    try {
      const raw = await conversationsApi.fetchMessages(key, { limit: 200 });
      const mapped = (raw || []).map((m) => {
        const n = normalizeServerMessage(m, currentAccountId);
        return {
          id: n.id,
          from: n.from,
          text: n.text,
          createdAt: n.createdAt,
          senderId: n.senderId,
          senderAvatar: n.senderAvatar,
        };
      });
      // dedupe by id
      const unique = [];
      const seen = new Set();
      for (const it of mapped) {
        if (!seen.has(String(it.id))) {
          seen.add(String(it.id));
          unique.push(it);
        }
      }
      unique.sort(
        (a, b) =>
          new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime()
      );
      setMessages((prev) => ({ ...prev, [key]: unique }));
      // Mark as read when loading messages (opening conversation)
      await markConversationAsRead(key);
    } catch (e) {
      console.warn("loadMessagesForConv failed", e);
      setMessages((prev) => ({ ...prev, [key]: [] }));
    }
  };

  // publish message via STOMP (optimistic UI)
  const handleSend = async () => {
    const text = input.trim();
    if (!text) return;
    const key = selectedConvId?.toString();
    if (!key) return;
    const tempId = `tmp-${Date.now()}`;
    const optimistic = {
      id: tempId,
      conversationId: key,
      from: "coach",
      text,
      createdAt: new Date().toISOString(),
      pending: true,
      senderId: currentAccountId,
    };
    setMessages((p) => ({ ...p, [key]: [...(p[key] || []), optimistic] }));
    setInput("");

    const client = stompRef.current;

    if (client) {
      try {
        await waitConnected(client, 8000);
        const payload = {
          conversationId: key,
          messageType: "TEXT",
          content: text,
          clientMessageId: tempId,
        };
        await safePublish(client, "/app/conversations/messages", payload, {
          "content-type": "application/json",
        });
      } catch (e) {
        console.warn("stomp publish failed / fallback to REST", e);
        setMessages((prev) => ({
          ...prev,
          [key]: (prev[key] || []).map((m) =>
            m.id === tempId ? { ...m, pending: false, failed: true } : m
          ),
        }));
        try {
          const payload = {
            conversationId: key,
            content: text,
            messageType: "TEXT",
            clientMessageId: tempId,
          };
          const sent = await conversationsApi.sendMessage(payload);
          const serverMsg = normalizeServerMessage(sent, currentAccountId);
          const actualConv = serverMsg.conversationId?.toString() ?? key;
          setMessages((prev) => ({
            ...prev,
            [actualConv]: (prev[actualConv] || []).map((m) =>
              m.id === tempId
                ? {
                    id: serverMsg.id,
                    from: "coach",
                    text: serverMsg.text,
                    createdAt: serverMsg.createdAt,
                    senderId: serverMsg.senderId,
                  }
                : m
            ),
          }));
          if (actualConv !== key) {
            setConversations((prev) => [
              {
                id: actualConv,
                name: `Conversation ${actualConv}`,
                lastMessage: text,
              },
              ...prev,
            ]);
            setSelectedConvId(actualConv);
          } else {
            setConversations((prev) =>
              prev.map((c) => (c.id === key ? { ...c, lastMessage: text } : c))
            );
          }
        } catch (e2) {
          console.warn("send via REST failed", e2);
        }
      }
      return;
    }

    // no client -> REST
    try {
      const payload = {
        conversationId: key,
        content: text,
        messageType: "TEXT",
      };
      const sent = await conversationsApi.sendMessage(payload);
      const serverMsg = normalizeServerMessage(sent, currentAccountId);
      const actualConv = serverMsg.conversationId?.toString() ?? key;
      setMessages((prev) => ({
        ...prev,
        [actualConv]: (prev[actualConv] || []).map((m) =>
          m.id === tempId
            ? {
                id: serverMsg.id,
                from: "coach",
                text: serverMsg.text,
                createdAt: serverMsg.createdAt,
                senderId: serverMsg.senderId,
              }
            : m
        ),
      }));
      if (actualConv !== key) {
        setConversations((prev) => [
          {
            id: actualConv,
            name: `Conversation ${actualConv}`,
            lastMessage: text,
          },
          ...prev,
        ]);
        setSelectedConvId(actualConv);
      } else {
        setConversations((prev) =>
          prev.map((c) => (c.id === key ? { ...c, lastMessage: text } : c))
        );
      }
    } catch (e) {
      console.warn("send via REST failed (no client)", e);
      setMessages((prev) => ({
        ...prev,
        [key]: (prev[key] || []).map((m) =>
          m.id === tempId ? { ...m, pending: false, failed: true } : m
        ),
      }));
    }
  };

  // typing publish via STOMP (best-effort)
  const handleInputChange = (v) => {
    setInput(v);
    const client = stompRef.current;
    if (client && client.connected) {
      try {
        client.publish({
          destination: "/app/conversations/typing",
          body: JSON.stringify({
            conversationId: selectedConvId,
            from: currentAccountId,
            isTyping: true,
          }),
          headers: { "content-type": "application/json" },
        });
      } catch (e) {}
      if (typingTimeoutRef.current) clearTimeout(typingTimeoutRef.current);
      typingTimeoutRef.current = setTimeout(() => {
        try {
          client.publish({
            destination: "/app/conversations/typing",
            body: JSON.stringify({
              conversationId: selectedConvId,
              from: currentAccountId,
              isTyping: false,
            }),
            headers: { "content-type": "application/json" },
          });
        } catch (e) {}
      }, 700);
    }
  };

  const convMessages = messages[selectedConvId] || [];
  const typingWho = typingMap[selectedConvId];

  const timeShort = (iso) => {
    try {
      return new Date(iso).toLocaleTimeString();
    } catch {
      return "";
    }
  };

  return (
    <div className={styles.container}>
      <aside className={styles.sidebar}>
        <div className={styles.sidebarHeader}>
          <h3>Conversations</h3>
          <span
            className={`${styles.badge} ${
              status === "connected" ? styles.badgeOnline : styles.badgeOffline
            }`}
          >
            {status === "connected"
              ? "Online"
              : status === "connecting"
              ? "Connecting..."
              : "No Connection"}
          </span>
        </div>

        <ul className={styles.convList}>
          {conversations.map((c) => (
            <li
              key={c.id}
              role="button"
              tabIndex={0}
              onClick={() => setSelectedConvId(c.id)}
              data-online={c.online ? "true" : "false"}
              className={`${styles.convItem} ${
                selectedConvId === c.id ? styles.convItemActive : ""
              }`}
            >
              <div className={styles.convAvatar} aria-hidden>
                {c.avatar ? (
                  <img
                    src={c.avatar}
                    alt={c.name || "avatar"}
                    className={styles.convAvatarImg}
                    onError={(e) => {
                      e.currentTarget.onerror = null;
                      e.currentTarget.style.display = "none";
                    }}
                  />
                ) : (
                  <span className={styles.convInitials}>
                    {(c.name || "?")
                      .split(" ")
                      .map((s) => s[0] || "")
                      .slice(0, 2)
                      .join("")
                      .toUpperCase()}
                  </span>
                )}
              </div>

              <div className={styles.convMetaWrap}>
                <div className={styles.convTitle}>
                  <span
                    style={{
                      overflow: "hidden",
                      textOverflow: "ellipsis",
                      display: "inline-block",
                      maxWidth: "220px",
                    }}
                  >
                    {c.name}
                  </span>
                  <span className={styles.convTime}>
                    {c.lastMessageTime
                      ? formatShortTime(c.lastMessageTime)
                      : ""}
                  </span>
                </div>
                <div className={styles.convMeta}>
                  <span
                    style={{
                      overflow: "hidden",
                      textOverflow: "ellipsis",
                      display: "inline-block",
                      maxWidth: "200px",
                    }}
                  >
                    {c.lastMessage}
                  </span>
                  {c.unreadCount > 0 && (
                    <span className={styles.unreadBadge}>{c.unreadCount}</span>
                  )}
                </div>
              </div>
            </li>
          ))}
        </ul>
      </aside>

      <section className={styles.chatPanel}>
        <header className={styles.chatHeader}>
          <div>
            <div className={styles.chatTitle}>
              {conversations.find((c) => c.id === selectedConvId)?.name ||
                "Chat"}
            </div>
            <div className={styles.chatSub}>
              {conversations.find((c) => c.id === selectedConvId)?.lastMessage}
            </div>
          </div>
          <div className={styles.convId}>ID: {selectedConvId ?? "-"}</div>
        </header>

        <div ref={listRef} className={styles.messageList}>
          {convMessages.map((m) => {
            const mine = m.senderId === currentAccountId || m.from === "coach";
            return (
              <div
                key={m.id}
                className={`${styles.msgRow} ${
                  mine ? styles.msgRowEnd : styles.msgRowStart
                }`}
              >
                <div
                  className={`${styles.msgBubble} ${
                    mine ? styles.msgMine : styles.msgOther
                  }`}
                >
                  <div className={styles.msgText}>{m.text}</div>
                  <div className={styles.msgMeta}>
                    <span className={styles.msgTime}>
                      {timeShort(m.createdAt)}
                    </span>
                    {m.pending && (
                      <span className={styles.msgPending}>Sending…</span>
                    )}
                    {m.failed && (
                      <span className={styles.msgFailed}>Failed</span>
                    )}
                  </div>
                </div>
              </div>
            );
          })}

          {typingWho && (
            <div className={styles.typing}>
              {typingWho === currentAccountId
                ? "Bạn đang gõ..."
                : `${typingWho} đang gõ…`}
            </div>
          )}
        </div>

        <div className={styles.inputBar}>
          <input
            value={input}
            onChange={(e) => handleInputChange(e.target.value)}
            onKeyDown={(e) => {
              if (e.key === "Enter") {
                e.preventDefault();
                handleSend();
              }
            }}
            placeholder="Gõ tin nhắn..."
            className={styles.input}
            aria-label="Message"
          />
          <button
            onClick={handleSend}
            className={styles.sendBtn}
            aria-label="Send"
          >
            <Send className="w-4 h-4" />
            <span className={styles.sendLabel}>Send</span>
          </button>
        </div>
      </section>
    </div>
  );
}
