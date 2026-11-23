import { useEffect, useState } from "react";

interface Props {
  words: string[];
  interval?: number;
  className?: string;
}

export default function FlipText({
  words,
  interval = 2400,
  className = ""
}: Props) {
  const [index, setIndex] = useState(0);

  useEffect(() => {
    if (words.length < 2) return;

    const timer = window.setInterval(() => {
      setIndex((current) => (current + 1) % words.length);
    }, interval);

    return () => window.clearInterval(timer);
  }, [words, interval]);

  return (
    <span className={`flip-text ${className}`}>
      <span className="flip-text-inner" key={index}>
        {words[index]}
      </span>
    </span>
  );
}
