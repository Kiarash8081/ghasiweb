import { useEffect, useRef, useState, type CSSProperties } from "react";
import { useNavigate } from "react-router-dom";
import { useTheme } from "../context/ThemeContext";
import { t, TranslationKey } from "../data/translations";

interface MenuProps {
  onSelect?: (panel: string | null) => void;
  active?: string | null;
}

const OPEN_DELAY = 900;

const routes: Record<string, string> = {
  about: "/about",
  work: "/work",
  design: "/design",
  contact: "/contact",
};

export default function Menu({ onSelect, active = null }: MenuProps) {
  const { lang } = useTheme();
  const navigate = useNavigate();
  const [forming, setForming] = useState<string | null>(null);
  const timerRef = useRef<number | null>(null);

  const items: { key: string | null; label: string; tone: "teal" | "clay" }[] = [
    { key: "about", label: t(lang, "nav.about" as TranslationKey), tone: "teal" },
    { key: "work", label: t(lang, "nav.work" as TranslationKey), tone: "clay" },
    { key: "design", label: t(lang, "nav.design" as TranslationKey), tone: "teal" },
    { key: "contact", label: t(lang, "nav.contact" as TranslationKey), tone: "clay" },
    { key: null, label: "Paar-web", tone: "clay" },
  ];

  useEffect(() => {
    return () => {
      if (timerRef.current) window.clearTimeout(timerRef.current);
    };
  }, []);

  const clearTimer = () => {
    if (timerRef.current) {
      window.clearTimeout(timerRef.current);
      timerRef.current = null;
    }
  };

  const handleSelect = (key: string | null) => {
    clearTimer();

    if (key === null) {
      setForming(null);
      onSelect?.(null);
      navigate("/");
      return;
    }

    if (active === key) {
      setForming(null);
      onSelect?.(null);
      return;
    }

    setForming(key);
    onSelect?.(null);
    timerRef.current = window.setTimeout(() => {
      setForming(null);
      onSelect?.(key);
      navigate(routes[key] || "/");
      timerRef.current = null;
    }, OPEN_DELAY);
  };

  const top = items.slice(0, 3);
  const bottom = items.slice(3);

  const renderCell = (item: (typeof items)[number]) => {
    const isForming = forming !== null && forming === item.key;
    const isActive = active === item.key && item.key !== null;
    return (
      <button
        key={item.key ?? "home"}
        type="button"
        className={`hex-cell tone-${item.tone}${isActive ? " is-active" : ""}${isForming ? " is-forming" : ""}${item.key === null ? " hex-brand" : ""}`}
        onClick={() => handleSelect(item.key)}
        aria-expanded={item.key !== null && (active === item.key || forming === item.key)}
        disabled={forming !== null && !isForming}
      >
        <span className="hex-glow" aria-hidden="true" />
        {isForming && (
          <span className="hex-orbit" aria-hidden="true">
            {Array.from({ length: 8 }, (_, i) => (
              <span key={i} className="hex-shard-wrap" style={{ transform: `rotate(${i * 45}deg)` } as CSSProperties}>
                <span className={`hex-shard tone-${i % 2 === 0 ? "teal" : "clay"}`} style={{ animationDelay: `${i * 45}ms` }} />
              </span>
            ))}
            <span className="hex-ring" />
            <span className="hex-ring hex-ring-late" />
          </span>
        )}
        <span className="hex-face">
          <span className="hex-label">{item.label}</span>
        </span>
      </button>
    );
  };

  return (
    <nav className={`honeycomb${forming ? " is-opening" : ""}`} aria-label="">
      <div className="honey-row">{top.map(renderCell)}</div>
      <div className="honey-row honey-row-offset">{bottom.map(renderCell)}</div>
    </nav>
  );
}
