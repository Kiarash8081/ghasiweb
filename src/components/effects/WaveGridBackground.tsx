interface Props {
  children?: React.ReactNode;
  className?: string;
}

export default function WaveGridBackground({
  children,
  className = ""
}: Props) {
  return (
    <div className={`wave-grid-background ${className}`}>
      <div className="wave-grid-lines" aria-hidden="true">
        {Array.from({ length: 18 }).map((_, i) => (
          <span key={`h-${i}`} className="wave-line horizontal" />
        ))}

        {Array.from({ length: 14 }).map((_, i) => (
          <span key={`v-${i}`} className="wave-line vertical" />
        ))}
      </div>

      <div className="wave-grid-content">
        {children}
      </div>
    </div>
  );
}
