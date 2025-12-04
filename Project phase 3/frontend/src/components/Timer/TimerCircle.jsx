// src/components/Timer/TimerCircle.jsx
import React, { useEffect, useState } from "react";
import GiveUpModal from "./GiveUpModal";

const CANCEL_WINDOW_SECONDS = 8;

const TimerCircle = ({ onSessionComplete, label }) => {
  const totalTime = 25 * 60; // 25 minutes
  const [timeLeft, setTimeLeft] = useState(totalTime);
  const [isRunning, setIsRunning] = useState(false);
  const [progress, setProgress] = useState(0);

  // 8-second “Cancel” window
  const [inCancelWindow, setInCancelWindow] = useState(false);
  const [cancelSecondsLeft, setCancelSecondsLeft] = useState(
    CANCEL_WINDOW_SECONDS
  );

  // Give Up modal
  const [showGiveUpModal, setShowGiveUpModal] = useState(false);

  const radius = 140;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset =
    circumference - (progress / 100) * circumference;

  /* ---------- MAIN TIMER TICK ---------- */
  useEffect(() => {
    if (!isRunning) return;

    const interval = setInterval(() => {
      setTimeLeft((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          setIsRunning(false);
          setProgress(100);
          setInCancelWindow(false);

          if (onSessionComplete) onSessionComplete();
          return 0;
        }

        const newTime = prev - 1;
        setProgress(((totalTime - newTime) / totalTime) * 100);
        return newTime;
      });
    }, 1000);

    return () => clearInterval(interval);
  }, [isRunning, onSessionComplete, totalTime]);

  /* ---------- 8s CANCEL WINDOW TICK ---------- */
  useEffect(() => {
    if (!isRunning || !inCancelWindow) return;
    if (cancelSecondsLeft <= 0) {
      setInCancelWindow(false);
      return;
    }

    const id = setTimeout(
      () => setCancelSecondsLeft((s) => s - 1),
      1000
    );
    return () => clearTimeout(id);
  }, [isRunning, inCancelWindow, cancelSecondsLeft]);

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${String(mins).padStart(2, "0")}:${String(secs).padStart(
      2,
      "0"
    )}`;
  };

  const resetTimer = () => {
    setIsRunning(false);
    setTimeLeft(totalTime);
    setProgress(0);
    setInCancelWindow(false);
    setCancelSecondsLeft(CANCEL_WINDOW_SECONDS);
  };

  /* ---------- BUTTON BEHAVIOUR ---------- */

  const handleStart = () => {
    setIsRunning(true);
    setInCancelWindow(true);
    setCancelSecondsLeft(CANCEL_WINDOW_SECONDS);
  };

  const handleEarlyCancel = () => {
    resetTimer();
  };

  const handleGiveUpClick = () => {
    setShowGiveUpModal(true);
  };

  const handleGiveUpConfirm = () => {
    // hook to “ruin reward in StudyVille”
    console.log("Player gave up — ruin reward in StudyVille here.");
    setShowGiveUpModal(false);
    resetTimer();
  };

  const handleGiveUpCancel = () => {
    setShowGiveUpModal(false);
  };

  const handleMainButtonClick = () => {
    if (!isRunning) {
      handleStart();
    } else if (inCancelWindow) {
      handleEarlyCancel();
    } else {
      handleGiveUpClick();
    }
  };

  const mainButtonLabel = !isRunning
    ? "Start Focus"
    : inCancelWindow
    ? `Cancel (${cancelSecondsLeft}s)`
    : "Give Up";

  const showChangeTimer = !isRunning && timeLeft === totalTime;

  return (
    <div className="timer-circle-wrapper">
      {/* === ORB WITH PROGRESS RING === */}
      <div className="timer-orb">
        <svg
          className="timer-orb-ring"
          viewBox="0 0 320 320"
        >
          {/* background ring */}
          <circle
            cx="160"
            cy="160"
            r={radius}
            fill="none"
            stroke="rgba(255,255,255,0.35)"
            strokeWidth="14"
          />
          {/* progress ring */}
          <circle
            cx="160"
            cy="160"
            r={radius}
            fill="none"
            stroke="#50463A"
            strokeWidth="14"
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={strokeDashoffset}
          />
        </svg>

        {/* reward illustration */}
        <div className="drop-shadow-lg" style={{ position: "relative", zIndex: 1 }}>
          <svg width="180" height="180" viewBox="0 0 180 180">
            {/* ground */}
            <polygon
              points="90,160 20,130 90,100 160,130"
              fill="#7CB342"
            />
            <polygon
              points="90,165 20,135 20,130 90,160 160,130 160,135"
              fill="#558B2F"
            />

            {/* house base */}
            <polygon
              points="50,130 50,70 90,50 130,70 130,130 90,150"
              fill="#F5F5F5"
            />
            <polygon
              points="90,150 130,130 130,70 90,90"
              fill="#D0D0D0"
            />
            <polygon
              points="50,130 90,150 90,90 50,70"
              fill="#FFFFFF"
            />

            {/* roof */}
            <polygon
              points="90,30 40,60 90,45 140,60"
              fill="#D97853"
            />
            <polygon
              points="90,45 140,60 140,70 90,55"
              fill="#C56745"
            />
            <polygon
              points="40,60 90,45 90,55 40,70"
              fill="#E88B6B"
            />

            {/* door */}
            <rect
              x="86"
              y="110"
              width="12"
              height="20"
              fill="#A85A32"
            />

            {/* windows */}
            <rect
              x="60"
              y="80"
              width="15"
              height="15"
              fill="#87CEEB"
              stroke="#888"
              strokeWidth="1"
            />
            <rect
              x="60"
              y="105"
              width="15"
              height="15"
              fill="#87CEEB"
              stroke="#888"
              strokeWidth="1"
            />

            {/* trees */}
            <ellipse
              cx="35"
              cy="125"
              rx="12"
              ry="15"
              fill="#4CAF50"
            />
            <ellipse
              cx="145"
              cy="125"
              rx="12"
              ry="15"
              fill="#4CAF50"
            />
          </svg>
        </div>
      </div>

      {/* LABEL / TAG */}
      {label && (
        <button className="timer-tag" type="button">
          <span className="timer-tag-dot" />
          {label}
        </button>
      )}

      {/* TIMER NUMBER */}
      <div className="timer-time">{formatTime(timeLeft)}</div>

      {/* MAIN BUTTON */}
      <button
        type="button"
        onClick={handleMainButtonClick}
        className="btn btn-primary"
      >
        {mainButtonLabel}
      </button>

      {/* CHANGE TIMER */}
      {showChangeTimer && (
        <button
          type="button"
          onClick={resetTimer}
          className="timer-change-link"
        >
          Change Timer
        </button>
      )}

      {/* GIVE UP MODAL */}
      <GiveUpModal
        isOpen={showGiveUpModal}
        onCancel={handleGiveUpCancel}
        onConfirm={handleGiveUpConfirm}
      />
    </div>
  );
};

export default TimerCircle;
