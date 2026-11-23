import PageFrame from "../components/PageFrame";
import ContactForm from "../components/ContactForm";
import SpotlightPanel from "../components/ui/SpotlightPanel";
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";

export default function ContactPage() {
  const { lang } = useTheme();

  const channels = [
    { href: "#", label: "", meta: t(lang, "contact.call") },
    { href: "#", label: t(lang, "contact.tg"), meta: "" },
    { href: "#", label: t(lang, "contact.sms"), meta: "" },
  ];

  return (
    <PageFrame
      title={t(lang, "contact.title")}
      kicker={t(lang, "contact.kicker")}
      description={t(lang, "contact.slogan")}
      tone="clay"
    >
      <section className="vp-contact">
        <div className="vp-contact-side">
          {channels.map((item, i) => (
            <SpotlightPanel key={i} as="a" href={item.href} className="vp-link-card">
              <span className="vp-meta">{item.meta}</span>
              <strong>{item.label}</strong>
              <span className="vp-arrow" aria-hidden="true">↗</span>
            </SpotlightPanel>
          ))}
          <SpotlightPanel className="vp-panel vp-note">
            <p>{t(lang, "contact.note")}</p>
          </SpotlightPanel>
        </div>

        <SpotlightPanel className="vp-panel vp-form-panel">
          <div className="vp-badge">{t(lang, "contact.formBadge")}</div>
          <h2 className="vp-form-title">{t(lang, "contact.formTitle")}</h2>
          <ContactForm />
        </SpotlightPanel>
      </section>
    </PageFrame>
  );
}
