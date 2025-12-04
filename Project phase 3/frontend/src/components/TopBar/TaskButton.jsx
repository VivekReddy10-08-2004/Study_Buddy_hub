// src/components/TopBar/TaskButton.jsx
import React, { useState } from "react";
import { ListTodo } from "lucide-react";

const TaskButton = ({ onClick }) => {
  const [pressed, setPressed] = useState(false);

  return (
    <button
      onClick={onClick}
      className="
        bg-[#605448]
        hover:bg-[#50463A]
        text-white
        w-16 h-16
        rounded-full
        text-sm font-semibold
        shadow-md
        flex items-center justify-center
        transition-all active:scale-95
      "
    >
      <ListTodo className="w-7 h-7" />
    </button>

  );
};

export default TaskButton;
