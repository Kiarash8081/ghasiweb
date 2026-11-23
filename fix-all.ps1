$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false

Write-Host "شروع..." -ForegroundColor Cyan

# ============================================
# 1. PerspectiveGrid.tsx - با کدوم پس زمینه ها
# ============================================
$grid = @"
"use client";

import { useEffect, useState } from "react";

export function PerspectiveGrid() {
  const [bgType, setBgType] = useState("grid");

  useEffect(() => {
    function loadBg() {
      fetch("./background.php")
        .then(r => r.json())
        .then(d => { if (d.background) setBgType(d.background); })
        .catch(() => {});
    }
    loadBg();
    window.addEventListener("background-updated", loadBg);
    return () => window.removeEventListener("background-updated", loadBg);
  }, []);

  if (bgType === "none") {
    return <div className="bg-root bg-none" aria-hidden="true" />;
  }

  if (bgType === "dots") {
    return <div className="bg-root bg-dots" aria-hidden="true" />;
  }

  if (bgType === "lines") {
    return <div className="bg-root bg-lines" aria-hidden="true" />;
  }

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

  // grid
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
Write-Host "1. PerspectiveGrid.tsx OK" -ForegroundColor Green

# ============================================
# 2. AdminPanel.tsx - پنل زیبا با 7 پس زمینه
# ============================================
$admin = @"
import { useState, useEffect } from "react";

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
    fetch("./save.php").then(r => r.json()).then(d => { if (Array.isArray(d)) setProjects(d); }).catch(() => {});
    fetch("./background.php").then(r => r.json()).then(d => { if (d.background) setBackgroundState(d.background); }).catch(() => {});
  }, [isOpen]);

  useEffect(() => {
    if (!loggedIn || view !== "messages") return;
    fetch("./messages.php?user=" + ADMIN_USER)
      .then(r => r.json())
      .then(d => { if (Array.isArray(d)) setMessages(d); })
      .catch(() => {});
  }, [loggedIn, view]);

  const saveProjects = async (newProjects: Project[]) => {
    setLoading(true);
    try {
      const res = await fetch("./save.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: ADMIN_USER, pass: ADMIN_PASS, projects: newProjects }),
      });
      if (res.ok) {
        setProjects(newProjects);
        window.dispatchEvent(new Event("projects-updated"));
        onProjectsChange();
      }
    } catch {}
    setLoading(false);
  };

  const saveBackground = async (bg: string) => {
    setBackgroundState(bg);
    try {
      await fetch("./background.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: ADMIN_USER, pass: ADMIN_PASS, background: bg }),
      });
      window.dispatchEvent(new Event("background-updated"));
    } catch {}
  };

  const deleteMessage = async (id: string) => {
    try {
      await fetch("./messages.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: ADMIN_USER, action: "delete", id }),
      });
      setMessages(messages.filter(m => m.id !== id));
    } catch {}
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
    saveProjects([...projects, { id: Date.now().toString(), host: host.trim(), url: cleanUrl }]);
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
                  <button className="admin-menu-item" onClick={() => setView("messages")}>
                    پیام ها {unreadCount > 0 && "(" + unreadCount + ")"}
                  </button>
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
                      <button className="admin-delete" onClick={() => saveProjects(projects.filter(x => x.id !== p.id))}>حذف</button>
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
                          <button className="admin-delete" onClick={() => deleteMessage(m.id)}>حذف</button>
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
                      onClick={() => saveBackground(bg.id)}
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
Write-Host "2. AdminPanel.tsx OK" -ForegroundColor Green

# ============================================
# 3. CSS - همه چیز
# ============================================
$css = @"
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Font */
@font-face {
  font-family: "Vazirmatn";
  font-weight: 400;
  src: url("/fonts/vazirmatn-arabic-400-normal.woff2") format("woff2");
}
@font-face {
  font-family: "Vazirmatn";
  font-weight: 700;
  src: url("/fonts/vazirmatn-arabic-700-normal.woff2") format("woff2");
}
@font-face {
  font-family: "Vazirmatn";
  font-weight: 800;
  src: url("/fonts/vazirmatn-arabic-800-normal.woff2") format("woff2");
}

html, body, button, input, textarea, select, h1, h2, h3, h4, h5, h6, p, span, div, a, li, b, strong {
  font-family: "Vazirmatn", Tahoma, sans-serif !important;
}

*, *::before, *::after { box-sizing: border-box; }

html { background: #ffffff; }
html.dark { background: #000000; }

body {
  margin: 0;
  padding: 0;
  min-height: 100vh;
  background: #ffffff;
  color: #111;
  overflow-x: hidden;
}

html.dark body { background: #000000; color: #fff; }

/* ============================================
   Header
   ============================================ */
.site-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 90;
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 90px;
  padding: 12px 24px;
  background: #ffffff;
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
}

html.dark .site-header {
  background: #000000;
  border-bottom-color: rgba(255, 255, 255, 0.08);
}

body.viewer-open .site-header { min-height: 60px; }
body.viewer-open .brand { display: none; }

.brand {
  display: flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  line-height: 0;
}

.brand img {
  display: block;
  width: auto;
  height: 65px;
}

#stage {
  position: relative;
  z-index: 1;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 28px;
  padding: 140px 16px 60px;
}

/* ============================================
   Menu
   ============================================ */
.menu {
  width: min(560px, 100%);
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 20px;
}

.metal-menu-btn {
  position: relative;
  display: flex;
  border: none;
  background: transparent;
  padding: 0;
  cursor: pointer;
  width: 100%;
  transition: transform 0.15s;
}

.metal-menu-btn:active { transform: scale(0.98); }

.metal-menu-wrap {
  position: relative;
  border-radius: 999px;
  overflow: hidden;
  padding: 4px;
  box-shadow: 0 20px 50px -12px rgba(220, 38, 38, 0.25);
  width: 100%;
}

.metal-menu-wrap::before {
  content: "";
  position: absolute;
  inset: -50%;
  background: conic-gradient(from 0deg, #888888 0%, #ffffff 12%, #aaaaaa 24%, #ffffff 36%, #666666 48%, #ffffff 60%, #999999 72%, #ffffff 84%, #888888 100%);
  animation: metal-spin 4s linear infinite;
  z-index: 0;
}

@keyframes metal-spin { to { transform: rotate(360deg); } }

.metal-menu-body {
  position: relative;
  z-index: 10;
  border-radius: 999px;
  background: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 18px 24px;
  min-height: 64px;
  width: 100%;
}

.metal-menu-btn:hover .metal-menu-body { background: #fafafa; }

.metal-menu-text {
  font-size: 1.05rem;
  font-weight: 700;
  color: #111;
  white-space: nowrap;
}

html.dark .metal-menu-body { background: #111; }
html.dark .metal-menu-btn:hover .metal-menu-body { background: #1a1a1a; }
html.dark .metal-menu-text { color: #fff; }

/* ============================================
   Sheets
   ============================================ */
.sheet { width: min(760px, 100%); }

.sheet-inner {
  padding: 32px;
  border-radius: 24px;
  background: #ffffff;
  border: 1px solid rgba(220, 38, 38, 0.15);
  box-shadow: 0 24px 50px rgba(220, 38, 38, 0.08);
}

html.dark .sheet-inner { background: #111; border-color: rgba(225, 6, 0, 0.2); }

.kicker {
  display: inline-block;
  margin-bottom: 8px;
  color: #dc2626;
  font-size: 0.82rem;
  font-weight: 700;
}

.sheet h2 { margin: 0 0 8px; font-size: 2rem; color: #111; }
html.dark .sheet h2 { color: #fff; }

.sheet .slogan { margin: 0 0 16px; color: #666; font-size: 1rem; line-height: 1.8; }
html.dark .sheet .slogan { color: #bbb; }

.sheet p { margin: 0; color: #666; line-height: 1.9; }
html.dark .sheet p { color: #bbb; }

.phone {
  display: inline-block;
  margin: 12px 0 0;
  direction: ltr;
  color: #111;
  font-size: 1.8rem;
  font-weight: 800;
  text-decoration: none;
  border-bottom: 3px solid #dc2626;
}

html.dark .phone { color: #fff; }

/* Tiles */
.tiles {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 12px;
  margin-top: 18px;
}

.tile {
  display: block;
  padding: 16px 14px;
  border-radius: 16px;
  background: rgba(220, 38, 38, 0.05);
  border: 1px solid rgba(220, 38, 38, 0.15);
  color: inherit;
  text-decoration: none;
}

.tile b { display: block; margin-bottom: 6px; color: #111; font-size: 0.98rem; }
html.dark .tile b { color: #fff; }
.tile span { color: #666; font-size: 0.9rem; }
html.dark .tile span { color: #999; }

.mark {
  display: block;
  width: 36px;
  height: 4px;
  margin-bottom: 12px;
  border-radius: 99px;
  background: linear-gradient(90deg, #dc2626, transparent);
}

/* Works */
.works {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 14px;
  margin-top: 18px;
}

.shot {
  display: flex;
  flex-direction: column;
  overflow: hidden;
  border-radius: 18px;
  border: 1px solid rgba(220, 38, 38, 0.15);
  background: #fff;
  cursor: pointer;
  box-shadow: 0 8px 24px rgba(220, 38, 38, 0.08);
  transition: transform 0.3s;
}

.shot:hover { transform: translateY(-4px); }

.shot-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  direction: ltr;
  padding: 8px 10px;
  background: #f5f5f5;
  border-bottom: 1px solid rgba(0, 0, 0, 0.05);
}

.shot-dots { display: flex; gap: 5px; }

.shot-dots i { width: 8px; height: 8px; border-radius: 50%; background: #d0d0d0; display: block; }
.shot-dots i:first-child { background: #dc2626; }

.shot-url {
  flex: 1;
  padding: 4px 10px;
  border-radius: 999px;
  background: #fff;
  color: #333;
  font-size: 0.78rem;
  text-align: center;
}

.shot-view { height: 300px; overflow-y: auto; background: #fafafa; }
.shot-view img { display: block; width: 100%; height: auto; }
.shot-iframe { width: 100%; height: 100%; border: 0; display: block; }

/* Contact Bar */
.contact-bar { margin-bottom: 24px; display: flex; justify-content: center; }

.contact-tiles {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 14px;
  width: 100%;
  max-width: 680px;
}

.contact-tile {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  padding: 22px 16px;
  border-radius: 20px;
  background: #ffffff;
  border: 1.5px solid rgba(220, 38, 38, 0.15);
  color: inherit;
  text-decoration: none;
  text-align: center;
  transition: all 0.3s;
}

.contact-tile:hover { transform: translateY(-6px); border-color: #dc2626; }

.contact-tile .contact-icon {
  width: 48px;
  height: 48px;
  border-radius: 14px;
  background: rgba(220, 38, 38, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #dc2626;
}

.contact-tile .contact-icon svg { width: 24px; height: 24px; }
.contact-tile b { display: block; color: #111; font-size: 1rem; font-weight: 700; }
.contact-tile .contact-value { color: #888; font-size: 0.85rem; direction: ltr; }

html.dark .contact-tile { background: #111; border-color: rgba(225, 6, 0, 0.2); }
html.dark .contact-tile b { color: #fff; }

/* Footer */
.site-footer {
  position: relative;
  z-index: 1;
  margin-top: 60px;
  padding: 30px 20px 20px;
  background: #ffffff;
  border-top: 1px solid rgba(220, 38, 38, 0.1);
}

html.dark .site-footer { background: #000000; border-top-color: rgba(225, 6, 0, 0.2); }

.footer-inner { max-width: 760px; margin: 0 auto; text-align: center; }
.footer-copy { margin-top: 16px; color: #888; font-size: 0.8rem; }

/* Admak */
.admak-wrap { position: fixed; top: 16px; right: 24px; z-index: 100; }
body.viewer-open .admak-wrap { display: none; }

.admak-btn {
  width: 44px;
  height: 44px;
  padding: 10px;
  border-radius: 50%;
  border: 1px solid rgba(220, 38, 38, 0.2);
  background: #ffffff;
  color: #dc2626;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
}

.admak-btn:hover { background: #dc2626; color: #ffffff; }
.admak-btn svg { width: 22px; height: 22px; }

html.dark .admak-btn { background: #111; border-color: rgba(225, 6, 0, 0.3); color: #ff4040; }

.admak-panel {
  position: absolute;
  top: 56px;
  right: 0;
  width: 200px;
  padding: 12px;
  border-radius: 14px;
  background: #ffffff;
  border: 1px solid rgba(220, 38, 38, 0.2);
  box-shadow: 0 14px 40px rgba(0, 0, 0, 0.15);
}

html.dark .admak-panel { background: #111; border-color: rgba(225, 6, 0, 0.3); color: #fff; }

.admak-label { margin: 0 0 6px; color: #dc2626; font-size: 0.75rem; font-weight: 700; }
.admak-row { display: flex; gap: 5px; margin-bottom: 10px; flex-wrap: wrap; }

.admak-row button {
  border: 1px solid rgba(220, 38, 38, 0.3);
  border-radius: 999px;
  padding: 5px 9px;
  background: transparent;
  color: inherit;
  cursor: pointer;
  font-weight: 700;
  font-size: 0.75rem;
  font-family: inherit;
}

.admak-row button.on { background: #dc2626; color: #fff; }
.admak-divider { height: 1px; background: rgba(220, 38, 38, 0.15); margin: 10px 0; }

.admak-admin {
  width: 100%;
  padding: 9px 12px;
  background: #dc2626;
  color: #fff;
  border: none;
  border-radius: 10px;
  cursor: pointer;
  font-family: inherit;
  font-size: 0.8rem;
  font-weight: 700;
}

/* Viewer */
.viewer { position: fixed; inset: 0; z-index: 60; display: flex; flex-direction: column; background: #fff; }
.viewer-bar { display: flex; align-items: center; gap: 10px; padding: 10px 12px; background: #fff; border-bottom: 1px solid rgba(0, 0, 0, 0.08); }

.viewer-back {
  border: 0;
  border-radius: 999px;
  padding: 10px 20px;
  background: #dc2626;
  color: #fff;
  font-size: 14px;
  font-weight: 700;
  cursor: pointer;
}

.viewer-url {
  flex: 1;
  padding: 8px 14px;
  border-radius: 999px;
  background: #f5f5f5;
  color: #333;
  font-size: 0.92rem;
  text-align: center;
  direction: ltr;
}

.viewer-frame { flex: 1; width: 100%; border: 0; }

/* Loader */
.loader {
  position: fixed;
  inset: 0;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: #fff;
  transition: opacity 0.6s ease, visibility 0.6s ease;
  gap: 24px;
}

html.dark .loader { background: #000; }
.loader.done { opacity: 0; visibility: hidden; }

.loader-logo {
  font-size: 42px;
  font-weight: 800;
  letter-spacing: 6px;
  color: #dc2626;
  text-transform: uppercase;
}

.loader-laptop { width: 200px; }
.loader-lid {
  width: 164px;
  height: 104px;
  margin: 0 auto;
  background: #1c2333;
  border: 6px solid #3a4358;
  border-bottom: none;
  border-radius: 8px 8px 2px 2px;
  box-sizing: border-box;
}

.loader-screen {
  height: 100%;
  background: #0c121b;
  border-radius: 3px 3px 0 0;
  padding: 8px 10px;
  overflow: hidden;
  box-sizing: border-box;
}

.loader-lines i {
  display: block;
  height: 4px;
  margin-bottom: 6px;
  border-radius: 4px;
  background: #e10600;
  animation: loader-code 3s ease-in-out infinite;
}

.loader-lines i:nth-child(1) { width: 46%; }
.loader-lines i:nth-child(2) { width: 78%; background: #ff4b4b; }
.loader-lines i:nth-child(3) { width: 62%; background: #f2c14e; }
.loader-lines i:nth-child(4) { width: 84%; }
.loader-lines i:nth-child(5) { width: 38%; background: #ff8b8b; }
.loader-lines i:nth-child(6) { width: 70%; background: #ff4b4b; }
.loader-lines i:nth-child(7) { width: 54%; background: #f2c14e; }

@keyframes loader-code {
  0%, 100% { transform: translateY(3px); }
  50% { transform: translateY(-5px); }
}

.loader-deck {
  height: 12px;
  background: linear-gradient(#4a556c, #343c4e);
  border-radius: 0 0 6px 6px;
  width: 100%;
}

.loader-track {
  width: min(280px, 80vw);
  height: 6px;
  border-radius: 99px;
  background: rgba(220, 38, 38, 0.15);
  overflow: hidden;
}

.loader-fill {
  height: 100%;
  width: 0;
  background: #dc2626;
  border-radius: inherit;
  animation: fill 2.5s linear forwards;
}

@keyframes fill { to { width: 100%; } }

.loader-text {
  margin: 0;
  color: #dc2626;
  font-size: 13px;
  letter-spacing: 4px;
  text-transform: lowercase;
}

/* ============================================
   Admin Panel (CodePen Style)
   ============================================ */
.admin-overlay {
  position: fixed;
  inset: 0;
  z-index: 9999;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  backdrop-filter: blur(10px);
}

.admin-modal {
  position: relative;
  background: #ecf0f1;
  border-radius: 8px;
  width: 100%;
  max-width: 400px;
  padding: 30px;
  box-shadow: 3px 3px 20px rgba(0, 0, 0, 0.4);
  overflow: hidden;
}

.admin-modal::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 5px;
  background: linear-gradient(to left,
    #27ae60 0%, #27ae60 20%,
    #8e44ad 20%, #8e44ad 40%,
    #3498db 40%, #3498db 60%,
    #e74c3c 60%, #e74c3c 80%,
    #f1c40f 80%, #f1c40f 100%);
}

html.dark .admin-modal {
  background: #1a1a1e;
  color: #fff;
}

.admin-close {
  position: absolute;
  top: 16px;
  right: 16px;
  width: 32px;
  height: 32px;
  border: none;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 50%;
  cursor: pointer;
  font-size: 20px;
  color: #666;
  display: flex;
  align-items: center;
  justify-content: center;
}

html.dark .admin-close { background: rgba(255, 255, 255, 0.1); color: #fff; }

.admin-close:hover { background: #e74c3c; color: #fff; }

.admin-login-wrap { text-align: center; }

.admin-title {
  text-align: center;
  font-weight: 400;
  font-size: 1.8rem;
  margin: 0 0 20px;
  color: #34495e;
}

html.dark .admin-title { color: #fff; }

.admin-login-wrap form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.admin-input {
  width: 100%;
  padding: 12px 14px;
  border: 1px solid #bbb;
  border-radius: 4px;
  font-family: inherit;
  font-size: 14px;
  background: #fff;
  color: #111;
  box-sizing: border-box;
  outline: 0;
}

.admin-input:focus { border-color: #3498db; }

html.dark .admin-input {
  background: #0e0e12;
  color: #fff;
  border-color: #333;
}

.admin-btn {
  padding: 14px;
  background: #e74c3c;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-family: inherit;
  font-size: 16px;
  font-weight: 400;
  cursor: pointer;
  transition: box-shadow 0.4s ease;
}

.admin-btn:hover { box-shadow: 1px 1px 5px #555; }
.admin-btn:active { box-shadow: 1px 1px 7px #222; }
.admin-btn:disabled { opacity: 0.5; cursor: not-allowed; }

.admin-error {
  color: #e74c3c;
  font-size: 0.85rem;
  margin: 0;
  padding: 8px;
  background: rgba(231, 76, 60, 0.1);
  border-radius: 4px;
}

/* Admin Menu */
.admin-top {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  gap: 12px;
}

.admin-top h2 { margin: 0; flex: 1; text-align: center; font-size: 1.5rem; }

.admin-logout {
  padding: 6px 14px;
  background: #e74c3c;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-family: inherit;
  font-size: 0.8rem;
  font-weight: 700;
}

.admin-back {
  padding: 6px 14px;
  background: #3498db;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-family: inherit;
  font-size: 0.8rem;
  font-weight: 700;
}

.admin-menu {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.admin-menu-item {
  padding: 16px 20px;
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  cursor: pointer;
  font-family: inherit;
  font-size: 1rem;
  font-weight: 700;
  color: #34495e;
  text-align: center;
  transition: all 0.2s;
}

html.dark .admin-menu-item { background: #0e0e12; color: #fff; border-color: #333; }

.admin-menu-item:hover {
  background: #e74c3c;
  color: #fff;
  border-color: #e74c3c;
}

/* Admin Form */
.admin-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 20px;
}

.admin-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 300px;
  overflow-y: auto;
}

.admin-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px;
  background: #fff;
  border: 1px solid #ddd;
  border-radius: 4px;
  gap: 10px;
}

html.dark .admin-item { background: #0e0e12; border-color: #333; }

.admin-item-info { flex: 1; min-width: 0; }
.admin-item-host { color: #34495e; font-size: 0.9rem; font-weight: 700; margin-bottom: 2px; }
html.dark .admin-item-host { color: #fff; }

.admin-item-url {
  color: #888;
  font-size: 0.75rem;
  direction: ltr;
  text-align: left;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.admin-delete {
  padding: 6px 12px;
  background: #e74c3c;
  color: #fff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-family: inherit;
  font-size: 0.75rem;
  font-weight: 700;
  flex-shrink: 0;
}

/* Admin Messages */
.admin-message {
  padding: 12px;
  border-radius: 4px;
  background: #fff;
  border: 1px solid #ddd;
  margin-bottom: 8px;
}

html.dark .admin-message { background: #0e0e12; border-color: #333; }

.admin-message-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 6px;
  font-size: 0.85rem;
  gap: 8px;
  flex-wrap: wrap;
}

.admin-message-header strong { color: #e74c3c; }
.admin-message-header span { color: #888; direction: ltr; font-size: 0.75rem; }

.admin-message p { margin: 0 0 8px; color: #333; font-size: 0.85rem; line-height: 1.6; }
html.dark .admin-message p { color: #ccc; }

.admin-message-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.7rem;
  color: #888;
}

/* Admin Background */
.admin-bg-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  max-height: 400px;
  overflow-y: auto;
  padding: 4px;
}

.admin-bg-option {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 8px;
  border-radius: 6px;
  border: 2px solid #ddd;
  background: #fff;
  cursor: pointer;
  font-family: inherit;
  font-size: 0.7rem;
  font-weight: 700;
  color: #34495e;
  transition: all 0.2s;
}

html.dark .admin-bg-option { background: #0e0e12; color: #fff; border-color: #333; }

.admin-bg-option.active {
  border-color: #e74c3c;
  box-shadow: 0 0 0 2px rgba(231, 76, 60, 0.2);
}

.admin-bg-option:hover { border-color: #e74c3c; }

.bg-preview {
  width: 100%;
  height: 40px;
  border-radius: 4px;
  border: 1px solid rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.bg-preview-grid {
  background-color: #fff;
  background-image:
    linear-gradient(rgba(220, 38, 38, 0.3) 1px, transparent 1px),
    linear-gradient(90deg, rgba(220, 38, 38, 0.3) 1px, transparent 1px);
  background-size: 10px 10px;
}

.bg-preview-none { background: #fff; }

.bg-preview-dots {
  background-color: #fff;
  background-image: radial-gradient(circle, rgba(220, 38, 38, 0.5) 1.5px, transparent 1.5px);
  background-size: 10px 10px;
}

.bg-preview-lines {
  background-color: #fff;
  background-image:
    linear-gradient(rgba(220, 38, 38, 0.2) 1px, transparent 1px),
    linear-gradient(90deg, rgba(220, 38, 38, 0.2) 1px, transparent 1px);
  background-size: 16px 16px;
}

.bg-preview-waves {
  background: linear-gradient(180deg, #fff 0%, rgba(220, 38, 38, 0.4) 100%);
}

.bg-preview-circles {
  background: radial-gradient(circle at 30% 50%, rgba(220, 38, 38, 0.4) 20%, transparent 22%),
              radial-gradient(circle at 70% 30%, rgba(220, 38, 38, 0.3) 18%, transparent 20%);
  background-color: #fff;
}

.bg-preview-triangles {
  background: linear-gradient(45deg, transparent 48%, rgba(220, 38, 38, 0.4) 50%, transparent 52%),
              linear-gradient(-45deg, transparent 48%, rgba(220, 38, 38, 0.3) 50%, transparent 52%);
  background-color: #fff;
}

/* ============================================
   Backgrounds (actual)
   ============================================ */
.bg-root {
  position: fixed;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  background: #ffffff;
}

html.dark .bg-root { background: #0a0a0a; }

.bg-none { background: #ffffff; }
html.dark .bg-none { background: #0a0a0a; }

.bg-dots {
  background-color: #ffffff;
  background-image: radial-gradient(circle, rgba(220, 38, 38, 0.25) 1.5px, transparent 1.5px);
  background-size: 24px 24px;
}

html.dark .bg-dots {
  background-color: #0a0a0a;
  background-image: radial-gradient(circle, rgba(225, 6, 0, 0.3) 1.5px, transparent 1.5px);
}

.bg-lines {
  background-color: #ffffff;
  background-image:
    linear-gradient(rgba(220, 38, 38, 0.15) 1px, transparent 1px),
    linear-gradient(90deg, rgba(220, 38, 38, 0.15) 1px, transparent 1px);
  background-size: 40px 40px;
}

html.dark .bg-lines {
  background-color: #0a0a0a;
  background-image:
    linear-gradient(rgba(225, 6, 0, 0.2) 1px, transparent 1px),
    linear-gradient(90deg, rgba(225, 6, 0, 0.2) 1px, transparent 1px);
}

.bg-waves {
  background-color: #ffffff;
  display: flex;
  align-items: flex-end;
}

html.dark .bg-waves { background-color: #0a0a0a; }

.bg-waves-svg { width: 100%; height: 60vh; }

/* Circles */
.bg-circles {
  background-color: #ffffff;
  overflow: hidden;
}

html.dark .bg-circles { background-color: #0a0a0a; }

.bg-circle {
  position: absolute;
  border-radius: 50%;
  border: 2px solid rgba(220, 38, 38, 0.15);
  animation: circle-float 10s ease-in-out infinite;
}

.bg-circle.c1 { width: 300px; height: 300px; top: 10%; left: 5%; animation-delay: 0s; }
.bg-circle.c2 { width: 200px; height: 200px; top: 60%; right: 10%; animation-delay: 2s; }
.bg-circle.c3 { width: 400px; height: 400px; bottom: -100px; left: 30%; animation-delay: 4s; }
.bg-circle.c4 { width: 150px; height: 150px; top: 20%; right: 30%; animation-delay: 6s; }

@keyframes circle-float {
  0%, 100% { transform: translate(0, 0); }
  50% { transform: translate(30px, -30px); }
}

/* Triangles */
.bg-triangles {
  background-color: #ffffff;
  overflow: hidden;
}

html.dark .bg-triangles { background-color: #0a0a0a; }

.bg-tri {
  position: absolute;
  width: 0;
  height: 0;
  border-left: 60px solid transparent;
  border-right: 60px solid transparent;
  border-bottom: 100px solid rgba(220, 38, 38, 0.12);
  animation: tri-float 12s ease-in-out infinite;
}

.bg-tri.t1 { top: 10%; left: 10%; animation-delay: 0s; }
.bg-tri.t2 { top: 40%; right: 15%; animation-delay: 2s; transform: rotate(45deg); }
.bg-tri.t3 { bottom: 15%; left: 25%; animation-delay: 4s; transform: rotate(-30deg); }
.bg-tri.t4 { top: 60%; left: 60%; animation-delay: 6s; transform: rotate(90deg); }
.bg-tri.t5 { bottom: 20%; right: 20%; animation-delay: 8s; transform: rotate(-60deg); }

@keyframes tri-float {
  0%, 100% { transform: translate(0, 0) rotate(0deg); }
  50% { transform: translate(20px, -20px) rotate(15deg); }
}

/* Grid */
.bg-grid-wrap { overflow: hidden; }

.bg-grid-inner {
  position: absolute;
  width: 200vw;
  height: 200vh;
  left: -50vw;
  top: -50vh;
  display: grid;
  grid-template-columns: repeat(30, 1fr);
  grid-template-rows: repeat(30, 1fr);
  transform: perspective(1000px) rotateX(35deg) rotateZ(15deg);
  transform-origin: center center;
  pointer-events: auto;
}

.bg-grid-tile {
  min-height: 1px;
  min-width: 1px;
  border: 1px solid rgba(220, 38, 38, 0.12);
  background: transparent;
  transition: background-color 0.8s ease, box-shadow 0.8s ease;
}

html.dark .bg-grid-tile { border-color: rgba(225, 6, 0, 0.15); }

.bg-grid-fade {
  position: absolute;
  inset: 0;
  z-index: 2;
  pointer-events: none;
  background: radial-gradient(circle at center, transparent 0%, transparent 30%, rgba(255, 255, 255, 0.7) 70%, #ffffff 100%);
}

html.dark .bg-grid-fade {
  background: radial-gradient(circle at center, transparent 0%, transparent 30%, rgba(10, 10, 10, 0.7) 70%, #0a0a0a 100%);
}

/* ============================================
   App Content
   ============================================ */
.app-content {
  position: relative;
  z-index: 1;
  transition: opacity 0.6s ease;
}

/* ============================================
   Mobile
   ============================================ */
@media (max-width: 700px) {
  .site-header { min-height: 70px; padding: 8px 12px; }
  .brand img { height: 50px; }
  .menu { grid-template-columns: 1fr; }
  .contact-tiles { grid-template-columns: 1fr; }
  .works { grid-template-columns: 1fr; }
  .tiles { grid-template-columns: 1fr; }
  .admak-wrap { right: 12px; top: 12px; }
  #stage { padding: 100px 16px 60px; }
  .loader-logo { font-size: 32px; }
}
"@

[System.IO.File]::WriteAllText("$PWD\src\index.css", $css, $utf8)
Write-Host "3. index.css OK" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "همه چیز آماده شد!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "npm run dev" -ForegroundColor Yellow
