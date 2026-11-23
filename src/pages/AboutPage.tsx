import PageFrame from "../components/PageFrame";
import SpotlightPanel from "../components/ui/SpotlightPanel";
import AsciiGlitchRipple from "../components/effects/AsciiGlitchRipple";
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";

export default function AboutPage() {
  const { lang } = useTheme();

  const stats = [
    { label: "", value: "" },
    { label: "", value: "" },
    { label: "", value: "" },
  ];

  const links = [
    { href: "#", label: "", meta: "" },
    { href: "#", label: t(lang, "about.telegram"), meta: "" },
    { href: "#", label: t(lang, "about.github"), meta: "" },
    { href: "#", label: t(lang, "about.bale"), meta: "" },
  ];

  return (
    <PageFrame
      title={t(lang, "about.name")}
      kicker={t(lang, "about.kicker")}
      description={t(lang, "about.bio")}
      tone="teal"
    >
      <section className="vp-stack">
        <SpotlightPanel className="vp-panel vp-hero-panel">
          <div className="vp-badge" />
          <AsciiGlitchRipple>{t(lang, "about.name")}</AsciiGlitchRipple>
          <p className="about-role">{t(lang, "about.role")}</p>
          <div className="vp-stats">
            {stats.map((item, i) => (
              <div key={i} className="vp-stat">
                <span className="vp-stat-label">{item.label}</span>
                <strong className="vp-stat-value">{item.value}</strong>
              </div>
            ))}
          </div>
        </SpotlightPanel>

        <div className="vp-grid-2">
          {links.map((item, i) => (
            <SpotlightPanel key={i} as="a" href={item.href} className="vp-link-card">
              <span className="vp-meta">{item.meta}</span>
              <strong>{item.label}</strong>
              <span className="vp-arrow" aria-hidden="true">↗</span>
            </SpotlightPanel>
          ))}
        </div>
      </section>
    </PageFrame>
  );
}
