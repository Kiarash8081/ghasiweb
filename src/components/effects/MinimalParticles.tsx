import { useEffect, useRef } from "react";

type Particle = {
  x: number;
  y: number;
  vx: number;
  vy: number;
  r: number;
  a: number;
  tone: 0 | 1 | 2;
};

const COLORS = [
  "220, 38, 38",
  "15, 118, 110",
  "194, 93, 24",
];

export default function MinimalParticles() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    let width = 0;
    let height = 0;
    let dpr = 1;
    let raf = 0;
    let alive = true;
    const mouse = { x: -9999, y: -9999, active: false };
    let particles: Particle[] = [];

    const resize = () => {
      dpr = Math.min(window.devicePixelRatio || 1, 2);
      width = window.innerWidth;
      height = window.innerHeight;
      canvas.width = Math.floor(width * dpr);
      canvas.height = Math.floor(height * dpr);
      canvas.style.width = `${width}px`;
      canvas.style.height = `${height}px`;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

      const count = reduce ? 18 : Math.min(48, Math.floor((width * height) / 28000));
      particles = Array.from({ length: count }, () => ({
        x: Math.random() * width,
        y: Math.random() * height,
        vx: (Math.random() - 0.5) * (reduce ? 0.08 : 0.22),
        vy: (Math.random() - 0.5) * (reduce ? 0.08 : 0.22),
        r: 0.8 + Math.random() * 1.8,
        a: 0.18 + Math.random() * 0.35,
        tone: (Math.floor(Math.random() * 3) as 0 | 1 | 2),
      }));
    };

    const onMove = (e: PointerEvent) => {
      mouse.x = e.clientX;
      mouse.y = e.clientY;
      mouse.active = true;
    };
    const onLeave = () => {
      mouse.active = false;
      mouse.x = -9999;
      mouse.y = -9999;
    };

    const draw = () => {
      if (!alive) return;
      ctx.clearRect(0, 0, width, height);

      for (let i = 0; i < particles.length; i++) {
        const p = particles[i];
        p.x += p.vx;
        p.y += p.vy;

        if (p.x < -20) p.x = width + 20;
        if (p.x > width + 20) p.x = -20;
        if (p.y < -20) p.y = height + 20;
        if (p.y > height + 20) p.y = -20;

        if (mouse.active) {
          const dx = p.x - mouse.x;
          const dy = p.y - mouse.y;
          const dist = Math.hypot(dx, dy);
          if (dist < 140 && dist > 0.1) {
            p.vx += (dx / dist) * 0.012;
            p.vy += (dy / dist) * 0.012;
          }
        }

        p.vx *= 0.995;
        p.vy *= 0.995;
        const speed = Math.hypot(p.vx, p.vy);
        if (speed < 0.04) {
          p.vx += (Math.random() - 0.5) * 0.02;
          p.vy += (Math.random() - 0.5) * 0.02;
        }
      }

      const linkDist = Math.min(130, width * 0.12);
      for (let i = 0; i < particles.length; i++) {
        for (let j = i + 1; j < particles.length; j++) {
          const a = particles[i];
          const b = particles[j];
          const dx = a.x - b.x;
          const dy = a.y - b.y;
          const dist = Math.hypot(dx, dy);
          if (dist > linkDist) continue;
          const alpha = (1 - dist / linkDist) * 0.14;
          ctx.beginPath();
          ctx.moveTo(a.x, a.y);
          ctx.lineTo(b.x, b.y);
          ctx.strokeStyle = `rgba(220, 38, 38, ${alpha})`;
          ctx.lineWidth = 1;
          ctx.stroke();
        }
      }

      for (const p of particles) {
        ctx.beginPath();
        ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        ctx.fillStyle = `rgba(${COLORS[p.tone]}, ${p.a})`;
        ctx.fill();
      }

      raf = window.requestAnimationFrame(draw);
    };

    resize();
    draw();
    window.addEventListener("resize", resize);
    window.addEventListener("pointermove", onMove, { passive: true });
    window.addEventListener("pointerleave", onLeave);

    const onVis = () => {
      if (document.hidden) {
        window.cancelAnimationFrame(raf);
      } else {
        raf = window.requestAnimationFrame(draw);
      }
    };
    document.addEventListener("visibilitychange", onVis);

    return () => {
      alive = false;
      window.cancelAnimationFrame(raf);
      window.removeEventListener("resize", resize);
      window.removeEventListener("pointermove", onMove);
      window.removeEventListener("pointerleave", onLeave);
      document.removeEventListener("visibilitychange", onVis);
    };
  }, []);

  return <canvas className="fx-particles" ref={canvasRef} aria-hidden="true" />;
}
