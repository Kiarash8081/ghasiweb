import { useEffect, useRef } from "react";

interface Props {
  children: React.ReactNode;
  className?: string;
}

export default function ScrollDissolveReveal({
  children,
  className = ""
}: Props) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const update = () => {
      const rect = el.getBoundingClientRect();
      const viewport = window.innerHeight;

      const visible =
        Math.max(
          0,
          Math.min(1, (viewport - rect.top) / (viewport * 0.7))
        );

      el.style.setProperty(
        "--dissolve-progress",
        visible.toString()
      );
    };

    update();
    window.addEventListener("scroll", update, { passive: true });
    window.addEventListener("resize", update);

    return () => {
      window.removeEventListener("scroll", update);
      window.removeEventListener("resize", update);
    };
  }, []);

  return (
    <div
      ref={ref}
      className={`scroll-dissolve-reveal ${className}`}
    >
      {children}
    </div>
  );
}
