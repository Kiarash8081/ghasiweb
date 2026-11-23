import Menu from "../components/Menu";
import Footer from "../components/Footer";
import SiteCopy from "../components/SiteCopy";
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";

export default function HomePage() {
  const { lang } = useTheme();

  return (
    <>
      <header className="site-header">
        <a className="brand" href="#/" aria-label="Paar-web">
          <picture>
            <source srcSet="./assets/logo.webp" type="image/webp" />
            <img src="./assets/logo.png" alt="" width="58" height="58" />
          </picture>
        </a>
        <div className="site-heading">
          <h1>{t(lang, "about.name")}</h1>
          <p>{t(lang, "footer.tagline")}</p>
        </div>
      </header>
      <main id="stage">
        <div className="stage-pill">
          <h2 className="stage-kicker">{t(lang, "nav.design")}</h2>
        </div>
        <Menu />
      </main>
      <SiteCopy />
      <Footer />
    </>
  );
}
