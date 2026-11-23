import type { ReactNode } from "react";
import { Link } from "react-router-dom";
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";
import Footer from "./Footer";

interface PageFrameProps {
  title: string;
  kicker?: string;
  description?: string;
  tone?: "red" | "teal" | "clay";
  children: ReactNode;
}

export default function PageFrame({
  title,
  kicker,
  description,
  tone = "red",
  children,
}: PageFrameProps) {
  const { lang } = useTheme();

  return (
    <div className={`page-frame tone-${tone}`}>
      <div className="page-mesh" aria-hidden="true" />
      <div className="page-accent" aria-hidden="true">
        <span className="page-accent-line" />
        <span className="page-accent-dot" />
      </div>

      <header className="page-topbar">
        <Link className="page-back" to="/">
          <span className="page-back-arrow" aria-hidden="true">←</span>
          {t(lang, "page.back")}
        </Link>
        <div className="page-crumbs" aria-hidden="true">
          <span>Paar-web</span>
          <span>/</span>
          <span>{kicker || title}</span>
        </div>
      </header>

      <main className="page-main">
        <div className="page-hero">
          {kicker && <p className="kicker page-kicker">{kicker}</p>}
          <h1 className="page-title">
            <span className="page-title-text">{title}</span>
            <span className="page-title-underline" aria-hidden="true" />
          </h1>
          {description && <p className="page-desc">{description}</p>}
        </div>
        <div className="page-body reveal-stagger">{children}</div>
      </main>

      <Footer />
    </div>
  );
}
