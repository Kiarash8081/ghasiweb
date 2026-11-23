import { useState, useCallback, useEffect, type ReactNode } from "react";
import Admak from "./Admak";
import AdminPanel from "./AdminPanel";
import ChatPanel from "./ChatPanel";
import InstallPWA from "./InstallPWA";
import Viewer from "./Viewer";
import AmbientOrbs from "./effects/AmbientOrbs";
import CursorGlow from "./effects/CursorGlow";
import MinimalParticles from "./effects/MinimalParticles";
import { PerspectiveGrid } from "./ui/PerspectiveGrid";

interface ViewerState {
  url: string;
  host: string;
}

interface AppShellProps {
  children: ReactNode;
  loading?: boolean;
}

export function openViewer(url: string, host: string) {
  window.dispatchEvent(new CustomEvent("open-viewer", { detail: { url, host } }));
}

export default function AppShell({ children, loading = false }: AppShellProps) {
  const [viewer, setViewer] = useState<ViewerState | null>(null);
  const [adminOpen, setAdminOpen] = useState(false);
  const [chatOpen, setChatOpen] = useState(false);

  const handleProjectsChange = useCallback(() => {
    window.dispatchEvent(new Event("projects-updated"));
  }, []);

  useEffect(() => {
    const handler = (event: Event) => {
      const detail = (event as CustomEvent<{ url: string; host: string }>).detail;
      if (detail?.url) setViewer({ url: detail.url, host: detail.host || detail.url });
    };
    window.addEventListener("open-viewer", handler as EventListener);
    return () => window.removeEventListener("open-viewer", handler as EventListener);
  }, []);

  return (
    <>
      <PerspectiveGrid />
      <AmbientOrbs />
      <MinimalParticles />
      <CursorGlow />
      <div className="app-content" style={{ opacity: loading ? 0 : 1 }}>
        <Admak onOpenAdmin={() => setAdminOpen(true)} onOpenChat={() => setChatOpen(true)} />
        {children}
      </div>
      {viewer && (
        <Viewer url={viewer.url} host={viewer.host} onClose={() => setViewer(null)} />
      )}
      <AdminPanel
        isOpen={adminOpen}
        onClose={() => setAdminOpen(false)}
        onProjectsChange={handleProjectsChange}
      />
      <ChatPanel isOpen={chatOpen} onClose={() => setChatOpen(false)} />
      <InstallPWA />
    </>
  );
}
