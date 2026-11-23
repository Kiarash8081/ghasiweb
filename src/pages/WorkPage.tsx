import { useEffect, useState } from "react";
import PageFrame from "../components/PageFrame";
import SpotlightPanel from "../components/ui/SpotlightPanel";
import { openViewer } from "../components/AppShell";
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";
import { getProjects } from "../lib/api";
import { defaultProjects, type Project } from "../data/defaultProjects";

function previewOf(p: Project) {
  if (p.image) return p.image;
  const hit = defaultProjects.find((d) => d.id === p.id || d.url === p.url || d.host === p.host);
  return hit?.image || "";
}

export default function WorkPage() {
  const { lang } = useTheme();
  const [projects, setProjects] = useState<Project[]>(defaultProjects);

  useEffect(() => {
    let alive = true;
    function load() {
      getProjects().then((list) => { if (alive) setProjects(list); }).catch(() => { if (alive) setProjects(defaultProjects); });
    }
    load();
    window.addEventListener("projects-updated", load);
    return () => { alive = false; window.removeEventListener("projects-updated", load); };
  }, []);

  return (
    <PageFrame
      title={t(lang, "work.title")}
      kicker={t(lang, "work.kicker")}
      description={t(lang, "work.slogan")}
      tone="clay"
    >
      <section className="vp-stack">
        <div className="vp-toolbar">
          <span className="vp-chip">{projects.length} {t(lang, "work.count")}</span>
          <span className="vp-chip ghost">{t(lang, "work.preview")}</span>
        </div>

        {projects.length === 0 ? (
          <SpotlightPanel className="vp-panel">
            <p className="slogan">{t(lang, "work.empty")}</p>
          </SpotlightPanel>
        ) : (
          <div className="vp-work-grid">
            {projects.map((p, i) => {
              const shot = previewOf(p);
              return (
                <SpotlightPanel
                  key={p.id}
                  as="button"
                  className={`vp-work-card tone-${i % 2 === 0 ? "teal" : "clay"}`}
                  onClick={() => openViewer(p.url, p.host)}
                >
                  <span className="vp-work-preview" aria-hidden="true">
                    {shot ? (
                      <img className="vp-work-shot is-ready" src={shot} alt="" loading="lazy" decoding="async" />
                    ) : null}
                    <iframe
                      className="vp-work-frame"
                      src={p.url}
                      title={p.host}
                      loading="lazy"
                      sandbox="allow-scripts allow-same-origin"
                      tabIndex={-1}
                    />
                    <span className="vp-work-shade" />
                    <span className="vp-live-dot">{t(lang, "work.live")}</span>
                  </span>
                  <span className="vp-work-meta">
                    <span className="vp-meta">0{i + 1}</span>
                    <strong className="vp-work-host">{p.host}</strong>
                    <span className="vp-work-cta">{t(lang, "work.open")}</span>
                  </span>
                </SpotlightPanel>
              );
            })}
          </div>
        )}
      </section>
    </PageFrame>
  );
}
