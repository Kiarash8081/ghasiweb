$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false

Write-Host "اضافه کردن PWA..." -ForegroundColor Cyan

# ============================================
# 1. نصب پکیج PWA
# ============================================
Write-Host "نصب vite-plugin-pwa..." -ForegroundColor Yellow
npm install -D vite-plugin-pwa

# ============================================
# 2. vite.config.ts - اضافه کردن PWA plugin
# ============================================
$viteConfig = @"
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
          {
            src: './assets/logo.png',
            sizes: '192x192',
            type: 'image/png',
            purpose: 'any maskable'
          },
          {
            src: './assets/logo.png',
            sizes: '512x512',
            type: 'image/png',
            purpose: 'any maskable'
          }
        ]
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        runtimeCaching: [
          {
            urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'google-fonts-cache',
              expiration: {
                maxEntries: 10,
                maxAgeSeconds: 60 * 60 * 24 * 365
              }
            }
          }
        ]
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
[System.IO.File]::WriteAllText("$PWD\vite.config.ts", $viteConfig, $utf8)
Write-Host "1. vite.config.ts OK" -ForegroundColor Green

# ============================================
# 3. main.tsx - ثبت PWA
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
Write-Host "2. main.tsx OK" -ForegroundColor Green

# ============================================
# 4. index.html - اضافه کردن theme-color و manifest
# ============================================
$html = @"
<!doctype html>
<html lang="fa" dir="rtl">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
    <meta name="theme-color" content="#dc2626" />
    <meta name="description" content="کیارش قاسمیان - طراح و توسعه دهنده سایت | نمونه کارها و خدمات طراحی وب" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
    <meta name="apple-mobile-web-app-title" content="Paar-web" />
    <meta property="og:title" content="Paar-web - Kiarash Ghasemian" />
    <meta property="og:description" content="سایتی که همان نگاه اول مشتری را نگه می دارد." />
    <meta property="og:type" content="website" />
    <link rel="icon" type="image/png" href="./assets/logo.png" />
    <link rel="apple-touch-icon" href="./assets/logo.png" />
    <title>Paar-web - Kiarash Ghasemian</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
"@
[System.IO.File]::WriteAllText("$PWD\index.html", $html, $utf8)
Write-Host "3. index.html OK" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "PWA اضافه شد!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "حالا build کن:" -ForegroundColor Yellow
Write-Host "  npm run build" -ForegroundColor White
