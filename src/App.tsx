import { useState } from "react";
import { HashRouter, Navigate, Route, Routes } from "react-router-dom";
import { ThemeProvider } from "./context/ThemeContext";
import AppShell from "./components/AppShell";
import Loader from "./components/Loader";
import HomePage from "./pages/HomePage";
import AboutPage from "./pages/AboutPage";
import WorkPage from "./pages/WorkPage";
import DesignPage from "./pages/DesignPage";
import ContactPage from "./pages/ContactPage";
import SeoHead from "./components/SeoHead";

function AppInner() {
  const [loading, setLoading] = useState(true);

  return (
    <>
      {loading && <Loader onDone={() => setLoading(false)} />}
      <SeoHead />
      <AppShell loading={loading}>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/about" element={<AboutPage />} />
          <Route path="/work" element={<WorkPage />} />
          <Route path="/design" element={<DesignPage />} />
          <Route path="/contact" element={<ContactPage />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </AppShell>
    </>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <HashRouter>
        <AppInner />
      </HashRouter>
    </ThemeProvider>
  );
}
