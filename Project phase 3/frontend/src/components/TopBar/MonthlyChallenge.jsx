// src/components/TopBar/MonthlyChallenge.jsx
import React from "react";

const MonthlyChallenge = ({ completedSessions, targetSessions, streakDays }) => {
  const pct = Math.min(
    100,
    Math.round((completedSessions / targetSessions) * 100)
  );

  return (
    <div className="flex-1 rounded-3xl bg-white/90 px-6 py-3 shadow-md backdrop-blur-sm max-w-md">
      <p className="text-center text-sm font-semibold text-[#5C4A3B]">
        November Challenge
      </p>

      {/* Progress bar */}
      <div className="mt-2 w-full">
        <div className="h-2 w-full overflow-hidden rounded-full bg-[#F7E0D3]">
          <div
            className="h-full rounded-full bg-gradient-to-r from-[#D97853] to-[#F39F73] transition-[width] duration-300"
            style={{ width: `${pct}%` }}
          />
        </div>
        <div className="mt-1 flex items-center justify-between text-[11px] text-[#7A5B47]">
          <span>
            {completedSessions}/{targetSessions} sessions
          </span>
          <span>{pct}%</span>
        </div>
      </div>

      {/* Streak */}
      <div className="mt-1 flex items-center justify-center gap-1 text-xs text-[#7A5B47]">
        <span role="img" aria-label="fire">
          🔥
        </span>
        <span>{streakDays} days</span>
      </div>
    </div>
  );
};

export default MonthlyChallenge;
