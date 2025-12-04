// src/components/Timer/StudyTag.jsx
import React from "react";

export default function StudyTag({ label, onClick }) {
  return (
    <button
      onClick={onClick}
      className="
        mt-4 flex items-center gap-2
        px-5 py-2 rounded-full
        bg-[#F6EEE6]
        text-[#50463A] text-sm font-medium
        shadow-sm active:scale-95 transition
      "
    >
      <span className="h-2.5 w-2.5 rounded-full bg-emerald-500" />
      {label}
    </button>
  );
}
