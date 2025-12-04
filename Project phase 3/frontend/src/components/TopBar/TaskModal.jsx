// src/components/TopBar/TaskModal.jsx
import React, { useState } from "react";

const TaskModal = ({ isOpen, onClose, tasks, onToggleTask, onAddTask }) => {
  const [newTask, setNewTask] = useState("");

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    onAddTask(newTask);
    setNewTask("");
  };

  return (
    <div
      style={{
        position: "fixed",
        inset: 0,
        background: "rgba(0,0,0,0.25)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        zIndex: 50,
      }}
      onClick={onClose}
    >
      <div
        onClick={(e) => e.stopPropagation()}
        style={{
          width: "90%",
          maxWidth: 420,
          maxHeight: "80vh",
          background: "rgba(255,255,255,0.95)",
          borderRadius: 24,
          padding: "18px 18px 16px",
          boxShadow: "0 18px 40px rgba(0,0,0,0.2)",
          display: "flex",
          flexDirection: "column",
        }}
      >
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            marginBottom: 10,
          }}
        >
          <h2
            style={{
              margin: 0,
              fontSize: 18,
              color: "#4a2430",
            }}
          >
            Tasks
          </h2>
          <button
            onClick={onClose}
            style={{
              border: "none",
              background: "transparent",
              fontSize: 20,
              cursor: "pointer",
            }}
          >
            ✕
          </button>
        </div>

        {/* Task list */}
        <div
          style={{
            flex: 1,
            overflowY: "auto",
            paddingRight: 4,
            marginBottom: 10,
          }}
        >
          {tasks.length === 0 && (
            <p style={{ fontSize: 14, color: "#7e5a64" }}>
              No tasks yet. Add your first one!
            </p>
          )}
          {tasks.map((task) => (
            <label
              key={task.id}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 8,
                padding: "6px 0",
                fontSize: 14,
                cursor: "pointer",
              }}
            >
              <input
                type="checkbox"
                checked={task.done}
                onChange={() => onToggleTask(task.id)}
              />
              <span
                style={{
                  textDecoration: task.done ? "line-through" : "none",
                  color: task.done ? "#b2a0aa" : "#4b2734",
                }}
              >
                {task.text}
              </span>
            </label>
          ))}
        </div>

        {/* New task form */}
        <form onSubmit={handleSubmit} style={{ display: "flex", gap: 8 }}>
          <input
            type="text"
            placeholder="Add new task…"
            value={newTask}
            onChange={(e) => setNewTask(e.target.value)}
            style={{
              flex: 1,
              borderRadius: 999,
              border: "1px solid #f0cbd5",
              padding: "8px 12px",
              fontSize: 14,
              outline: "none",
            }}
          />
          <button
            type="submit"
            style={{
              borderRadius: 999,
              border: "none",
              padding: "8px 14px",
              fontSize: 14,
              fontWeight: 600,
              cursor: "pointer",
              background:
                "linear-gradient(135deg,#f3a28d,#cf6c51)",
              color: "#fff7f2",
            }}
          >
            Add
          </button>
        </form>

        {/* Show more button */}
        <button
          style={{
            marginTop: 10,
            alignSelf: "flex-start",
            border: "none",
            background: "transparent",
            color: "#a0524d",
            fontSize: 13,
            cursor: "pointer",
          }}
        >
          Show more →
        </button>
      </div>
    </div>
  );
};

export default TaskModal;
