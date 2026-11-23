import PageFrame from "../components/PageFrame";
import SpotlightPanel from "../components/ui/SpotlightPanel";
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";

export default function DesignPage() {
  const { lang } = useTheme();

  const services = [
    { code: "01", title: "", text: "", wide: true },
    { code: "02", title: "", text: "", wide: false },
    { code: "03", title: "", text: "", wide: false },
    { code: "04", title: "", text: "", wide: true },
  ];

  const steps = ["", "", "", ""];

  return (
    <PageFrame
      title={t(lang, "design.title")}
      kicker={t(lang, "design.kicker")}
      description={t(lang, "design.desc")}
      tone="red"
    >
      <section className="vp-stack">
        <div className="vp-bento">
          {services.map((item) => (
            <SpotlightPanel
              key={item.code}
              as="article"
              className={`vp-bento-item${item.wide ? " is-wide" : ""}`}
            >
              <span className="vp-meta">{item.code}</span>
              <h2>{item.title}</h2>
              <p>{item.text}</p>
            </SpotlightPanel>
          ))}
        </div>

        <SpotlightPanel className="vp-panel vp-process">
          <div className="vp-badge">{t(lang, "design.process")}</div>
          <ol className="vp-steps">
            {steps.map((step, i) => (
              <li key={i}>
                <span className="vp-step-num">0{i + 1}</span>
                <span>{step}</span>
              </li>
            ))}
          </ol>
        </SpotlightPanel>
      </section>
    </PageFrame>
  );
}
