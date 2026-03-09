"use client";

const variants = {
  primary: "bg-blue-600 hover:bg-blue-700 text-white",
  secondary: "dark:bg-slate-700 bg-slate-200 dark:hover:bg-slate-600 hover:bg-slate-300 dark:text-white text-slate-800",
  danger: "bg-red-600 hover:bg-red-700 text-white",
  ghost: "bg-transparent dark:hover:bg-slate-800 hover:bg-slate-100 dark:text-slate-300 text-slate-600",
};

export function Button({
  children,
  variant = "primary",
  size = "md",
  className = "",
  ...props
}: {
  children: React.ReactNode;
  variant?: keyof typeof variants;
  size?: "sm" | "md" | "lg";
  className?: string;
} & React.ButtonHTMLAttributes<HTMLButtonElement>) {
  const sizeClass = size === "sm" ? "px-3 py-1.5 text-sm" : size === "lg" ? "px-6 py-3" : "px-4 py-2";
  return (
    <button
      className={`${variants[variant]} ${sizeClass} rounded-lg font-medium transition-colors disabled:opacity-50 disabled:cursor-not-allowed ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
