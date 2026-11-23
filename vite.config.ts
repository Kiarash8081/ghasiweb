import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'
import path from 'path'
import { cpSync } from 'node:fs'

export default defineConfig({
  plugins: [
    react(),
    {
      name: 'copy-php-api',
      closeBundle() {
        cpSync('api', 'dist/api', { recursive: true })
        for (const file of ['contact.php', 'messages.php', 'db.php', 'background.php', 'save.php', 'analytics.php']) {
          cpSync(`php-files/${file}`, `dist/${file}`)
        }
      },
    },
    {
      name: 'async-css',
      apply: 'build',
      transformIndexHtml(html) {
        return html.replace(
          /<link rel="stylesheet"([^>]*?)href="([^"]+)"([^>]*)>/g,
          '<link rel="preload" as="style" href="$2" onload="this.onload=null;this.rel=\'stylesheet\'"><noscript><link rel="stylesheet" href="$2"></noscript>'
        )
      },
    },
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg', 'assets/logo.png'],
      manifest: {
        name: 'Mojde - Kiarash Ghasemian',
        short_name: 'Mojde',
        description: 'طراحی سایت، سئو و نمونه کار کیارش قاسمیان',
        theme_color: '#dc2626',
        background_color: '#ffffff',
        display: 'standalone',
        orientation: 'portrait',
        scope: './',
        start_url: './',
        lang: 'fa',
        dir: 'rtl',
        icons: [
          { src: './assets/logo-192.png', sizes: '192x192', type: 'image/png', purpose: 'any maskable' },
          { src: './assets/logo-512.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' }
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