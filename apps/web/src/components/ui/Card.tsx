"use client";

export function Card({
  children,
  className = "",
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={`dark:bg-slate-900 bg-white border dark:border-slate-800 border-slate-200 rounded-xl p-4 transition-colors ${className}`}>
      {children}
    </div>
  );
}
