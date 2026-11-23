import { Link } from "react-router-dom";
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";
import ContactBar from "./ContactBar";

export default function Footer() {
  const { lang } = useTheme();
  const year = new Date().getFullYear();

  const pages = [
    { to: "/about", label: t(lang, "nav.about") },
    { to: "/work", label: t(lang, "nav.work") },
    { to: "/design", label: t(lang, "nav.design") },
    { to: "/contact", label: t(lang, "nav.contact") },
  ];

  return (
    <footer className="site-footer">
      <div className="footer-glow" aria-hidden="true" />
      <div className="footer-inner">
        <div className="footer-grid">
          <div className="footer-brand">
            <Link to="/" className="footer-logo" aria-label="Paar-web">
              <picture>
                <source srcSet="./assets/logo.webp" type="image/webp" />
                <img src="./assets/logo.png" alt="" width="48" height="48" />
              </picture>
              <span>Paar-web</span>
            </Link>
            <p className="footer-tagline">{t(lang, "footer.tagline")}</p>
          </div>

          <div className="footer-col">
            <h3>{t(lang, "footer.pages")}</h3>
            <ul>
              {pages.map((p) => (
                <li key={p.to}>
                  <Link to={p.to}>{p.label}</Link>
                </li>
              ))}
            </ul>
          </div>

          <div className="footer-col">
            <h3>{t(lang, "footer.contact")}</h3>
            <ul>
              <li><a href="#"> </a></li>
              <li><a href="#">{t(lang, "contact.tg")}</a></li>
              <li><a href="#">{t(lang, "about.github")}</a></li>
              <li><a href="#">{t(lang, "contact.sms")}</a></li>
            </ul>
          </div>
        </div>

        <div className="footer-bar">
          <ContactBar />
        </div>

        <p className="footer-copy">
          {year} {t(lang, "about.name")} · {t(lang, "footer.rights")}
        </p>
      </div>
    </footer>
  );
}
