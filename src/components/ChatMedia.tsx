import { useState } from "react";

export interface ChatMessage {
  id: number;
  sender: "user" | "admin";
  content: string;
  created_at: string;
  kind?: "text" | "image" | "video" | "voice" | null;
  file_path?: string | null;
}

export function MsgMenu({ onMe, onAll }: { onMe: () => void; onAll: () => void }) {
  const [open, setOpen] = useState(false);
  return (
    <div className="msg-actions">
      <button type="button" className="msg-more" aria-label="" onClick={() => setOpen((v) => !v)}>⋮</button>
      {open && (
        <div className="msg-menu">
          <button type="button" onClick={() => { setOpen(false); onMe(); }} />
          <button type="button" onClick={() => { setOpen(false); onAll(); }} />
        </div>
      )}
    </div>
  );
}

export function MessageBody({ message }: { message: ChatMessage }) {
  const kind = message.kind || "text";
  const src = message.file_path ? "./" + message.file_path.replace(/^\.\//, "") : "";
  if (kind === "image" && src) return <img className="chat-media" src={src} alt="" />;
  if (kind === "video" && src) return <video className="chat-media" src={src} controls />;
  if (kind === "voice" && src) return <audio className="chat-media" src={src} controls />;
  return <span className="chat-text" dir="auto">{message.content}</span>;
}
