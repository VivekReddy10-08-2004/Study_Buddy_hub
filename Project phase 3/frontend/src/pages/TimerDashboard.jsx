// src/pages/TimerDashboard.jsx
import React, { useState } from "react";

import TaskButton from "../components/TopBar/TaskButton";
import MonthlyChallenge from "../components/TopBar/MonthlyChallenge";
import MoneyDisplay from "../components/TopBar/MoneyDisplay";
import UserButton from "../components/TopBar/UserButton";
import TaskModal from "../components/TopBar/TaskModal";

import TimerCircle from "../components/Timer/TimerCircle";
import NavButtons from "../components/NavButtons";

export default function TimerDashboard() {
  const [isTaskModalOpen, setIsTaskModalOpen] = useState(false);
  const [tasks, setTasks] = useState([]);
  const [isTimerRunning, setIsTimerRunning] = useState(false);
  const [cancelCountdown, setCancelCountdown] = useState(8);

  return (
    <div className="timer-page">
      {/* ---------- TOP BAR ---------- */}
      <div className="timer-top-row">
        {/* LEFT — Task Button (always visible) */}
        <div className="timer-top-left">
          <TaskButton onClick={() => setIsTaskModalOpen(true)} />
        </div>

        {/* CENTER — Monthly Challenge (hidden when timer runs) */}
        {!isTimerRunning && (
          <div className="timer-top-center">
            <MonthlyChallenge
              completedSessions={3}
              targetSessions={20}
              streakDays={5}
            />
          </div>
        )}

        {/* RIGHT — Money + User (hidden when timer runs) */}
        {!isTimerRunning && (
          <div className="timer-top-right">
            <MoneyDisplay />
            <UserButton />
          </div>
        )}
      </div>

      {/* ---------- CENTER TIMER ---------- */}
      <main className="timer-main">
        <TimerCircle
          label="Phase 2 Database Project"
          isTimerRunning={isTimerRunning}
          setIsTimerRunning={setIsTimerRunning}
          cancelCountdown={cancelCountdown}
          setCancelCountdown={setCancelCountdown}
        />
      </main>

      {/* ---------- BOTTOM NAV ---------- */}
      {!isTimerRunning && (
        <div className="timer-bottom-nav">
          <NavButtons />
        </div>
      )}

      {/* ---------- TASK MODAL ---------- */}
      <TaskModal
        isOpen={isTaskModalOpen}
        onClose={() => setIsTaskModalOpen(false)}
        tasks={tasks}
        onToggleTask={() => {}}
        onAddTask={() => {}}
      />
    </div>
  );
}
