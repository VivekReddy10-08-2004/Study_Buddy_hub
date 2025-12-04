// src/components/TopBar/MoneyDisplay.jsx
import React, { useState } from "react";
import { CircleDollarSign, Plus } from "lucide-react";

const MoneyDisplay = () => {
  const [coins, setCoins] = useState(2153);

  const addCoins = () => setCoins((c) => c + 10);

  return (
    <div className="flex items-center">
      {/* Pill container */}
      <div
        className="
          flex items-center gap-3
          rounded-full
          bg-[#5A8F73] 
          px-4 py-1.5
          shadow-md
        "
      >
        {/* Coin icon */}
        <div
          className="
            flex items-center justify-center
            h-8 w-8
            rounded-full
            bg-gradient-to-br from-[#FFE89A] to-[#F5C14C]
            shadow-md
            border border-[#E2B64A]/70
          "
        >
          <CircleDollarSign
            size={18}
            className="text-[#C08A2A]"
            strokeWidth={2.5}
          />
        </div>

        {/* Amount text */}
        <span className="text-white text-sm font-semibold tracking-wide">
          {coins}
        </span>

        {/* Plus button */}
        <button
          type="button"
          onClick={addCoins}
          className="
            flex items-center justify-center
            h-7 w-7
            rounded-full
            bg-[#7BCF7F]
            text-white 
            shadow-sm
            hover:bg-[#6AB671]
            active:scale-95
            transition
          "
        >
          <Plus size={18} strokeWidth={3} />
        </button>
      </div>
    </div>
  );
};

export default MoneyDisplay;
