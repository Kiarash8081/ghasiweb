export default function ContactBar() {
  const items = [
    { href: "#", label: "" },
    { href: "#", label: "" },
    { href: "#", label: "" },
    { href: "#", label: "" },
    { href: "#", label: "" },
  ];

  return (
    <div className="vui-contact-wrap">
      <div className="vui-contact-group">
        {items.map((item, i) => (
          <a key={i} className="vui-item" href={item.href}>
            <span className="vui-tip">{item.label}</span>
            <div className="vui-item-inner">
              <div className="vui-front">
                <span className="vui-letter vui-icon" />
              </div>
              <div className="vui-back">
                <span className="vui-letter-white vui-icon" />
              </div>
            </div>
            <span className="vui-label">{item.label}</span>
          </a>
        ))}
      </div>
    </div>
  );
}
