import { useState, useEffect, useRef } from "react";
import ChatTools from "./ChatTools";
import { MessageBody, MsgMenu, type ChatMessage } from "./ChatMedia";
import { readJson } from "../lib/readJson";

interface ChatRequest {
  id: number;
  user_name: string;
  user_contact: string;
  message?: string;
  status: "pending" | "accepted" | "rejected";
  created_at: string;
}

interface Chat {
  id: number;
  user_name: string;
  user_contact?: string;
  unread: number;
  last_message: string | null;
}

type Message = ChatMessage;

const ADMIN_USER = "kiarash";
const ADMIN_PASS = "CHANGE_ME";

interface AdminChatProps {
  onBack: () => void;
  initialChat?: { id: number; name: string } | null;
}

function initial(name: string) {
  const t = name.trim();
  return t ? t.charAt(0) : "؟";
}

function clock(value: string) {
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return "";
  return d.toLocaleTimeString("fa-IR", { hour: "2-digit", minute: "2-digit" });
}

export default function AdminChat({ onBack, initialChat }: AdminChatProps) {
  const [requests, setRequests] = useState<ChatRequest[]>([]);
  const [chats, setChats] = useState<Chat[]>([]);
  const [activeChat, setActiveChat] = useState<number | null>(initialChat?.id ?? null);
  const [activeChatName, setActiveChatName] = useState(initialChat?.name ?? "");
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [accepting, setAccepting] = useState<number | null>(null);
  const [query, setQuery] = useState("");
  const lastIdRef = useRef(0);
  const sinceRef = useRef(0);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const openedSeed = useRef(false);

  const loadRequests = async () => {
    try {
      const res = await fetch("./api/chat_admin.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: ADMIN_USER, pass: ADMIN_PASS, action: "list" }),
      });
      const data = await readJson(res);
      if (Array.isArray(data)) setRequests(data);
    } catch {}
  };

  const loadChats = async () => {
    try {
      const res = await fetch("./api/chat_list.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: ADMIN_USER, pass: ADMIN_PASS }),
      });
      const data = await readJson(res);
      if (Array.isArray(data)) {
        setChats(data.map((c: Chat) => ({ ...c, id: Number(c.id), unread: Number(c.unread) || 0 })));
      }
    } catch {}
  };

  useEffect(() => {
    loadRequests();
    loadChats();
    const iv = setInterval(() => {
      loadRequests();
      loadChats();
    }, 4000);
    return () => clearInterval(iv);
  }, []);

  useEffect(() => {
    if (!initialChat || openedSeed.current) return;
    openedSeed.current = true;
    setActiveChat(initialChat.id);
    setActiveChatName(initialChat.name);
    setMessages([]);
    lastIdRef.current = 0;
  }, [initialChat]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  useEffect(() => {
    if (!activeChat) return;
    let cancelled = false;

    async function run() {
      try {
        const res = await fetch(`./api/chat_history.php?chat_id=${activeChat}&role=admin`);
        const data = await readJson(res);
        if (!cancelled && Array.isArray(data.messages)) {
          const history = data.messages.map((m: Message) => ({ ...m, id: Number(m.id) }));
          setMessages(history);
          lastIdRef.current = history.length ? history[history.length - 1].id : 0;
        }
      } catch {}

      while (!cancelled) {
        try {
          const res = await fetch(`./api/chat_poll.php?chat_id=${activeChat}&last_id=${lastIdRef.current}&role=admin&since=${sinceRef.current}`);
          const data = await readJson(res);
          if (data.now) sinceRef.current = Number(data.now);
          if (Array.isArray(data.removed) && data.removed.length) {
            const gone = new Set(data.removed.map(Number));
            setMessages((prev) => prev.filter((m) => !gone.has(m.id)));
          }
          if (data.messages?.length) {
            const incoming = data.messages.map((m: Message) => ({ ...m, id: Number(m.id) }));
            setMessages((prev) => {
              const ids = new Set(prev.map((m) => m.id));
              const fresh = incoming.filter((m: Message) => !ids.has(m.id));
              return fresh.length ? [...prev, ...fresh] : prev;
            });
            lastIdRef.current = incoming[incoming.length - 1].id;
          }
        } catch {}
        await new Promise((r) => setTimeout(r, 800));
      }
    }
    run();
    return () => { cancelled = true; };
  }, [activeChat]);

  const openChat = (id: number, name: string) => {
    setActiveChat(Number(id));
    setActiveChatName(name || chats.find((c) => Number(c.id) === Number(id))?.user_name || "");
    setMessages([]);
    lastIdRef.current = 0;
  };

  const acceptRequest = async (request: ChatRequest) => {
    setAccepting(request.id);
    try {
      const res = await fetch("./api/chat_admin.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: ADMIN_USER, pass: ADMIN_PASS, action: "accept", request_id: request.id }),
      });
      const data = await readJson(res);
      if (data.success && data.chat_id) {
        await loadRequests();
        await loadChats();
        openChat(Number(data.chat_id), data.user_name || request.user_name);
      }
    } catch {}
    setAccepting(null);
  };

  const rejectRequest = async (id: number) => {
    try {
      await fetch("./api/chat_admin.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: ADMIN_USER, pass: ADMIN_PASS, action: "reject", request_id: id }),
      });
      await loadRequests();
    } catch {}
  };

  const sendReply = async () => {
    if (!input.trim() || !activeChat) return;
    const content = input.trim();
    setInput("");

    try {
      const res = await fetch("./api/chat_send.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          chat_id: activeChat,
          sender: "admin",
          content,
          user: ADMIN_USER,
          pass: ADMIN_PASS,
        }),
      });
      const data = await readJson(res);
      if (data.message) {
        const saved = { ...data.message, id: Number(data.message.id) };
        setMessages((prev) => (prev.some((m) => m.id === saved.id) ? prev : [...prev, saved]));
        lastIdRef.current = Math.max(lastIdRef.current, saved.id);
      }
    } catch {}
  };

  const eraseMessage = async (id: number, scope: "me" | "all") => {
    if (!activeChat) return;
    try {
      const res = await fetch("./api/chat_delete_msg.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          message_id: id,
          chat_id: activeChat,
          scope,
          role: "admin",
          user: ADMIN_USER,
          pass: ADMIN_PASS,
        }),
      });
      const data = await readJson(res);
      if (data.success) setMessages((prev) => prev.filter((m) => m.id !== id));
    } catch {}
  };

  const deleteChat = async (id: number) => {
    if (!window.confirm("")) return;
    try {
      const res = await fetch("./api/chat_admin.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: ADMIN_USER, pass: ADMIN_PASS, action: "delete", chat_id: id }),
      });
      const data = await readJson(res);
      if (data.success) {
        if (activeChat === id) {
          setActiveChat(null);
          setMessages([]);
        }
        await loadChats();
      }
    } catch {}
  };

  const pending = requests.filter((r) => r.status === "pending");
  const q = query.trim().toLowerCase();
  const filteredChats = q
    ? chats.filter((c) => {
        const hay = `${c.user_name} ${c.user_contact || ""} ${c.last_message || ""}`.toLowerCase();
        return hay.includes(q);
      })
    : chats;
  const filteredPending = q
    ? pending.filter((r) => {
        const hay = `${r.user_name} ${r.user_contact} ${r.message || ""}`.toLowerCase();
        return hay.includes(q);
      })
    : pending;

  return (
    <div className={activeChat ? "tg-app has-chat" : "tg-app"}>
      <aside className="tg-side">
        <div className="tg-side-head">
          <button className="tg-back" onClick={onBack}></button>
          <strong></strong>
          <button type="button" className="tg-x" onClick={onBack} aria-label="">×</button>
        </div>

        <label className="tg-search">
          <span className="sr-only"></span>
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder=""
            autoComplete="off"
          />
        </label>

        <div className="tg-side-scroll">
          {filteredPending.length > 0 && (
            <p className="tg-section">{filteredPending.length}</p>
          )}
          {filteredPending.map((r) => (
            <div key={r.id} className="tg-request">
              <div className="tg-row">
                <span className="tg-avatar">{initial(r.user_name)}</span>
                <div className="tg-row-text">
                  <div className="tg-row-top">
                    <strong>{r.user_name}</strong>
                    <small>{clock(r.created_at)}</small>
                  </div>
                  <p className="tg-contact-line">{r.user_contact}</p>
                  <p className="tg-preview">{r.message || ""}</p>
                </div>
              </div>
              <div className="tg-request-actions">
                <button className="tg-accept" disabled={accepting === r.id} onClick={() => acceptRequest(r)}>
                  {accepting === r.id ? "..." : ""}
                </button>
                <button className="tg-reject" onClick={() => rejectRequest(r.id)}></button>
              </div>
            </div>
          ))}

          <p className="tg-section">{filteredChats.length}</p>
          {chats.length === 0 && <p className="tg-empty"></p>}
          {chats.length > 0 && filteredChats.length === 0 && (
            <p className="tg-empty">{query}</p>
          )}
          {filteredChats.map((c) => (
            <div key={c.id} className={`tg-dialog-row${activeChat === c.id ? " is-active" : ""}`}>
              <button
                type="button"
                className={activeChat === c.id ? "tg-dialog on" : "tg-dialog"}
                onClick={() => openChat(c.id, c.user_name)}
              >
                <span className="tg-avatar">{initial(c.user_name)}</span>
                <span className="tg-row-text">
                  <span className="tg-row-top">
                    <strong>{c.user_name}</strong>
                    {c.unread > 0 && <span className="tg-badge">{c.unread}</span>}
                  </span>
                  <span className="tg-preview">{c.last_message || c.user_contact || ""}</span>
                </span>
              </button>
              <button type="button" className="tg-delete mini" onClick={() => deleteChat(c.id)} aria-label=""></button>
            </div>
          ))}
        </div>
      </aside>

      <section className="tg-main">
        {!activeChat ? (
          <div className="tg-placeholder">
            <div className="tg-placeholder-card">
              <strong></strong>
              <p></p>
            </div>
          </div>
        ) : (
          <>
            <header className="tg-top">
              <div className="tg-peer">
                <span className="tg-avatar">{initial(activeChatName)}</span>
                <span>
                  <strong>{activeChatName || ""}</strong>
                  <small></small>
                </span>
              </div>
              <button type="button" className="tg-back" onClick={() => setActiveChat(null)}></button>
              <button type="button" className="tg-delete" onClick={() => deleteChat(activeChat)}> گفتگو</button>
              <button type="button" className="tg-x" onClick={onBack} aria-label="">×</button>
            </header>

            <div className="tg-thread">
              {messages.length === 0 && <p className="tg-empty"></p>}
              {messages.map((m) => {
                const mine = m.sender === "admin";
                return (
                  <div key={m.id} className={mine ? "tg-line out" : "tg-line in"}>
                    {!mine && <span className="tg-avatar">{initial(activeChatName)}</span>}
                    <div className={mine ? "tg-bubble out" : "tg-bubble in"}>
                      {!mine && <span className="tg-who">{activeChatName || ""}</span>}
                      <MessageBody message={m} />
                      <time>{clock(m.created_at)}</time>
                      <MsgMenu onMe={() => eraseMessage(m.id, "me")} onAll={() => eraseMessage(m.id, "all")} />
                    </div>
                  </div>
                );
              })}
              <div ref={messagesEndRef} />
            </div>

            <form
              className="tg-composer"
              onSubmit={(e) => {
                e.preventDefault();
                sendReply();
              }}
            >
              <ChatTools
                chatId={activeChat}
                sender="admin"
                adminAuth={{ user: ADMIN_USER, pass: ADMIN_PASS }}
                onSent={(saved) => {
                  setMessages((prev) => (prev.some((m) => m.id === saved.id) ? prev : [...prev, saved]));
                  lastIdRef.current = Math.max(lastIdRef.current, saved.id);
                }}
                onError={() => {}}
              />
              <input
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder=""
                dir="auto"
              />
              <button type="submit" aria-label="">
                <svg viewBox="0 0 24 24" width="22" height="22" fill="currentColor">
                  <path d="M2.01 21 23 12 2.01 3 2 10l15 2-15 2z" />
                </svg>
              </button>
            </form>
          </>
        )}
      </section>
    </div>
  );
}
