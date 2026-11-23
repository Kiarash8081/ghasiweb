import { useEffect } from "react";
import { useLocation } from "react-router-dom";
import { useTheme } from "../context/ThemeContext";
import { t, type TranslationKey } from "../data/translations";

const SITE = "";

const META: Record<string, { title: TranslationKey; desc: TranslationKey }> = {
  "/": { title: "seo.homeTitle", desc: "seo.homeDesc" },
  "/about": { title: "seo.aboutTitle", desc: "seo.aboutDesc" },
  "/work": { title: "seo.workTitle", desc: "seo.workDesc" },
  "/design": { title: "seo.designTitle", desc: "seo.designDesc" },
  "/contact": { title: "seo.contactTitle", desc: "seo.contactDesc" },
};

function setMeta(selector: string, attr: string, value: string) {
  const el = document.querySelector(selector);
  if (el) el.setAttribute(attr, value);
}

export default function SeoHead() {
  const { pathname } = useLocation();
  const { lang } = useTheme();

  useEffect(() => {
    const entry = META[pathname] || META["/"];
    const title = t(lang, entry.title);
    const description = t(lang, entry.desc);
    const url = `${SITE}${pathname === "/" ? "/" : `/#${pathname}`}`;

    document.title = title;
    document.documentElement.lang = lang === "fa" ? "fa" : lang === "ar" ? "ar" : "en";
    document.documentElement.dir = lang === "en" ? "ltr" : "rtl";

    setMeta('meta[name="description"]', "content", description);
    setMeta('meta[property="og:title"]', "content", title);
    setMeta('meta[property="og:description"]', "content", description);
    setMeta('meta[property="og:url"]', "content", url);
    setMeta('meta[property="og:locale"]', "content", lang === "fa" ? "fa_IR" : lang === "ar" ? "ar_SA" : "en_US");
    setMeta('meta[name="twitter:title"]', "content", title);
    setMeta('meta[name="twitter:description"]', "content", description);
    setMeta('link[rel="canonical"]', "href", `${SITE}/`);
  }, [pathname, lang]);

  return null;
}
