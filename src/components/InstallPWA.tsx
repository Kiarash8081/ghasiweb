import { useEffect, useState } from "react";
import { useTheme } from "../context/ThemeContext";

export default function InstallPWA() {
  const { lang } = useTheme();
  const [deferredPrompt, setDeferredPrompt] = useState<any>(null);
  const [show, setShow] = useState(false);
  const [isIOS, setIsIOS] = useState(false);
  const [isStandalone, setIsStandalone] = useState(false);
  const [showManual, setShowManual] = useState(false);

  useEffect(() => {
    // چک iOS
    const ios = /iPad|iPhone|iPod/.test(navigator.userAgent);
    setIsIOS(ios);

    // چک نصب شده
    const standalone = window.matchMedia("(display-mode: standalone)").matches;
    setIsStandalone(standalone);

    // چک قبلا رد شده
    const dismissed = localStorage.getItem("pwa-dismissed");
    if (dismissed) return;

    if (standalone) return;

    const handler = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e);
      setTimeout(() => setShow(true), 2000);
    };

    window.addEventListener("beforeinstallprompt", handler);

    // اگه iOS بود پیام دستی نشون بده
    if (ios && !standalone) {
      setTimeout(() => setShowManual(true), 3000);
    }

    return () => window.removeEventListener("beforeinstallprompt", handler);
  }, []);

  const handleInstall = async () => {
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === "accepted") setShow(false);
    setDeferredPrompt(null);
  };

  const handleDismiss = () => {
    setShow(false);
    setShowManual(false);
    localStorage.setItem("pwa-dismissed", "true");
  };

  // اگه نصب شده هیچی نشون نده
  if (isStandalone) return null;

  const labels = {
    fa: {
      title: "نصب اپلیکیشن",
      desc: "برنامه را روی گوشی نصب کن و مثل یک اپ از آن استفاده کن",
      install: "نصب کن",
      later: "بعدا",
      iosTitle: "نصب روی iPhone",
      iosDesc: "دکمه اشتراکگذاری را بزن سپس Add to Home Screen را انتخاب کن",
    },
    en: {
      title: "Install App",
      desc: "Install the app on your phone and use it like an app",
      install: "Install",
      later: "Later",
      iosTitle: "Install on iPhone",
      iosDesc: "Tap Share, then Add to Home Screen",
    },
    ar: {
      title: "تثبت التطبق",
      desc: "ثبت التطبيق على هاتفك واستخدمه كتطبيق",
      install: "تثبت",
      later: "لاحقا",
      iosTitle: "تثبت على iPhone",
      iosDesc: "اضغط على زر المشاركة ثم Add to Home Screen",
    },
  };
  const L = labels[lang] || labels.fa;

  // نمایش پیام iOS
  if (showManual && isIOS && !show) {
    return (
      <div className="pwa-prompt">
        <div className="pwa-prompt-inner">
          <div className="pwa-icon">
            <img src="./assets/logo.png" alt="Paar-web" />
          </div>
          <div className="pwa-text">
            <strong>{L.iosTitle}</strong>
            <span>{L.iosDesc}</span>
          </div>
          <div className="pwa-buttons">
            <button className="pwa-later" onClick={handleDismiss}></button>
          </div>
        </div>
      </div>
    );
  }

  // نمایش پیام اندروید/دسکتاپ
  if (!show || !deferredPrompt) return null;

  return (
    <div className="pwa-prompt">
      <div className="pwa-prompt-inner">
        <div className="pwa-icon">
          <img src="./assets/logo.png" alt="Paar-web" />
        </div>
        <div className="pwa-text">
          <strong>{L.title}</strong>
          <span>{L.desc}</span>
        </div>
        <div className="pwa-buttons">
          <button className="pwa-install" onClick={handleInstall}>{L.install}</button>
          <button className="pwa-later" onClick={handleDismiss}>{L.later}</button>
        </div>
      </div>
    </div>
  );
}