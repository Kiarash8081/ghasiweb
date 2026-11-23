import { useRef, useState } from "react";
import { readJson } from "../lib/readJson";
import type { ChatMessage } from "./ChatMedia";

const MAX = 10 * 1024 * 1024;

interface ChatToolsProps {
  chatId: number;
  sender: "user" | "admin";
  adminAuth?: { user: string; pass: string };
  onSent: (message: ChatMessage) => void;
  onError: (text: string) => void;
}

export default function ChatTools({ chatId, sender, adminAuth, onSent, onError }: ChatToolsProps) {
  const fileRef = useRef<HTMLInputElement>(null);
  const recorder = useRef<MediaRecorder | null>(null);
  const [recording, setRecording] = useState(false);

  const upload = async (file: File, kind: "image" | "video" | "voice") => {
    if (file.size > MAX) {
      onError("حجم فایل باید حداکثر ۱۰ مگابایت باشد");
      return;
    }
    const body = new FormData();
    body.append("chat_id", String(chatId));
    body.append("sender", sender);
    body.append("kind", kind);
    body.append("file", file);
    if (adminAuth) {
      body.append("user", adminAuth.user);
      body.append("pass", adminAuth.pass);
    }
    try {
      const res = await fetch("./api/chat_upload.php", { method: "POST", body });
      const data = await readJson(res);
      if (data.message) onSent({ ...data.message, id: Number(data.message.id) });
      else onError(data.error || "ارسال فایل انجام نشد");
    } catch {
      onError("ارسال فایل انجام نشد");
    }
  };

  const onFile = (file: File) => {
    if (file.type.startsWith("image/")) upload(file, "image");
    else if (file.type.startsWith("video/")) upload(file, "video");
    else onError("فقط عکس یا ویدیو تا ۱۰ مگابایت");
  };

  const toggleVoice = async () => {
    if (recording && recorder.current) {
      recorder.current.stop();
      setRecording(false);
      return;
    }
    try {
      const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
      const rec = new MediaRecorder(stream);
      const chunks: Blob[] = [];
      rec.ondataavailable = (e) => {
        if (e.data.size) chunks.push(e.data);
      };
      rec.onstop = () => {
        stream.getTracks().forEach((t) => t.stop());
        const type = rec.mimeType || "audio/webm";
        const ext = type.includes("mp4") ? "m4a" : type.includes("ogg") ? "ogg" : "webm";
        const file = new File(chunks, `voice.${ext}`, { type });
        upload(file, "voice");
      };
      recorder.current = rec;
      rec.start();
      setRecording(true);
    } catch {
      onError("دسترسی به میکروفون داده نشد");
    }
  };

  return (
    <>
      <input
        ref={fileRef}
        type="file"
        accept="image/*,video/*"
        hidden
        onChange={(e) => {
          const file = e.target.files?.[0];
          e.target.value = "";
          if (file) onFile(file);
        }}
      />
      <button type="button" className="chat-tool" aria-label="پیوست" onClick={() => fileRef.current?.click()}>
        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2">
          <path d="M21.4 11.05 12.2 20.24a6 6 0 0 1-8.48-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.82-2.83l8.48-8.48" />
        </svg>
      </button>
      <button type="button" className={recording ? "chat-tool rec" : "chat-tool"} aria-label="ویس" onClick={toggleVoice}>
        <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" strokeWidth="2">
          <rect x="9" y="3" width="6" height="11" rx="3" />
          <path d="M5 11a7 7 0 0 0 14 0M12 18v3" />
        </svg>
      </button>
    </>
  );
}
