"use client";

export function Skeleton({ className = "" }: { className?: string }) {
  return <div className={`animate-pulse dark:bg-slate-800 bg-slate-200 rounded ${className}`} />;
}

export function TableSkeleton({ rows = 5 }: { rows?: number }) {
  return (
    <div className="space-y-3">
      {Array.from({ length: rows }).map((_, i) => (
        <Skeleton key={i} className="h-12 w-full" />
      ))}
    </div>
  );
}
