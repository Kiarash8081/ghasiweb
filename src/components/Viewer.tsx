import { useEffect } from "react";
import { useTheme } from "../context/ThemeContext";
import { t } from "../data/translations";

interface ViewerProps {
  url: string;
  host: string;
  onClose: () => void;
}

export default function Viewer({ url, host, onClose }: ViewerProps) {
  const { lang } = useTheme();

  useEffect(() => {
    document.body.classList.add("viewer-open");
    document.body.style.overflow = "hidden";
    return () => {
      document.body.classList.remove("viewer-open");
      document.body.style.overflow = "";
    };
  }, []);

  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.key === "Escape") onClose();
    }
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [onClose]);

  return (
    <div className="viewer">
      <div className="viewer-bar">
        <button className="viewer-back" onClick={onClose}>
          â† {t(lang, "viewer.back")}
        </button>
        <div className="viewer-url">{host}</div>
      </div>
      <iframe
        className="viewer-frame"
        src={url}
        title={host}
        referrerPolicy="no-referrer"
        sandbox="allow-scripts allow-same-origin allow-forms allow-popups allow-modals"
      />
    </div>
  );
}
