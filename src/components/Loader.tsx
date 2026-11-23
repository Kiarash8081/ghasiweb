import { useEffect, useState } from "react";

interface LoaderProps {
  onDone: () => void;
}

export default function Loader({ onDone }: LoaderProps) {
  const [done, setDone] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setDone(true);
      setTimeout(onDone, 600);
    }, 700);
    return () => clearTimeout(timer);
  }, [onDone]);

  return (
    <div className={done ? "loader done" : "loader"}>
      <div className="loader-logo">Mojde</div>

      <div className="loader-laptop">
        <div className="loader-lid">
          <div className="loader-screen">
            <div className="loader-lines">
              <i></i><i></i><i></i><i></i><i></i><i></i><i></i>
            </div>
          </div>
        </div>
        <div className="loader-deck"></div>
      </div>

      <div className="loader-track">
        <div className="loader-fill"></div>
      </div>
      <p className="loader-text">loading</p>
    </div>
  );
}