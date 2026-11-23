import { useEffect, useState } from "react";

const GLYPHS = ["</>", "{}", "=>", "if", "01", "fn", "let", "&&", "();", "for", "0x", "[]", "!=", "+=", "/*", "*/"];

export function PerspectiveGrid() {
  const tiles = Array.from({ length: 900 });
  const [code, setCode] = useState(false);

  useEffect(() => {
    const sync = () => setCode(document.documentElement.classList.contains("admin-code"));
    sync();
    const obs = new MutationObserver(sync);
    obs.observe(document.documentElement, { attributes: true, attributeFilter: ["class"] });
    return () => obs.disconnect();
  }, []);

  return (
    <div className="bg-root bg-grid-wrap" aria-hidden="true">
      <div className="bg-grid-inner">
        {tiles.map((_, i) => (
          <div key={i} className="bg-grid-tile">{code && i % 28 === 0 ? GLYPHS[Math.floor(i / 28) % GLYPHS.length] : ""}</div>
        ))}
      </div>
      <div className="bg-grid-fade" />
    </div>
  );
}

export default PerspectiveGrid;