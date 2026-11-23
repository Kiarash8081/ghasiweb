import { useState } from "react";
import { useTheme } from "../context/ThemeContext";

interface AdmakProps {
  onOpenAdmin: () => void;
  onOpenChat?: () => void;
}

export default function Admak({ onOpenAdmin, onOpenChat }: AdmakProps) {
  const { lang, theme, setLang, setTheme } = useTheme();
  const [open, setOpen] = useState(false);

  return (
    <div className="admak-wrap">
      <button className="admak-btn" type="button" aria-expanded={open} onClick={() => setOpen(!open)} aria-label="">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <circle cx="12" cy="7" r="4" />
          <path d="M4 21v-2a4 4 0 0 1 4-4h8a4 4 0 0 1 4 4v2" />
        </svg>
      </button>

      {open && (
        <div className="admak-panel">
          <p className="admak-label" />
          <div className="admak-row">
            <button onClick={() => setTheme("light")} className={theme === "light" ? "on" : ""} />
            <button onClick={() => setTheme("dark")} className={theme === "dark" ? "on" : ""} />
          </div>

          <p className="admak-label" />
          <div className="admak-row">
            {(["fa", "en", "ar"] as const).map((l) => (
              <button key={l} onClick={() => setLang(l)} className={lang === l ? "on" : ""}>
                {l === "fa" ? "فا" : l === "en" ? "EN" : "ع"}
              </button>
            ))}
          </div>

          <div className="admak-divider"></div>

          <button className="admak-chat" onClick={() => { setOpen(false); onOpenChat?.(); }} />
          <button className="admak-admin" onClick={() => { setOpen(false); onOpenAdmin(); }} />
        </div>
      )}
    </div>
  );
}
