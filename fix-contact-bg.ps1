$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false

Write-Host "شروع..." -ForegroundColor Cyan

# ============================================
# 1. ContactBar.tsx - دکمه های VengeanceUI
# ============================================
$contactBar = @"
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";

export default function ContactBar() {
  const { lang } = useTheme();

  return (
    <div className="contact-bar">
      <div className="contact-tiles">
        <a
          className="contact-tile"
          href="https://t.me/ghasik12"
          target="_blank"
          rel="noopener noreferrer"
        >
          <div className="contact-icon">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <path d="M9.78 18.65l.28-4.23 7.68-6.92c.34-.31-.07-.46-.52-.19L7.74 13.3 3.64 12c-.88-.25-.89-.86.2-1.3l15.97-6.16c.73-.33 1.43.18 1.15 1.3l-2.72 12.81c-.19.91-.74 1.13-1.5.71L12.6 16.3l-1.99 1.93c-.23.23-.42.42-.83.42z" />
            </svg>
          </div>
          <b>{t(lang, "contact.tg")}</b>
          <span className="contact-value">@ghasik12</span>
        </a>

        <a className="contact-tile" href="tel:09107727044">
          <div className="contact-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
            </svg>
          </div>
          <b>{t(lang, "contact.call")}</b>
          <span className="contact-value">09107727044</span>
        </a>

        <a className="contact-tile" href="sms:09107727044">
          <div className="contact-icon">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
            </svg>
          </div>
          <b>{t(lang, "contact.sms")}</b>
          <span className="contact-value">09107727044</span>
        </a>
      </div>
    </div>
  );
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\ContactBar.tsx", $contactBar, $utf8)
Write-Host "1. ContactBar.tsx OK" -ForegroundColor Green

# ============================================
# 2. Footer.tsx - با ContactBar + SocialFlip
# ============================================
$footer = @"
import { useTheme } from "../context/ThemeContext";
import ContactBar from "./ContactBar";
import SocialFlip from "./SocialFlip";

export default function Footer() {
  const { lang } = useTheme();

  return (
    <footer className="site-footer">
      <div className="footer-inner">
        <ContactBar />
        <SocialFlip />
        <p className="footer-copy">
          © {new Date().getFullYear()} —{" "}
          {lang === "fa" ? "کیارش قاسمیان" : lang === "ar" ? "كارش قاسمان" : "Kiarash Ghasemian"}
        </p>
      </div>
    </footer>
  );
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\Footer.tsx", $footer, $utf8)
Write-Host "2. Footer.tsx OK" -ForegroundColor Green

# ============================================
# 3. SocialFlip.tsx - چک کن هست
# ============================================
if (-not (Test-Path "src\components\SocialFlip.tsx")) {
    $social = @"
export default function SocialFlip() {
  return (
    <div className="social-flip">
      <div className="social-flip-group">
        <a className="social-item" href="https://github.com/Kiarash8081" target="_blank" rel="noopener noreferrer" aria-label="GitHub">
          <span className="social-tip">GitHub</span>
          <div className="social-item-inner">
            <div className="social-front">G</div>
            <div className="social-back">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M12 0C5.37 0 0 5.37 0 12c0 5.31 3.435 9.795 8.205 11.385.6.105.825-.255.825-.57 0-.285-.015-1.23-.015-2.235-3.015.555-3.795-.735-4.035-1.41-.135-.345-.72-1.41-1.23-1.695-.42-.225-1.02-.78-.015-.795.945-.015 1.62.87 1.845 1.23 1.08 1.815 2.805 1.305 3.495.99.105-.78.42-1.305.765-1.605-2.67-.3-5.46-1.335-5.46-5.925 0-1.305.465-2.385 1.23-3.225-.12-.3-.54-1.53.12-3.18 0 0 1.005-.315 3.3 1.23.96-.27 1.98-.405 3-.405s2.04.135 3 .405c2.295-1.56 3.3-1.23 3.3-1.23.66 1.65.24 2.88.12 3.18.765.84 1.23 1.905 1.23 3.225 0 4.605-2.805 5.625-5.475 5.925.435.375.81 1.095.81 2.22 0 1.605-.015 2.895-.015 3.3 0 .315.225.69.825.57A12.02 12.02 0 0024 12c0-6.63-5.37-12-12-12z" />
              </svg>
            </div>
          </div>
        </a>
        <a className="social-item" href="https://t.me/ghasik12" target="_blank" rel="noopener noreferrer" aria-label="Telegram">
          <span className="social-tip">Telegram</span>
          <div className="social-item-inner">
            <div className="social-front">T</div>
            <div className="social-back">
              <svg viewBox="0 0 24 24" fill="currentColor">
                <path d="M9.78 18.65l.28-4.23 7.68-6.92c.34-.31-.07-.46-.52-.19L7.74 13.3 3.64 12c-.88-.25-.89-.86.2-1.3l15.97-6.16c.73-.33 1.43.18 1.15 1.3l-2.72 12.81c-.19.91-.74 1.13-1.5.71L12.6 16.3l-1.99 1.93c-.23.23-.42.42-.83.42z" />
              </svg>
            </div>
          </div>
        </a>
        <a className="social-item" href="https://ble.ir/ghasik" target="_blank" rel="noopener noreferrer" aria-label="Bale">
          <span className="social-tip">Bale</span>
          <div className="social-item-inner">
            <div className="social-front">B</div>
            <div className="social-back">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z" />
              </svg>
            </div>
          </div>
        </a>
      </div>
    </div>
  );
}
"@
    [System.IO.File]::WriteAllText("$PWD\src\components\SocialFlip.tsx", $social, $utf8)
    Write-Host "3. SocialFlip.tsx OK (ساخته شد)" -ForegroundColor Green
} else {
    Write-Host "3. SocialFlip.tsx موجود است" -ForegroundColor Yellow
}

# ============================================
# 4. background.php - کاربردی تر
# ============================================
$bgPhp = @"
<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if (`$_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit(0);

`$host = 'localhost';
`$dbname = 'mojdew_mojdew_mojde';
`$user = 'mojdew_kiarash';
`$pass = 'CHANGE_ME';

try {
    `$pdo = new PDO("mysql:host=`$host;dbname=`$dbname;charset=utf8mb4", `$user, `$pass);
    `$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException `$e) {
    http_response_code(500);
    echo json_encode(['error' => 'DB failed', 'msg' => `$e->getMessage()]);
    exit;
}

if (`$_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        `$stmt = `$pdo->query("SELECT value FROM settings WHERE ` + "`key`" + ` = 'background'");
        `$row = `$stmt->fetch(PDO::FETCH_ASSOC);
        echo json_encode(['background' => `$row ? `$row['value'] : 'grid']);
    } catch (Exception `$e) {
        echo json_encode(['background' => 'grid', 'error' => `$e->getMessage()]);
    }
    exit;
}

if (`$_SERVER['REQUEST_METHOD'] === 'POST') {
    `$data = json_decode(file_get_contents('php://input'), true);
    
    `$bg = `$data['background'] ?? 'grid';
    
    try {
        `$stmt = `$pdo->prepare("INSERT INTO settings (` + "`key`" + `, value) VALUES ('background', ?) ON DUPLICATE KEY UPDATE value = ?");
        `$stmt->execute([`$bg, `$bg]);
        echo json_encode(['status' => 'ok', 'background' => `$bg]);
    } catch (Exception `$e) {
        http_response_code(500);
        echo json_encode(['error' => `$e->getMessage()]);
    }
    exit;
}
"@
[System.IO.File]::WriteAllText("$PWD\php-files\background.php", $bgPhp, $utf8)
Write-Host "4. background.php OK" -ForegroundColor Green

# ============================================
# 5. BackgroundContext.tsx - بهتر
# ============================================
$bgCtx = @"
import { createContext, useContext, useEffect, useState, ReactNode } from "react";

type BgType = "grid" | "none" | "dots" | "lines" | "waves" | "circles" | "triangles";

interface BgContextType {
  background: BgType;
  changeBackground: (bg: BgType) => Promise<void>;
}

const BgContext = createContext<BgContextType | null>(null);

export function BackgroundProvider({ children }: { children: ReactNode }) {
  const [background, setBackground] = useState<BgType>("grid");

  const loadBg = () => {
    fetch("./background.php")
      .then(r => r.json())
      .then(d => {
        if (d.background) setBackground(d.background);
      })
      .catch(() => {});
  };

  useEffect(() => {
    loadBg();
    const handler = () => loadBg();
    window.addEventListener("background-updated", handler);
    return () => window.removeEventListener("background-updated", handler);
  }, []);

  const changeBackground = async (bg: BgType) => {
    setBackground(bg);
    try {
      const res = await fetch("./background.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: "kiarash", pass: "CHANGE_ME", background: bg }),
      });
      if (res.ok) {
        window.dispatchEvent(new Event("background-updated"));
      }
    } catch {}
  };

  return (
    <BgContext.Provider value={{ background, changeBackground }}>
      {children}
    </BgContext.Provider>
  );
}

export function useBackground() {
  const ctx = useContext(BgContext);
  if (!ctx) throw new Error("useBackground must be inside BackgroundProvider");
  return ctx;
}
"@
[System.IO.File]::WriteAllText("$PWD\src\context\BackgroundContext.tsx", $bgCtx, $utf8)
Write-Host "5. BackgroundContext.tsx OK" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "همه فایل ها آپدیت شدن!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
