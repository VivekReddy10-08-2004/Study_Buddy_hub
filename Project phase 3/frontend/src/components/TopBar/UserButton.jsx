// src/components/TopBar/UserButton.jsx
import React from "react";
import { User } from "lucide-react";   // <-- ICON IMPORT

const UserButton = () => {
  return (
    <button
      className="
        w-16 h-16
        bg-[#605448] hover:bg-[#50463A]
        rounded-full
        flex items-center justify-center
        shadow-md
        transition active:scale-95
        text-white
      "
    >
      <User className="w-7 h-7" />   {/* CLEAN ICON CENTERED */}
    </button>
  );
};

export default UserButton;
