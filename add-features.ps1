$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false

Write-Host "شروع اضافه کردن 7 قابلیت..." -ForegroundColor Cyan

# ============================================
# 1. ThemeContext.tsx - تم خودکار
# ============================================
$theme = @"
import { createContext, useContext, useEffect, useState, ReactNode } from "react";

type Lang = "fa" | "en" | "ar";
type Theme = "light" | "dark";

interface ThemeContextType {
  lang: Lang;
  theme: Theme;
  setLang: (l: Lang) => void;
  setTheme: (t: Theme) => void;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

function getAutoTheme(): Theme {
  const hour = new Date().getHours();
  return hour >= 18 || hour < 6 ? "dark" : "light";
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>(() => {
    return (localStorage.getItem("lang") as Lang) || "fa";
  });
  const [theme, setThemeState] = useState<Theme>(() => {
    const saved = localStorage.getItem("theme");
    if (saved === "light" || saved === "dark") return saved;
    return getAutoTheme();
  });

  useEffect(() => {
    document.documentElement.lang = lang;
    document.documentElement.dir = lang === "en" ? "ltr" : "rtl";
    localStorage.setItem("lang", lang);
  }, [lang]);

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme);
    if (theme === "dark") document.documentElement.classList.add("dark");
    else document.documentElement.classList.remove("dark");
    localStorage.setItem("theme", theme);
  }, [theme]);

  return (
    <ThemeContext.Provider value={{ lang, theme, setLang: setLangState, setTheme: setThemeState }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error("useTheme must be inside ThemeProvider");
  return ctx;
}
"@
[System.IO.File]::WriteAllText("$PWD\src\context\ThemeContext.tsx", $theme, $utf8)
Write-Host "1. تم خودکار OK" -ForegroundColor Green

# ============================================
# 2. ContactForm.tsx - فرم تماس
# ============================================
$contactForm = @"
import { useState } from "react";
import { useTheme } from "../context/ThemeContext";

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
      const res = await fetch("./contact.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, email, message }),
      });
      if (res.ok) {
        setStatus("sent");
        setName("");
        setEmail("");
        setMessage("");
        setTimeout(() => setStatus("idle"), 5000);
      } else {
        setStatus("error");
      }
    } catch {
      setStatus("error");
    }
  };

  const labels = {
    fa: { name: "نام شما", email: "ایمیل", message: "پیام", send: "ارسال", sending: "...", sent: "پیام ارسال شد! ✅", error: "خطا در ارسال" },
    en: { name: "Your Name", email: "Email", message: "Message", send: "Send", sending: "...", sent: "Message sent! ✅", error: "Send failed" },
    ar: { name: "اسمك", email: "البريد الإلكتروني", message: "الرسالة", send: "إرسال", sending: "...", sent: "تم الإرسال! ✅", error: "فشل الإرسال" },
  };
  const L = labels[lang] || labels.fa;

  return (
    <form onSubmit={handleSubmit} className="contact-form">
      <input
        type="text"
        placeholder={L.name}
        value={name}
        onChange={(e) => setName(e.target.value)}
        className="admin-input"
        required
      />
      <input
        type="email"
        placeholder={L.email}
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        className="admin-input"
        required
      />
      <textarea
        placeholder={L.message}
        value={message}
        onChange={(e) => setMessage(e.target.value)}
        className="admin-input"
        rows={4}
        required
      />
      <button type="submit" className="admin-btn" disabled={status === "sending"}>
        {status === "sending" ? L.sending : status === "sent" ? L.sent : L.send}
      </button>
      {status === "error" && <p className="admin-error">{L.error}</p>}
    </form>
  );
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\ContactForm.tsx", $contactForm, $utf8)
Write-Host "2. فرم تماس OK" -ForegroundColor Green

# ============================================
# 3. Analytics.tsx - Google Analytics
# ============================================
$analytics = @"
import { useEffect } from "react";

export default function Analytics() {
  useEffect(() => {
    // Google Analytics
    const script1 = document.createElement("script");
    script1.async = true;
    script1.src = "https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX";
    document.head.appendChild(script1);

    const script2 = document.createElement("script");
    script2.innerHTML = `
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());
      gtag('config', 'G-XXXXXXXXXX');
    `;
    document.head.appendChild(script2);

    // آمار بازدید محلی
    const visits = parseInt(localStorage.getItem("visits") || "0") + 1;
    localStorage.setItem("visits", visits.toString());
  }, []);

  return null;
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\Analytics.tsx", $analytics, $utf8)
Write-Host "3. Google Analytics OK" -ForegroundColor Green

# ============================================
# 4. ResumeButton.tsx - دانلود PDF
# ============================================
$resumeBtn = @"
import { useTheme } from "../context/ThemeContext";

export default function ResumeButton() {
  const { lang } = useTheme();

  const labels = {
    fa: "دانلود رزومه (PDF)",
    en: "Download Resume (PDF)",
    ar: "تحميل السيرة الذاتية (PDF)",
  };

  return (
    <a
      href="./resume.pdf"
      download="Kiarash-Ghasemian-Resume.pdf"
      className="resume-btn"
      target="_blank"
      rel="noopener noreferrer"
    >
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" width="20" height="20">
        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" />
        <polyline points="7 10 12 15 17 10" />
        <line x1="12" y1="15" x2="12" y2="3" />
      </svg>
      {labels[lang] || labels.fa}
    </a>
  );
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\ResumeButton.tsx", $resumeBtn, $utf8)
Write-Host "4. دانلود رزومه OK" -ForegroundColor Green

# ============================================
# 5. ChatWidget.tsx - چت آنلاین
# ============================================
$chat = @"
import { useEffect } from "react";

export default function ChatWidget() {
  useEffect(() => {
    // Tawk.to Chat
    const s1 = document.createElement("script");
    s1.async = true;
    s1.src = "https://embed.tawk.to/000000000000000000000000/1abcdefgh";
    s1.charset = "UTF-8";
    s1.setAttribute("crossorigin", "*");
    document.body.appendChild(s1);
  }, []);

  return null;
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\ChatWidget.tsx", $chat, $utf8)
Write-Host "5. چت آنلاین OK" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "5 فایل ساخته شد!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
