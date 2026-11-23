import { createContext, useContext, useEffect, useState, ReactNode } from "react";

type Lang = "fa" | "en" | "ar";
type Theme = "light" | "dark";

interface ThemeContextType {
  lang: Lang;
  theme: Theme;
  setLang: (l: Lang) => void;
  setTheme: (t: Theme) => void;
}

const ThemeContext = createContext<ThemeContextType | null>(null);

function getAutoTheme(): Theme {
  const hour = new Date().getHours();
  return hour >= 18 || hour < 6 ? "dark" : "light";
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>(() => {
    return (localStorage.getItem("lang") as Lang) || "fa";
  });
  const [theme, setThemeState] = useState<Theme>(() => {
    const saved = localStorage.getItem("theme");
    if (saved === "light" || saved === "dark") return saved;
    return getAutoTheme();
  });

  useEffect(() => {
    document.documentElement.lang = lang;
    document.documentElement.dir = lang === "en" ? "ltr" : "rtl";
    localStorage.setItem("lang", lang);
  }, [lang]);

  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme);
    if (theme === "dark") document.documentElement.classList.add("dark");
    else document.documentElement.classList.remove("dark");
    localStorage.setItem("theme", theme);
  }, [theme]);

  return (
    <ThemeContext.Provider value={{ lang, theme, setLang: setLangState, setTheme: setThemeState }}>
      {children}
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error("useTheme must be inside ThemeProvider");
  return ctx;
}