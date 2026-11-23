import { useState, useEffect, useRef } from "react";
import { useTheme } from "../context/ThemeContext";
import { readJson } from "../lib/readJson";
import AdminAvatar from "./AdminAvatar";
import ChatTools from "./ChatTools";
import { MessageBody, MsgMenu, type ChatMessage } from "./ChatMedia";

type Message = ChatMessage;

interface ChatPanelProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function ChatPanel({ isOpen, onClose }: ChatPanelProps) {
  const { lang } = useTheme();

  const [step, setStep] = useState<"form" | "waiting" | "chat">("form");
  const [name, setName] = useState("");
  const [contact, setContact] = useState("");
  const [draft, setDraft] = useState("");
  const [chatId, setChatId] = useState<number | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [error, setError] = useState("");
  const lastIdRef = useRef(0);
  const sinceRef = useRef(0);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // بازیابی چت از localStorage
  useEffect(() => {
    if (!isOpen) return;

    const savedChatId = localStorage.getItem("paar_chat_id");
    const savedName = localStorage.getItem("paar_chat_name");
    const savedContact = localStorage.getItem("paar_chat_contact");
    const savedRequest = localStorage.getItem("paar_request_id");
    const savedDraft = localStorage.getItem("paar_chat_draft");

    if (savedName) setName(savedName);
    if (savedContact) setContact(savedContact);
    if (savedDraft) setDraft(savedDraft);

    if (savedChatId && savedName) {
      setChatId(parseInt(savedChatId, 10));
      setStep("chat");
    } else if (savedRequest) {
      setStep("waiting");
    }
  }, [isOpen]);

  // اسکرول خودکار
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // تاریخچه از دیتابیس، بعد فقط پیام‌های جدید
  useEffect(() => {
    if (step !== "chat" || !chatId) return;
    let cancelled = false;

    async function run() {
      try {
        const res = await fetch(`./api/chat_history.php?chat_id=${chatId}&role=user`);
        const data = await readJson(res);
        if (!cancelled && Array.isArray(data.messages)) {
          const history = data.messages.map((m: Message) => ({ ...m, id: Number(m.id) }));
          setMessages(history);
          if (history.length) lastIdRef.current = history[history.length - 1].id;
        }
      } catch {}

      while (!cancelled) {
        try {
          const res = await fetch(`./api/chat_poll.php?chat_id=${chatId}&last_id=${lastIdRef.current}&role=user&since=${sinceRef.current}`);
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
  }, [step, chatId]);

  // ارسال درخواست
  const eraseMessage = async (id: number, scope: "me" | "all") => {
    if (!chatId) return;
    try {
      const res = await fetch("./api/chat_delete_msg.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message_id: id, chat_id: chatId, scope, role: "user" }),
      });
      const data = await readJson(res);
      if (data.success) setMessages((prev) => prev.filter((m) => m.id !== id));
    } catch {}
  };

  const sendRequest = async () => {
    if (!name.trim() || !contact.trim() || !draft.trim()) {
      setError("");
      return;
    }

    try {
      const res = await fetch("./api/chat_request.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name: name.trim(), contact: contact.trim(), message: draft.trim() }),
      });
      const data = await readJson(res);

      if (data.success && data.request_id) {
        setError("");
        localStorage.setItem("paar_request_id", String(data.request_id));
        localStorage.setItem("paar_chat_name", name.trim());
        localStorage.setItem("paar_chat_contact", contact.trim());
        localStorage.setItem("paar_chat_draft", draft.trim());
        localStorage.removeItem("paar_chat_id");
        setStep("waiting");
      } else {
        setError(data.error || "");
      }
    } catch {
      setError("");
    }
  };

  // چک وضعیت درخواست (وقتی در حالت waiting)
  useEffect(() => {
    if (step !== "waiting") return;
    const requestId = localStorage.getItem("paar_request_id");
    if (!requestId) return;

    let cancelled = false;
    async function check() {
      while (!cancelled) {
        try {
          const res = await fetch("./api/chat_check.php?request_id=" + requestId);
          const data = await readJson(res);
          if (data.status === "accepted" && data.chat_id) {
            const id = Number(data.chat_id);
            setChatId(id);
            localStorage.setItem("paar_chat_id", String(id));
            localStorage.removeItem("paar_request_id");
            setStep("chat");
            return;
          }
          if (data.status === "rejected") {
            setError("");
            setStep("form");
            localStorage.removeItem("paar_request_id");
            return;
          }
        } catch {}
        await new Promise((r) => setTimeout(r, 2000));
      }
    }
    check();
    return () => { cancelled = true; };
  }, [step, lang]);

  // ارسال پیام
  const sendMessage = async () => {
    if (!input.trim() || !chatId) return;
    const content = input.trim();
    setInput("");

    try {
      const res = await fetch("./api/chat_send.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ chat_id: chatId, sender: "user", content }),
      });
      const data = await readJson(res);
      if (data.message) {
        const saved = { ...data.message, id: Number(data.message.id) };
        setMessages((prev) => (prev.some((m) => m.id === saved.id) ? prev : [...prev, saved]));
        lastIdRef.current = Math.max(lastIdRef.current, saved.id);
      } else {
        setError(data.error || "");
      }
    } catch {
      setError("");
    }
  };

  if (!isOpen) return null;

  const L = {
    fa: {
      title: "",
      formTitle: "",
      formDesc: "",
      name: "",
      contact: "",
      message: "",
      send: "",
      waiting: "",
      waitingDesc: "",
      placeholder: "",
      close: "",
    },
    en: {
      title: "",
      formTitle: "",
      formDesc: "",
      name: "",
      contact: "",
      message: "",
      send: "",
      waiting: "",
      waitingDesc: "",
      placeholder: "",
      close: "",
    },
    ar: {
      title: "",
      formTitle: "",
      formDesc: "",
      name: "",
      contact: "",
      message: "",
      send: "",
      waiting: "",
      waitingDesc: "",
      placeholder: "",
      close: "",
    },
  };
  const T = L[lang] || L.fa;

  return (
    <>
    <button type="button" className="chat-backdrop" onClick={onClose} aria-label={T.close} />
    <div className={step === "chat" ? "chat-panel tg-live" : "chat-panel"}>
      <div className={step === "chat" ? "tg-top" : "chat-panel-header"}>
        {step === "chat" ? (
          <div className="tg-peer">
            <AdminAvatar />
            <span>
              <strong>""</strong>
              <small>""</small>
            </span>
          </div>
        ) : (
          <span>{T.title}</span>
        )}
        <button type="button" className="chat-panel-close" onClick={onClose} aria-label={T.close}>×</button>
      </div>

      {step === "form" && (
        <div className="chat-panel-body">
          <h3 className="chat-form-title">{T.formTitle}</h3>
          <p className="chat-form-desc">{T.formDesc}</p>

          <input
            className="chat-input"
            placeholder={T.name}
            value={name}
            dir="auto"
            onChange={(e) => setName(e.target.value)}
          />
          <input
            className="chat-input"
            placeholder={T.contact}
            value={contact}
            dir="auto"
            onChange={(e) => setContact(e.target.value)}
          />
          <textarea
            className="chat-input"
            placeholder={T.message}
            value={draft}
            rows={4}
            dir="auto"
            onChange={(e) => setDraft(e.target.value)}
          />

          {error && <p className="chat-error">{error}</p>}

          <button className="chat-submit" onClick={sendRequest}>{T.send}</button>
        </div>
      )}

      {step === "waiting" && (
        <div className="chat-panel-body chat-waiting">
          <div className="chat-spinner"></div>
          <h3 className="chat-form-title">{T.waiting}</h3>
          <p className="chat-form-desc">{T.waitingDesc}</p>
          {draft && <div className="tg-wait-msg">{draft}</div>}
        </div>
      )}

      {step === "chat" && (
        <>
          <div className="chat-messages tg-thread">
            {messages.length === 0 && (
              <p className="chat-empty">
                ""
              </p>
            )}
            {messages.map((m) => (
              <div key={m.id} className={`chat-line ${m.sender}`}>
                {m.sender === "admin" && <AdminAvatar />}
                <div className="chat-line-main">
                  {m.sender === "admin" && <span className="chat-who">""</span>}
                  <div className="chat-bubble">
                    <MessageBody message={m} />
                    <time className="chat-time">
                      {new Date(m.created_at).toLocaleTimeString(lang === "fa" ? "fa-IR" : "en-US", {
                        hour: "2-digit",
                        minute: "2-digit",
                      })}
                    </time>
                  </div>
                  <MsgMenu onMe={() => eraseMessage(m.id, "me")} onAll={() => eraseMessage(m.id, "all")} />
                </div>
                {m.sender === "user" && <span className="tg-avatar you">{(name.trim() || "ش").charAt(0)}</span>}
              </div>
            ))}
            <div ref={messagesEndRef} />
          </div>

          {error && <p className="chat-error">{error}</p>}
          <div className="chat-input-row">
            <ChatTools
              chatId={chatId || 0}
              sender="user"
              onSent={(saved) => {
                setMessages((prev) => (prev.some((m) => m.id === saved.id) ? prev : [...prev, saved]));
                lastIdRef.current = Math.max(lastIdRef.current, saved.id);
                setError("");
              }}
              onError={setError}
            />
            <input
              className="chat-input"
              placeholder={T.placeholder}
              value={input}
              dir="auto"
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && sendMessage()}
            />
            <button className="chat-send" onClick={sendMessage} aria-label="Send">
              <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor">
                <path d="M2.01 21 23 12 2.01 3 2 10l15 2-15 2z" />
              </svg>
            </button>
          </div>
        </>
      )}
    </div>
    </>
  );
}
