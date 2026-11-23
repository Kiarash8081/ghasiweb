import { readJson } from "./readJson";
import { defaultProjects, type Project } from "../data/defaultProjects";

const IS_LOCAL = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";
const PORTFOLIO_KEY = "portfolio";
const KEEP_FLAG = "portfolio-keep-pvice-cafe";

export type { Project };
interface Message { id: string; name: string; email: string; message: string; created_at: string; is_read: number; }

export async function getBackground(): Promise<string> {
  if (IS_LOCAL) return localStorage.getItem("bg") || "grid";
  try {
    const res = await fetch("./background.php");
    const data = await res.json();
    return data.background || "grid";
  } catch {
    return localStorage.getItem("bg") || "grid";
  }
}

export async function setBackground(bg: string): Promise<void> {
  localStorage.setItem("bg", bg);
  window.dispatchEvent(new Event("background-updated"));
  if (!IS_LOCAL) {
    try {
      await fetch("./background.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: "kiarash", pass: "CHANGE_ME", background: bg }),
      });
    } catch {}
  }
}

function normalizeProjects(value: unknown): Project[] {
  if (!Array.isArray(value)) return [];
  return value.filter((item): item is Project => {
    return !!item && typeof item === "object" && typeof (item as Project).url === "string" && (item as Project).url.trim() !== "";
  }).map((item) => ({
    id: String(item.id || ""),
    host: String(item.host || ""),
    url: String(item.url),
  }));
}

function projectsFromPayload(data: unknown): Project[] {
  if (Array.isArray(data)) return data.length ? normalizeProjects(data) : defaultProjects;
  if (!data || typeof data !== "object") return defaultProjects;
  const payload = data as { managed?: boolean; projects?: unknown };
  const projects = normalizeProjects(payload.projects);
  if (payload.managed) return projects;
  return projects.length ? projects : defaultProjects;
}

function keepOnResume(project: Project) {
  const blob = `${project.host} ${project.url}`.toLowerCase();
  return blob.includes("pvice") || blob.includes("cafe") || `${project.host}${project.url}`.includes("کافه");
}

function pruneLocalOnce(list: Project[]): Project[] {
  if (localStorage.getItem(KEEP_FLAG) === "1") return list;
  const next = list.filter(keepOnResume);
  localStorage.setItem(KEEP_FLAG, "1");
  if (next.length !== list.length) {
    localStorage.setItem(PORTFOLIO_KEY, JSON.stringify({ managed: true, projects: next }));
  }
  return next;
}

function readLocalPortfolio(): Project[] {
  try {
    const saved = localStorage.getItem(PORTFOLIO_KEY);
    if (saved) return pruneLocalOnce(projectsFromPayload(JSON.parse(saved)));
    const older = localStorage.getItem("projects");
    if (older) return pruneLocalOnce(normalizeProjects(JSON.parse(older)));
  } catch {}
  localStorage.setItem(KEEP_FLAG, "1");
  return defaultProjects;
}

export async function getProjects(): Promise<Project[]> {
  if (IS_LOCAL) return readLocalPortfolio();
  const res = await fetch("./save.php?t=" + Date.now(), { cache: "no-store" });
  if (!res.ok) throw new Error("portfolio load failed");
  return projectsFromPayload(await readJson(res));
}

export async function saveProjects(projects: Project[]): Promise<boolean> {
  const clean = normalizeProjects(projects);
  if (IS_LOCAL) {
    localStorage.setItem(PORTFOLIO_KEY, JSON.stringify({ managed: true, projects: clean }));
    window.dispatchEvent(new Event("projects-updated"));
    return true;
  }
  const res = await fetch("./save.php", {
    method: "POST",
    cache: "no-store",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ user: "kiarash", pass: "CHANGE_ME", projects: clean }),
  });
  const data = await readJson(res).catch(() => ({}));
  if (!res.ok || data.status !== "ok") return false;
  window.dispatchEvent(new Event("projects-updated"));
  return true;
}

export async function getMessages(): Promise<Message[]> {
  if (IS_LOCAL) {
    const data = localStorage.getItem("messages");
    return data ? JSON.parse(data) : [];
  }
  try {
    const res = await fetch("./messages.php?user=kiarash&pass=" + encodeURIComponent("CHANGE_ME"));
    const data = await res.json();
    return Array.isArray(data) ? data : [];
  } catch {
    const data = localStorage.getItem("messages");
    return data ? JSON.parse(data) : [];
  }
}

export async function saveMessage(msg: { name: string; email: string; message: string }): Promise<void> {
  const newMsg: Message = {
    id: Date.now().toString(),
    name: msg.name,
    email: msg.email,
    message: msg.message,
    created_at: new Date().toISOString(),
    is_read: 0,
  };
  const existing = localStorage.getItem("messages");
  const messages: Message[] = existing ? JSON.parse(existing) : [];
  messages.unshift(newMsg);
  localStorage.setItem("messages", JSON.stringify(messages));
  if (!IS_LOCAL) {
    const res = await fetch("./contact.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(msg),
    });
    const data = await res.json().catch(() => null);
    if (!res.ok || !data || data.status !== "ok") {
      throw new Error(data?.error || "save failed");
    }
  }
}

export async function deleteMessage(id: string): Promise<void> {
  const existing = localStorage.getItem("messages");
  const messages: Message[] = existing ? JSON.parse(existing) : [];
  const filtered = messages.filter((m: Message) => m.id !== id);
  localStorage.setItem("messages", JSON.stringify(filtered));
  if (!IS_LOCAL) {
    try {
      await fetch("./messages.php", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ user: "kiarash", action: "delete", id }),
      });
    } catch {}
  }
}