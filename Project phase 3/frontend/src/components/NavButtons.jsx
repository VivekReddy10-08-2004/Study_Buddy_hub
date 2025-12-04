// src/components/NavButtons.jsx
import React from "react";
import {
  FileQuestion,
  BookOpen,
  Users,
  MessageCircle,
  Home,
} from "lucide-react";

const NavButtons = () => {
  const items = [
    { name: "Quizzes", icon: <FileQuestion size={22} /> },
    { name: "Resources", icon: <BookOpen size={22} /> },
    { name: "Buddies", icon: <Users size={22} /> },
    { name: "Chats", icon: <MessageCircle size={22} /> },
    { name: "Studyville", icon: <Home size={22} /> },
  ];

  return (
    <nav className="mt-16 flex justify-center gap-4 md:gap-6">
      {items.map((item) => (
        <button
          key={item.name}
          type="button"
          className="
            flex flex-col items-center justify-center
            h-20 w-20
            rounded-full
            bg-[#605448]
            text-white text-xs
            shadow-md transition 
            hover:bg-[#4F453D]
            active:scale-95
            gap-1
          "
        >
          {item.icon}
          <span className="text-[11px] font-medium leading-tight text-center">
            {item.name}
          </span>
        </button>
      ))}
    </nav>
  );
};

export default NavButtons;
