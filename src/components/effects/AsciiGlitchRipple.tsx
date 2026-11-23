import { useEffect, useRef } from "react";

interface Props {
  children: React.ReactNode;
  className?: string;
}

export default function AsciiGlitchRipple({
  children,
  className = ""
}: Props) {
  const ref = useRef<HTMLHeadingElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const handle = () => {
      el.classList.remove("ascii-glitch-active");
      void el.offsetWidth;
      el.classList.add("ascii-glitch-active");
    };

    el.addEventListener("mouseenter", handle);
    el.addEventListener("focus", handle);

    return () => {
      el.removeEventListener("mouseenter", handle);
      el.removeEventListener("focus", handle);
    };
  }, []);

  return (
    <h2
      ref={ref}
      className={`ascii-glitch-ripple ${className}`}
      tabIndex={0}
    >
      <span className="ascii-glitch-text">{children}</span>
      <span className="ascii-glitch-shadow ascii-shadow-a">
        {children}
      </span>
      <span className="ascii-glitch-shadow ascii-shadow-b">
        {children}
      </span>
    </h2>
  );
}
