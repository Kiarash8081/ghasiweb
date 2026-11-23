(function () {
  try {
    if (location.hostname === "localhost" || location.hostname === "127.0.0.1") return;
    var payload = JSON.stringify({ path: location.pathname, ref: document.referrer || "" });
    if (navigator.sendBeacon) {
      navigator.sendBeacon("./analytics.php", new Blob([payload], { type: "application/json" }));
      return;
    }
    fetch("./analytics.php", { method: "POST", headers: { "Content-Type": "application/json" }, body: payload, keepalive: true }).catch(function () {});
  } catch (e) {}
})();
