export interface Project {
  id: string;
  host: string;
  url: string;
  image?: string;
}

export const defaultProjects: Project[] = [];
