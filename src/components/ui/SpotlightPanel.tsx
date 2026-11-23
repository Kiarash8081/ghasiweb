import { useRef, type CSSProperties, type MouseEvent, type ReactNode, type RefObject } from "react";

interface SpotlightPanelProps {
  children: ReactNode;
  className?: string;
  as?: "div" | "article" | "section" | "a" | "button";
  href?: string;
  onClick?: () => void;
  style?: CSSProperties;
}

export default function SpotlightPanel({
  children,
  className = "",
  as = "div",
  href,
  onClick,
  style,
}: SpotlightPanelProps) {
  const ref = useRef<HTMLElement>(null);

  const onMove = (e: MouseEvent<HTMLElement>) => {
    const el = ref.current;
    if (!el) return;
    const rect = el.getBoundingClientRect();
    el.style.setProperty("--spot-x", `${e.clientX - rect.left}px`);
    el.style.setProperty("--spot-y", `${e.clientY - rect.top}px`);
  };

  const props = {
    ref: ref as RefObject<never>,
    className: `spot-panel ${className}`.trim(),
    onMouseMove: onMove,
    style,
    onClick,
  };

  if (as === "a" && href) {
    return (
      <a {...props} href={href} target="_blank" rel="noreferrer">
        <span className="spot-panel-shine" aria-hidden="true" />
        <span className="spot-panel-body">{children}</span>
      </a>
    );
  }

  if (as === "button") {
    return (
      <button type="button" {...props}>
        <span className="spot-panel-shine" aria-hidden="true" />
        <span className="spot-panel-body">{children}</span>
      </button>
    );
  }

  const Tag = as;
  return (
    <Tag {...props}>
      <span className="spot-panel-shine" aria-hidden="true" />
      <span className="spot-panel-body">{children}</span>
    </Tag>
  );
}
