import { useState } from "react";
import { saveMessage } from "../lib/api";

export default function ContactForm() {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [message, setMessage] = useState("");
  const [status, setStatus] = useState<"idle" | "sending" | "sent" | "error">("idle");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!name || !email || !message) return;
    setStatus("sending");
    try {
      await saveMessage({ name, email, message });
      setStatus("sent");
      setName("");
      setEmail("");
      setMessage("");
      setTimeout(() => setStatus("idle"), 5000);
    } catch {
      setStatus("error");
    }
  };

  return (
    <form onSubmit={handleSubmit} className="contact-form">
      <input type="text" placeholder="" value={name} onChange={(e) => setName(e.target.value)} className="admin-input" required />
      <input type="email" placeholder="" value={email} onChange={(e) => setEmail(e.target.value)} className="admin-input" required />
      <textarea placeholder="" value={message} onChange={(e) => setMessage(e.target.value)} className="admin-input" rows={4} required />
      <button type="submit" className="admin-btn" disabled={status === "sending"}>
        {status === "sending" ? "" : status === "sent" ? "" : ""}
      </button>
      {status === "error" && <p className="admin-error" />}
    </form>
  );
}
