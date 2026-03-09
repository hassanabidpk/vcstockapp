"use client";
import { useEffect } from "react";

export function Modal({
  isOpen,
  onClose,
  title,
  children,
}: {
  isOpen: boolean;
  onClose: () => void;
  title: string;
  children: React.ReactNode;
}) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      <div className="fixed inset-0 bg-black/60" onClick={onClose} />
      <div className="relative dark:bg-slate-900 bg-white border dark:border-slate-700 border-slate-200 rounded-xl p-6 w-full max-w-md mx-4 max-h-[90vh] overflow-y-auto transition-colors">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-lg font-semibold">{title}</h2>
          <button onClick={onClose} className="dark:text-slate-400 text-slate-500 dark:hover:text-white hover:text-slate-900 text-xl">
            ✕
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}
