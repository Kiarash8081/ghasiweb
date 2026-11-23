$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding $false

Write-Host "اضافه کردن قابلیت ها به سایت..." -ForegroundColor Cyan

# ============================================
# 1. App.tsx - اضافه کردن Analytics + ChatWidget
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
import Analytics from "./components/Analytics";
import ChatWidget from "./components/ChatWidget";
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
      <Analytics />
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
      <ChatWidget />
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
Write-Host "1. App.tsx OK" -ForegroundColor Green

# ============================================
# 2. Panels.tsx - اضافه کردن Resume + ContactForm
# ============================================
$panels = @"
import { useState, useEffect } from "react";
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";
import ContactBar from "./ContactBar";
import ResumeButton from "./ResumeButton";
import ContactForm from "./ContactForm";

interface Project { id: string; host: string; url: string; }
interface PanelsProps { active: string | null; onOpenViewer: (url: string, host: string) => void; }

const API_URL = "./save.php";

export default function Panels({ active, onOpenViewer }: PanelsProps) {
  const { lang } = useTheme();
  const [projects, setProjects] = useState<Project[]>([]);

  useEffect(() => {
    function load() {
      fetch(API_URL).then(r => r.json()).then(d => { if (Array.isArray(d) && d.length > 0) setProjects(d); }).catch(() => {});
    }
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
            <div style={{ marginTop: "24px", display: "flex", justifyContent: "center" }}>
              <ResumeButton />
            </div>
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
              <article className="tile">
                <span className="mark"></span>
                <b>{lang === "fa" ? "طراحی با ریکت" : "Built with React"}</b>
                <span>{lang === "fa" ? "خدمات طراحی سایت" : "Website design"}</span>
              </article>
              <article className="tile">
                <span className="mark"></span>
                <b>{lang === "fa" ? "سئو و لوگو" : "SEO and Logo"}</b>
                <span>{lang === "fa" ? "خدمات سئو" : "SEO services"}</span>
              </article>
              <article className="tile">
                <span className="mark"></span>
                <b>{lang === "fa" ? "داده و اطلاعات" : "Data"}</b>
                <span>{lang === "fa" ? "خدمات داده" : "Data services"}</span>
              </article>
            </div>
          </div>
        </section>
      )}
      {active === "contact" && (
        <section className="sheet">
          <ContactBar />
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
Write-Host "2. Panels.tsx OK" -ForegroundColor Green

# ============================================
# 3. اضافه کردن CSS
# ============================================
$css = [System.IO.File]::ReadAllText("$PWD\src\index.css", $utf8)

$newCSS = @"

/* ============================================
   Resume Button
   ============================================ */
.resume-btn {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 14px 24px;
  background: linear-gradient(135deg, #dc2626, #b91c1c);
  color: #fff;
  border-radius: 14px;
  text-decoration: none;
  font-weight: 700;
  font-size: 1rem;
  box-shadow: 0 8px 20px rgba(220, 38, 38, 0.25);
  transition: all 0.2s;
}

.resume-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 28px rgba(220, 38, 38, 0.35);
}

.resume-btn svg {
  width: 20px;
  height: 20px;
}

/* ============================================
   Contact Form
   ============================================ */
.contact-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-width: 500px;
  margin: 0 auto;
}

.contact-form textarea {
  resize: vertical;
  min-height: 100px;
  font-family: inherit;
}
"@

$css = $css + $newCSS
[System.IO.File]::WriteAllText("$PWD\src\index.css", $css, $utf8)
Write-Host "3. CSS OK" -ForegroundColor Green

Write-Host ""
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "همه فایل ها آپدیت شدن!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "حالا build کن:" -ForegroundColor Yellow
Write-Host "  npm run build" -ForegroundColor White
Write-Host "  Compress-Archive -Path 'dist\*' -DestinationPath 'site.zip' -Force" -ForegroundColor White
