export async function readJson(res: Response) {
  const text = (await res.text()).replace(/^\uFEFF+/, "").trim();
  return JSON.parse(text);
}
