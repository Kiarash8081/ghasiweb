$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false

Write-Host "شروع..." -ForegroundColor Cyan

# ============================================
# 1. api.ts - مدیریت API با fallback به localStorage
# ============================================
New-Item -ItemType Directory -Force -Path "src\lib" | Out-Null

$api = @"
// API Helper - با fallback به localStorage
const IS_LOCAL = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";

// ============================================
// Background
// ============================================
export async function getBackground(): Promise<string> {
  if (IS_LOCAL) {
    return localStorage.getItem("bg") || "grid";
  }
  try {
    const res = await fetch("./background.php");
    const data = await res.json();
    return data.background || "grid";
  } catch {
    return localStorage.getItem("bg") || "grid";
  }
}

export async function setBackground(bg: string): Promise<void> {
  localStorage.setItem("bg", bg);
  window.dispatchEvent(new Event("background-updated"));
  
  if (!IS_LOCAL) {
    try {
      await fetch("./background.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: "kiarash", pass: "CHANGE_ME", background: bg }),
      });
    } catch {}
  }
}

// ============================================
// Projects
// ============================================
interface Project { id: string; host: string; url: string; }

export async function getProjects(): Promise<Project[]> {
  if (IS_LOCAL) {
    const data = localStorage.getItem("projects");
    return data ? JSON.parse(data) : [];
  }
  try {
    const res = await fetch("./save.php");
    const data = await res.json();
    return Array.isArray(data) ? data : [];
  } catch {
    const data = localStorage.getItem("projects");
    return data ? JSON.parse(data) : [];
  }
}

export async function saveProjects(projects: Project[]): Promise<void> {
  localStorage.setItem("projects", JSON.stringify(projects));
  window.dispatchEvent(new Event("projects-updated"));
  
  if (!IS_LOCAL) {
    try {
      await fetch("./save.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: "kiarash", pass: "CHANGE_ME", projects }),
      });
    } catch {}
  }
}

// ============================================
// Messages
// ============================================
interface Message { id: string; name: string; email: string; message: string; created_at: string; is_read: number; }

export async function getMessages(): Promise<Message[]> {
  if (IS_LOCAL) {
    const data = localStorage.getItem("messages");
    return data ? JSON.parse(data) : [];
  }
  try {
    const res = await fetch("./messages.php?user=kiarash");
    const data = await res.json();
    return Array.isArray(data) ? data : [];
  } catch {
    const data = localStorage.getItem("messages");
    return data ? JSON.parse(data) : [];
  }
}

export async function saveMessage(msg: { name: string; email: string; message: string }): Promise<void> {
  const newMsg: Message = {
    id: Date.now().toString(),
    name: msg.name,
    email: msg.email,
    message: msg.message,
    created_at: new Date().toISOString(),
    is_read: 0,
  };
  
  const existing = localStorage.getItem("messages");
  const messages = existing ? JSON.parse(existing) : [];
  messages.unshift(newMsg);
  localStorage.setItem("messages", JSON.stringify(messages));
  
  if (!IS_LOCAL) {
    try {
      await fetch("./contact.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(msg),
      });
    } catch {}
  }
}

export async function deleteMessage(id: string): Promise<void> {
  const existing = localStorage.getItem("messages");
  const messages = existing ? JSON.parse(existing) : [];
  const filtered = messages.filter((m: Message) => m.id !== id);
  localStorage.setItem("messages", JSON.stringify(filtered));
  
  if (!IS_LOCAL) {
    try {
      await fetch("./messages.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: "kiarash", action: "delete", id }),
      });
    } catch {}
  }
}
"@
[System.IO.File]::WriteAllText("$PWD\src\lib\api.ts", $api, $utf8)
Write-Host "1. api.ts OK" -ForegroundColor Green

# ============================================
# 2. PerspectiveGrid.tsx - با api
# ============================================
$grid = @"
import { useEffect, useState } from "react";
import { getBackground } from "../lib/api";

type BgType = "grid" | "none" | "dots" | "lines" | "waves" | "circles" | "triangles";

export function PerspectiveGrid() {
  const [bgType, setBgType] = useState<BgType>("grid");

  useEffect(() => {
    function loadBg() {
      getBackground().then(bg => setBgType(bg as BgType));
    }
    loadBg();
    window.addEventListener("background-updated", loadBg);
    return () => window.removeEventListener("background-updated", loadBg);
  }, []);

  if (bgType === "none") return <div className="bg-root bg-none" aria-hidden="true" />;
  if (bgType === "dots") return <div className="bg-root bg-dots" aria-hidden="true" />;
  if (bgType === "lines") return <div className="bg-root bg-lines" aria-hidden="true" />;

  if (bgType === "waves") {
    return (
      <div className="bg-root bg-waves" aria-hidden="true">
        <svg viewBox="0 0 1440 320" preserveAspectRatio="none" className="bg-waves-svg">
          <path fill="rgba(220, 38, 38, 0.15)" d="M0,224L48,213.3C96,203,192,181,288,181.3C384,181,480,203,576,224C672,245,768,267,864,250.7C960,235,1056,181,1152,165.3C1248,149,1344,171,1392,181.3L1440,192L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z" />
          <path fill="rgba(220, 38, 38, 0.1)" d="M0,192L48,197.3C96,203,192,213,288,229.3C384,245,480,267,576,250.7C672,235,768,181,864,181.3C960,181,1056,235,1152,240C1248,245,1344,203,1392,181.3L1440,160L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z" />
        </svg>
      </div>
    );
  }

  if (bgType === "circles") {
    return (
      <div className="bg-root bg-circles" aria-hidden="true">
        <div className="bg-circle c1"></div>
        <div className="bg-circle c2"></div>
        <div className="bg-circle c3"></div>
        <div className="bg-circle c4"></div>
      </div>
    );
  }

  if (bgType === "triangles") {
    return (
      <div className="bg-root bg-triangles" aria-hidden="true">
        <div className="bg-tri t1"></div>
        <div className="bg-tri t2"></div>
        <div className="bg-tri t3"></div>
        <div className="bg-tri t4"></div>
        <div className="bg-tri t5"></div>
      </div>
    );
  }

  const tiles = Array.from({ length: 900 });
  return (
    <div className="bg-root bg-grid-wrap" aria-hidden="true">
      <div className="bg-grid-inner">
        {tiles.map((_, i) => <div key={i} className="bg-grid-tile" />)}
      </div>
      <div className="bg-grid-fade" />
    </div>
  );
}

export default PerspectiveGrid;
"@
[System.IO.File]::WriteAllText("$PWD\src\components\ui\PerspectiveGrid.tsx", $grid, $utf8)
Write-Host "2. PerspectiveGrid.tsx OK" -ForegroundColor Green

# ============================================
# 3. AdminPanel.tsx - با api
# ============================================
$admin = @"
import { useState, useEffect } from "react";
import { getProjects, saveProjects as saveP, getMessages, deleteMessage as delMsg, setBackground, getBackground } from "../lib/api";

interface Project { id: string; host: string; url: string; }
interface Message { id: string; name: string; email: string; message: string; created_at: string; is_read: number; }

interface AdminPanelProps {
  isOpen: boolean;
  onClose: () => void;
  onProjectsChange: () => void;
}

const ADMIN_USER = "kiarash";
const ADMIN_PASS = "CHANGE_ME";

type View = "menu" | "projects" | "messages" | "background";

const BACKGROUNDS = [
  { id: "grid", name: "مربع ها" },
  { id: "none", name: "ساده" },
  { id: "dots", name: "نقطه ها" },
  { id: "lines", name: "خطوط" },
  { id: "waves", name: "موج" },
  { id: "circles", name: "دایره ها" },
  { id: "triangles", name: "مثلث ها" },
];

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
  const [background, setBackgroundState] = useState("grid");

  useEffect(() => {
    if (!isOpen) return;
    setView("menu");
    getProjects().then(setProjects);
    getBackground().then(setBackgroundState);
  }, [isOpen]);

  useEffect(() => {
    if (!loggedIn || view !== "messages") return;
    getMessages().then(setMessages);
  }, [loggedIn, view]);

  const handleSaveProjects = async (newProjects: Project[]) => {
    setLoading(true);
    await saveP(newProjects);
    setProjects(newProjects);
    onProjectsChange();
    setLoading(false);
  };

  const handleSetBackground = async (bg: string) => {
    setBackgroundState(bg);
    await setBackground(bg);
  };

  const handleDeleteMessage = async (id: string) => {
    await delMsg(id);
    setMessages(messages.filter(m => m.id !== id));
  };

  const handleLogin = () => {
    if (username.trim().toLowerCase() === ADMIN_USER && password.trim() === ADMIN_PASS) {
      setLoggedIn(true);
      setError("");
    } else {
      setError("نام کاربری یا رمز عبور اشتباه است");
    }
  };

  const handleAdd = () => {
    if (!host || !url) return;
    let cleanUrl = url.trim();
    if (!cleanUrl.startsWith("http")) cleanUrl = "https://" + cleanUrl;
    handleSaveProjects([...projects, { id: Date.now().toString(), host: host.trim(), url: cleanUrl }]);
    setHost("");
    setUrl("");
  };

  if (!isOpen) return null;

  const unreadCount = messages.filter(m => !m.is_read).length;

  return (
    <div className="admin-overlay" onClick={onClose}>
      <div className="admin-modal" onClick={(e) => e.stopPropagation()}>
        <button className="admin-close" onClick={onClose}></button>

        {!loggedIn ? (
          <div className="admin-login-wrap">
            <h2 className="admin-title">ورود</h2>
            <form onSubmit={(e) => { e.preventDefault(); handleLogin(); }}>
              <input type="text" placeholder="نام کاربری" value={username} onChange={(e) => setUsername(e.target.value)} className="admin-input" />
              <input type="password" placeholder="رمز عبور" value={password} onChange={(e) => setPassword(e.target.value)} className="admin-input" />
              {error && <p className="admin-error">{error}</p>}
              <button type="submit" className="admin-btn">ورود</button>
            </form>
          </div>
        ) : (
          <>
            {view === "menu" && (
              <div>
                <div className="admin-top">
                  <h2 className="admin-title">پنل مدیریت</h2>
                  <button className="admin-logout" onClick={() => { setLoggedIn(false); setUsername(""); setPassword(""); }}>خروج</button>
                </div>
                <div className="admin-menu">
                  <button className="admin-menu-item" onClick={() => setView("projects")}>افزودن سایت به رزومه</button>
                  <button className="admin-menu-item" onClick={() => setView("messages")}>پیام ها {unreadCount > 0 && "(" + unreadCount + ")"}</button>
                  <button className="admin-menu-item" onClick={() => setView("background")}>تغییر پس زمینه</button>
                </div>
              </div>
            )}

            {view === "projects" && (
              <div>
                <div className="admin-top">
                  <button className="admin-back" onClick={() => setView("menu")}>بازگشت</button>
                  <h2 className="admin-title">افزودن سایت</h2>
                  <span></span>
                </div>
                <div className="admin-form">
                  <input type="text" placeholder="نام سایت" value={host} onChange={(e) => setHost(e.target.value)} className="admin-input" />
                  <input type="text" placeholder="لینک سایت" value={url} onChange={(e) => setUrl(e.target.value)} className="admin-input" />
                  <button className="admin-btn" onClick={handleAdd} disabled={loading}>افزودن</button>
                </div>
                <div className="admin-list">
                  {projects.map(p => (
                    <div key={p.id} className="admin-item">
                      <div className="admin-item-info">
                        <div className="admin-item-host">{p.host}</div>
                        <div className="admin-item-url">{p.url}</div>
                      </div>
                      <button className="admin-delete" onClick={() => handleSaveProjects(projects.filter(x => x.id !== p.id))}>حذف</button>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {view === "messages" && (
              <div>
                <div className="admin-top">
                  <button className="admin-back" onClick={() => setView("menu")}>بازگشت</button>
                  <h2 className="admin-title">پیام ها</h2>
                  <span></span>
                </div>
                {messages.length === 0 ? (
                  <p style={{ textAlign: "center", color: "#888", padding: "40px 20px" }}>پیامی وجود ندارد</p>
                ) : (
                  <div className="admin-list">
                    {messages.map(m => (
                      <div key={m.id} className="admin-message">
                        <div className="admin-message-header">
                          <strong>{m.name}</strong>
                          <span>{m.email}</span>
                        </div>
                        <p>{m.message}</p>
                        <div className="admin-message-footer">
                          <small>{new Date(m.created_at).toLocaleString("fa-IR")}</small>
                          <button className="admin-delete" onClick={() => handleDeleteMessage(m.id)}>حذف</button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            )}

            {view === "background" && (
              <div>
                <div className="admin-top">
                  <button className="admin-back" onClick={() => setView("menu")}>بازگشت</button>
                  <h2 className="admin-title">تغییر پس زمینه</h2>
                  <span></span>
                </div>
                <div className="admin-bg-grid">
                  {BACKGROUNDS.map(bg => (
                    <button
                      key={bg.id}
                      className={"admin-bg-option " + (background === bg.id ? "active" : "")}
                      onClick={() => handleSetBackground(bg.id)}
                    >
                      <div className={"bg-preview bg-preview-" + bg.id}></div>
                      <span>{bg.name}</span>
                    </button>
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\AdminPanel.tsx", $admin, $utf8)
Write-Host "3. AdminPanel.tsx OK" -ForegroundColor Green

# ============================================
# 4. ContactForm.tsx - با api
# ============================================
$contactForm = @"
import { useState } from "react";
import { useTheme } from "../context/ThemeContext";
import { saveMessage } from "../lib/api";

export default function ContactForm() {
  const { lang } = useTheme();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [status, setStatus] = useState<"idle" | "sending" | "sent" | "error">("idle");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !email || !message) return;

    setStatus("sending");
    try {
      await saveMessage({ name, email, message });
      setStatus("sent");
      setName("");
      setEmail("");
      setMessage("");
      setTimeout(() => setStatus("idle"), 5000);
    } catch {
      setStatus("error");
    }
  };

  const labels = {
    fa: { name: "نام شما", email: "ایمیل", message: "پیام", send: "ارسال", sending: "...", sent: "پیام ارسال شد! ✅", error: "خطا در ارسال" },
    en: { name: "Your Name", email: "Email", message: "Message", send: "Send", sending: "...", sent: "Sent! ✅", error: "Failed" },
    ar: { name: "اسمك", email: "البرد", message: "الرسالة", send: "إرسال", sending: "...", sent: "تم! ✅", error: "فشل" },
  };
  const L = labels[lang] || labels.fa;

  return (
    <form onSubmit={handleSubmit} className="contact-form">
      <input type="text" placeholder={L.name} value={name} onChange={(e) => setName(e.target.value)} className="admin-input" required />
      <input type="email" placeholder={L.email} value={email} onChange={(e) => setEmail(e.target.value)} className="admin-input" required />
      <textarea placeholder={L.message} value={message} onChange={(e) => setMessage(e.target.value)} className="admin-input" rows={4} required />
      <button type="submit" className="admin-btn" disabled={status === "sending"}>
        {status === "sending" ? L.sending : status === "sent" ? L.sent : L.send}
      </button>
      {status === "error" && <p className="admin-error">{L.error}</p>}
    </form>
  );
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\ContactForm.tsx", $contactForm, $utf8)
Write-Host "4. ContactForm.tsx OK" -ForegroundColor Green

# ============================================
# 5. Panels.tsx - با api
# ============================================
$panels = @"
import { useState, useEffect } from "react";
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";
import ContactForm from "./ContactForm";
import { getProjects } from "../lib/api";

interface Project { id: string; host: string; url: string; }
interface PanelsProps { active: string | null; onOpenViewer: (url: string, host: string) => void; }

export default function Panels({ active, onOpenViewer }: PanelsProps) {
  const { lang } = useTheme();
  const [projects, setProjects] = useState<Project[]>([]);

  useEffect(() => {
    function load() { getProjects().then(setProjects); }
    load();
    window.addEventListener("projects-updated", load);
    return () => window.removeEventListener("projects-updated", load);
  }, [active]);

  const defaultProjects: Project[] = [
    { id: "1", host: "pvice.com", url: "https://kiarash8081.github.io/Pvice/" },
    { id: "2", host: "novacafe.com", url: "https://kiarash8081.github.io/app_cafe/" },
  ];
  const allProjects = projects.length > 0 ? projects : defaultProjects;

  return (
    <>
      {active === "about" && (
        <section className="sheet">
          <div className="sheet-inner">
            <p className="kicker">{t(lang, "about.kicker")}</p>
            <h2>{t(lang, "about.name")}</h2>
            <p className="slogan">{t(lang, "about.slogan")}</p>
            <p>{t(lang, "about.body")}</p>
          </div>
        </section>
      )}

      {active === "work" && (
        <section className="sheet">
          <div className="sheet-inner">
            <p className="kicker">{t(lang, "work.kicker")}</p>
            <h2>{t(lang, "work.title")}</h2>
            <p className="slogan">{t(lang, "work.slogan")}</p>
            <div className="works">
              {allProjects.map(p => (
                <article key={p.id} className="shot" tabIndex={0} role="link" onClick={() => onOpenViewer(p.url, p.host)}>
                  <div className="shot-bar">
                    <span className="shot-dots"><i></i><i></i><i></i></span>
                    <span className="shot-url">{p.host}</span>
                  </div>
                  <div className="shot-view">
                    <iframe src={p.url} className="shot-iframe" title={p.host} loading="lazy" sandbox="allow-scripts allow-same-origin" />
                  </div>
                </article>
              ))}
            </div>
          </div>
        </section>
      )}

      {active === "design" && (
        <section className="sheet">
          <div className="sheet-inner">
            <p className="kicker">{t(lang, "design.kicker")}</p>
            <h2>{t(lang, "design.title")}</h2>
            <p className="slogan">{t(lang, "design.slogan")}</p>
            <p>{t(lang, "design.body")}</p>
            <div className="tiles">
              <article className="tile"><span className="mark"></span><b>{lang === "fa" ? "طراحی با ریکت" : "React"}</b><span>{lang === "fa" ? "خدمات طراحی سایت" : "Website design"}</span></article>
              <article className="tile"><span className="mark"></span><b>{lang === "fa" ? "سئو و لوگو" : "SEO"}</b><span>{lang === "fa" ? "خدمات سئو" : "SEO services"}</span></article>
              <article className="tile"><span className="mark"></span><b>{lang === "fa" ? "داده و اطلاعات" : "Data"}</b><span>{lang === "fa" ? "خدمات داده" : "Data services"}</span></article>
            </div>
          </div>
        </section>
      )}

      {active === "contact" && (
        <section className="sheet">
          <div className="sheet-inner">
            <p className="kicker">{t(lang, "contact.kicker")}</p>
            <h2>{t(lang, "contact.title")}</h2>
            <p className="slogan">{t(lang, "contact.slogan")}</p>
            <a className="phone" href="tel:09107727044">09107727044</a>
            <div style={{ marginTop: "24px" }}>
              <ContactForm />
            </div>
          </div>
        </section>
      )}
    </>
  );
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\Panels.tsx", $panels, $utf8)
Write-Host "5. Panels.tsx OK" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "همه چیز آماده شد!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "حالا npm run dev بزن" -ForegroundColor Yellow
