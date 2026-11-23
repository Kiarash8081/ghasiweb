/** Standard admin avatar using site logo */
export default function AdminAvatar() {
  return (
    <span className="tg-avatar admin-logo-avatar" aria-hidden="true">
      <picture>
        <source srcSet="./assets/logo.webp" type="image/webp" />
        <img src="./assets/logo.png" alt="" width="42" height="42" />
      </picture>
    </span>
  );
}
