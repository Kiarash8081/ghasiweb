$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false

Write-Host "شروع..." -ForegroundColor Cyan

# ============================================
# 1. Loader.tsx - برگردون به حالت قبل
# ============================================
$loader = @"
import { useEffect, useState } from "react";

interface LoaderProps {
  onDone: () => void;
}

export default function Loader({ onDone }: LoaderProps) {
  const [done, setDone] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDone(true);
      setTimeout(onDone, 600);
    }, 2500);
    return () => clearTimeout(timer);
  }, [onDone]);

  return (
    <div className={done ? "loader done" : "loader"}>
      <div className="loader-logo">Paar-web</div>
      <div className="loader-track">
        <div className="loader-fill"></div>
      </div>
      <p className="loader-text">loading</p>
    </div>
  );
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\Loader.tsx", $loader, $utf8)
Write-Host "1. Loader.tsx OK" -ForegroundColor Green

# ============================================
# 2. InstallPWA.tsx
# ============================================
$pwa = @"
import { useEffect, useState } from "react";
import { useTheme } from "../context/ThemeContext";

export default function InstallPWA() {
  const { lang } = useTheme();
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
  const [show, setShow] = useState(false);

  useEffect(() => {
    const handler = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e);
      if (!localStorage.getItem("pwa-dismissed")) {
        setTimeout(() => setShow(true), 5000);
      }
    };
    window.addEventListener("beforeinstallprompt", handler);
    return () => window.removeEventListener("beforeinstallprompt", handler);
  }, []);

  const handleInstall = async () => {
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === "accepted") setShow(false);
    setDeferredPrompt(null);
  };

  const handleDismiss = () => {
    setShow(false);
    localStorage.setItem("pwa-dismissed", "true");
  };

  if (!show || !deferredPrompt) return null;

  const labels = {
    fa: { title: "نصب اپلیکیشن", desc: "Paar-web را روی گوشی نصب کن", install: "نصب کن", later: "بعدا" },
    en: { title: "Install App", desc: "Install Paar-web on your phone", install: "Install", later: "Later" },
    ar: { title: "تثبت التطبق", desc: "ثبت Paar-web على هاتفك", install: "تثبت", later: "لاحقا" },
  };
  const L = labels[lang] || labels.fa;

  return (
    <div className="pwa-prompt">
      <div className="pwa-prompt-inner">
        <div className="pwa-icon">
          <img src="./assets/logo.png" alt="Paar-web" />
        </div>
        <div className="pwa-text">
          <strong>{L.title}</strong>
          <span>{L.desc}</span>
        </div>
        <div className="pwa-buttons">
          <button className="pwa-install" onClick={handleInstall}>{L.install}</button>
          <button className="pwa-later" onClick={handleDismiss}>{L.later}</button>
        </div>
      </div>
    </div>
  );
}
"@
[System.IO.File]::WriteAllText("$PWD\src\components\InstallPWA.tsx", $pwa, $utf8)
Write-Host "2. InstallPWA.tsx OK" -ForegroundColor Green

# ============================================
# 3. App.tsx - با InstallPWA
# ============================================
$app = @"
import { useState, useCallback } from "react";
import { ThemeProvider } from "./context/ThemeContext";
import Admak from "./components/Admak";
import Loader from "./components/Loader";
import Menu from "./components/Menu";
import Panels from "./components/Panels";
import Viewer from "./components/Viewer";
import Footer from "./components/Footer";
import AdminPanel from "./components/AdminPanel";
import InstallPWA from "./components/InstallPWA";
import { PerspectiveGrid } from "./components/ui/PerspectiveGrid";

interface ViewerState {
  url: string;
  host: string;
}

function AppInner() {
  const [loading, setLoading] = useState(true);
  const [active, setActive] = useState<string | null>(null);
  const [viewer, setViewer] = useState<ViewerState | null>(null);
  const [adminOpen, setAdminOpen] = useState(false);

  const handleProjectsChange = useCallback(() => {
    window.dispatchEvent(new Event("projects-updated"));
  }, []);

  return (
    <>
      {loading && <Loader onDone={() => setLoading(false)} />}
      <PerspectiveGrid />
      <div className="app-content" style={{ opacity: loading ? 0 : 1 }}>
        <Admak onOpenAdmin={() => setAdminOpen(true)} />
        <header className="site-header">
          <a className="brand" href="#stage">
            <img src="/assets/logo.png" alt="Paar-web" />
          </a>
        </header>
        <main id="stage">
          <Menu onSelect={setActive} active={active} />
          <Panels active={active} onOpenViewer={(url, host) => setViewer({ url, host })} />
        </main>
        <Footer />
      </div>
      {viewer && (
        <Viewer url={viewer.url} host={viewer.host} onClose={() => setViewer(null)} />
      )}
      <AdminPanel
        isOpen={adminOpen}
        onClose={() => setAdminOpen(false)}
        onProjectsChange={handleProjectsChange}
      />
      <InstallPWA />
    </>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <AppInner />
    </ThemeProvider>
  );
}
"@
[System.IO.File]::WriteAllText("$PWD\src\App.tsx", $app, $utf8)
Write-Host "3. App.tsx OK" -ForegroundColor Green

# ============================================
# 4. main.tsx - با PWA register
# ============================================
$main = @"
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { registerSW } from "virtual:pwa-register";
import App from "./App";
import "./index.css";

registerSW({ immediate: true });

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <App />
  </StrictMode>
);
"@
[System.IO.File]::WriteAllText("$PWD\src\main.tsx", $main, $utf8)
Write-Host "4. main.tsx OK" -ForegroundColor Green

# ============================================
# 5. نصب vite-plugin-pwa
# ============================================
Write-Host "نصب vite-plugin-pwa..." -ForegroundColor Yellow
npm install -D vite-plugin-pwa
Write-Host "5. PWA package OK" -ForegroundColor Green

# ============================================
# 6. vite.config.ts
# ============================================
$vite = @"
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'
import path from 'path'

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg', 'assets/logo.png'],
      manifest: {
        name: 'Paar-web - Kiarash Ghasemian',
        short_name: 'Paar-web',
        description: 'پورتفولیو و رزومه کیارش قاسمیان',
        theme_color: '#dc2626',
        background_color: '#ffffff',
        display: 'standalone',
        orientation: 'portrait',
        scope: './',
        start_url: './',
        lang: 'fa',
        dir: 'rtl',
        icons: [
          { src: './assets/logo.png', sizes: '192x192', type: 'image/png', purpose: 'any maskable' },
          { src: './assets/logo.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' }
        ]
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}']
      }
    })
  ],
  base: './',
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
})
"@
[System.IO.File]::WriteAllText("$PWD\vite.config.ts", $vite, $utf8)
Write-Host "6. vite.config.ts OK" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "همه تغییرات اعمال شد!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "حالا توی ترمینال بزن:" -ForegroundColor Yellow
Write-Host "  npm run dev" -ForegroundColor White
