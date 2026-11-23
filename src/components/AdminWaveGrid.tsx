import { useEffect, useRef } from "react";

interface Props {
  className?: string;
}

/**
 * Wave Grid Background - شبیهسازی 3D Wave Grid VengeanceUI
 * با Canvas 2D - بدون Three.js
 */
export default function AdminWaveGrid({ className = "" }: Props) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const mouseRef = useRef({ x: -1000, y: -1000 });
  const animRef = useRef<number>(0);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    let width = 0;
    let height = 0;
    const dpr = window.devicePixelRatio || 1;

    const resize = () => {
      const rect = canvas.parentElement?.getBoundingClientRect();
      if (!rect) return;
      width = rect.width;
      height = rect.height;
      canvas.width = width * dpr;
      canvas.height = height * dpr;
      canvas.style.width = width + "px";
      canvas.style.height = height + "px";
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    };

    resize();
    window.addEventListener("resize", resize);

    const handleMouseMove = (e: MouseEvent) => {
      const rect = canvas.getBoundingClientRect();
      mouseRef.current.x = e.clientX - rect.left;
      mouseRef.current.y = e.clientY - rect.top;
    };
    const handleMouseLeave = () => {
      mouseRef.current.x = -1000;
      mouseRef.current.y = -1000;
    };

    canvas.addEventListener("mousemove", handleMouseMove);
    canvas.addEventListener("mouseleave", handleMouseLeave);

    const COLS = 24;
    const ROWS = 18;
    const CELL_W = 28;
    const CELL_H = 18;
    const AMP = 18;
    let time = 0;

    const isDark = () =>
      document.documentElement.classList.contains("dark");

    const draw = () => {
      time += 0.025;
      ctx.clearRect(0, 0, width, height);

      const gridW = COLS * CELL_W;
      const gridH = ROWS * CELL_H;
      const offsetX = (width - gridW) / 2;
      const offsetY = (height - gridH) / 2;

      const dark = isDark();
      const baseAlpha = dark ? 0.18 : 0.12;
      const mx = mouseRef.current.x;
      const my = mouseRef.current.y;

      for (let r = 0; r < ROWS; r++) {
        for (let c = 0; c < COLS; c++) {
          const x = offsetX + c * CELL_W;
          const y = offsetY + r * CELL_H;

          // فاصله از موس
          const dx = x + CELL_W / 2 - mx;
          const dy = y + CELL_H / 2 - my;
          const dist = Math.sqrt(dx * dx + dy * dy);
          const mouseEffect = Math.max(0, 1 - dist / 200);

          // موج سینوسی + اثر موس
          const wave =
            Math.sin(c * 0.4 + time) * Math.cos(r * 0.4 + time * 0.7);
          const z = wave * AMP + mouseEffect * 24;

          // عمق مکعب
          const depth = Math.max(0.3, 1 - z / 40);

          // رنگ
          const alpha = baseAlpha * depth + mouseEffect * 0.35;
          const color = dark
            ? `rgba(225, 6, 0, ${alpha})`
            : `rgba(220, 38, 38, ${alpha})`;

          // بالای مکعب (لوزی)
          const cx = x + CELL_W / 2;
          const cy = y + CELL_H / 2 - z;

          // خطوط افقی
          ctx.strokeStyle = color;
          ctx.lineWidth = 1;

          ctx.beginPath();
          ctx.moveTo(x, cy + CELL_H / 2);
          ctx.lineTo(cx, cy);
          ctx.lineTo(x + CELL_W, cy + CELL_H / 2);
          ctx.lineTo(cx, cy + CELL_H);
          ctx.closePath();
          ctx.stroke();

          // خط عمودی برای عمق
          if (z > 2) {
            ctx.beginPath();
            ctx.moveTo(cx, cy + CELL_H);
            ctx.lineTo(cx, cy + CELL_H + z * 0.5);
            ctx.strokeStyle = dark
              ? `rgba(225, 6, 0, ${alpha * 0.6})`
              : `rgba(220, 38, 38, ${alpha * 0.6})`;
            ctx.stroke();
          }
        }
      }

      animRef.current = requestAnimationFrame(draw);
    };

    draw();

    return () => {
      cancelAnimationFrame(animRef.current);
      window.removeEventListener("resize", resize);
      canvas.removeEventListener("mousemove", handleMouseMove);
      canvas.removeEventListener("mouseleave", handleMouseLeave);
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      className={`admin-wave-grid ${className}`}
      aria-hidden="true"
    />
  );
}
