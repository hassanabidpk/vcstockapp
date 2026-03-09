"use client";

export function Input({
  label,
  className = "",
  ...props
}: {
  label?: string;
  className?: string;
} & React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <div className={className}>
      {label && <label className="block text-sm dark:text-slate-400 text-slate-600 mb-1">{label}</label>}
      <input
        className="w-full dark:bg-slate-800 bg-white border dark:border-slate-700 border-slate-300 rounded-lg px-3 py-2 dark:text-white text-slate-900 dark:placeholder-slate-500 placeholder-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-colors"
        {...props}
      />
    </div>
  );
}
