import { useState, useEffect } from "react";
import { getProjects, saveProjects as saveP, getMessages, deleteMessage as delMsg } from "../lib/api";
import { readJson } from "../lib/readJson";
import AdminChat from "./AdminChat";

import type { Project } from "../data/defaultProjects";

interface Message { id: string; name: string; email: string; message: string; created_at: string; is_read: number; }

interface AdminPanelProps {
  isOpen: boolean;
  onClose: () => void;
  onProjectsChange: () => void;
}

const ADMIN_USER = "kiarash";
const ADMIN_PASS = "CHANGE_ME";

type View = "menu" | "projects" | "messages" | "chat";

export default function AdminPanel({ isOpen, onClose, onProjectsChange }: AdminPanelProps) {
  const [loggedIn, setLoggedIn] = useState(false);
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [view, setView] = useState<View>("menu");
  const [loading, setLoading] = useState(false);
  const [host, setHost] = useState("");
  const [url, setUrl] = useState("");
  const [projects, setProjects] = useState<Project[]>([]);
  const [messages, setMessages] = useState<Message[]>([]);
  const [seedChat, setSeedChat] = useState<{ id: number; name: string } | null>(null);
  const [startingChat, setStartingChat] = useState<string | null>(null);

  useEffect(() => {
    document.documentElement.classList.toggle("admin-code", loggedIn);
    return () => document.documentElement.classList.remove("admin-code");
  }, [loggedIn]);

  useEffect(() => {
    if (!isOpen) return;
    setView("menu");
    getProjects().then(setProjects).catch(() => setError(""));
  }, [isOpen]);

  useEffect(() => {
    if (!loggedIn) return;
    getMessages().then(setMessages);
  }, [loggedIn, view]);

  const handleSaveProjects = async (newProjects: Project[]) => {
    setLoading(true);
    const ok = await saveP(newProjects);
    if (ok) {
      const fresh = await getProjects().catch(() => newProjects);
      setProjects(fresh);
      setError("");
      onProjectsChange();
    } else {
      setError("");
    }
    setLoading(false);
    return ok;
  };

  const handleDeleteMessage = async (id: string) => {
    await delMsg(id);
    setMessages(messages.filter((m) => m.id !== id));
  };

  const startChatFromMessage = async (m: Message) => {
    setStartingChat(m.id);
    try {
      const res = await fetch("./api/chat_admin.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          user: ADMIN_USER,
          pass: ADMIN_PASS,
          action: "from_contact",
          name: m.name,
          contact: m.email,
          message: m.message,
        }),
      });
      const data = await readJson(res);
      if (data.success && data.chat_id) {
        setSeedChat({ id: Number(data.chat_id), name: data.user_name || m.name });
        setView("chat");
      }
    } catch {}
    setStartingChat(null);
  };

  const handleLogin = () => {
    if (username.trim().toLowerCase() === ADMIN_USER && password.trim() === ADMIN_PASS) {
      setLoggedIn(true);
      setError("");
    } else {
      setError("");
    }
  };

  const handleAdd = async () => {
    if (!host.trim() || !url.trim() || loading) return;
    let cleanUrl = url.trim();
    if (!cleanUrl.startsWith("http")) cleanUrl = "https://" + cleanUrl;
    const ok = await handleSaveProjects([...projects, { id: Date.now().toString(), host: host.trim(), url: cleanUrl }]);
    if (ok) {
      setHost("");
      setUrl("");
    }
  };

  const handleDeleteProject = async (project: Project) => {
    if (loading) return;
    if (!window.confirm("")) return;
    await handleSaveProjects(projects.filter((x) => x.id !== project.id));
  };

  if (!isOpen) return null;

  const unreadCount = messages.filter((m) => !m.is_read).length;

  return (
    <div className="admin-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
        <button className="admin-close" onClick={onClose}></button>

        {!loggedIn ? (
          <div className="admin-login-wrap">
            <h2 className="admin-title"></h2>
            <form onSubmit={(e) => { e.preventDefault(); handleLogin(); }}>
              <input type="text" placeholder="" value={username} onChange={(e) => setUsername(e.target.value)} className="admin-input" />
              <input type="password" placeholder="" value={password} onChange={(e) => setPassword(e.target.value)} className="admin-input" />
              {error && <p className="admin-error">{error}</p>}
              <button type="submit" className="admin-btn"></button>
            </form>
          </div>
        ) : (
          <>
            {view === "menu" && (
              <div className="admin-menu-view">
                <div className="admin-header-bar">
                  <h2 className="admin-title" />
                  <button className="admin-logout" onClick={() => { setLoggedIn(false); setUsername(""); setPassword(""); }} />
                </div>
                <div className="admin-menu">
                  <button className="admin-menu-btn" onClick={() => setView("projects")} />
                  <button className="admin-menu-btn" onClick={() => setView("messages")}>
                    {unreadCount > 0 && "(" + unreadCount + ")"}
                  </button>
                  <button className="admin-menu-btn" onClick={() => setView("chat")}>
                    
                  </button>
                </div>
              </div>
            )}

            {view === "projects" && (
              <div className="admin-view">
                <div className="admin-header-bar">
                  <button className="admin-back" onClick={() => setView("menu")}></button>
                  <h2 className="admin-title" />
                  <span></span>
                </div>
                <div className="admin-form">
                  <input type="text" placeholder="" value={host} onChange={(e) => setHost(e.target.value)} className="admin-input" />
                  <input type="text" placeholder="" value={url} onChange={(e) => setUrl(e.target.value)} className="admin-input" />
                  <button className="admin-btn" onClick={handleAdd} disabled={loading}>{loading ? "..." : ""}</button>
                  {error && <p className="admin-error">{error}</p>}
                </div>
                <p className="admin-hint" />
                {projects.length === 0 ? (
                  <p className="admin-empty" />
                ) : (
                <div className="admin-list">
                  {projects.map((p) => (
                    <div key={p.id} className="admin-item">
                      <div className="admin-item-info">
                        <div className="admin-item-host">{p.host}</div>
                        <div className="admin-item-url">{p.url}</div>
                      </div>
                      <button className="admin-delete" disabled={loading} onClick={() => handleDeleteProject(p)}></button>
                    </div>
                  ))}
                </div>
                )}
              </div>
            )}

            {view === "messages" && (
              <div className="admin-view">
                <div className="admin-header-bar">
                  <button className="admin-back" onClick={() => setView("menu")}></button>
                  <h2 className="admin-title" />
                  <span></span>
                </div>
                {messages.length === 0 ? (
                  <p className="admin-empty" />
                ) : (
                  <div className="admin-list">
                    {messages.map((m) => (
                      <div key={m.id} className="admin-message">
                        <div className="admin-message-header">
                          <strong>{m.name}</strong>
                          <span>{m.email}</span>
                        </div>
                        <p>{m.message}</p>
                        <div className="admin-message-footer">
                          <small>{new Date(m.created_at).toLocaleString("fa-IR")}</small>
                          <button className="admin-delete" onClick={() => handleDeleteMessage(m.id)}></button>
                          <button className="tg-accept tg-accept-inline" disabled={startingChat === m.id} onClick={() => startChatFromMessage(m)}>
                            {startingChat === m.id ? "..." : ""}
                          </button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {view === "chat" && (
              <AdminChat onBack={() => setView("menu")} initialChat={seedChat} />
            )}
          </>
        )}
      </div>
    </div>
  );
}
