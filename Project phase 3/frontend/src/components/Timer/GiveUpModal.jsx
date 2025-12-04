// src/components/Timer/GiveUpModal.jsx
import React from "react";

const GiveUpModal = ({ isOpen, onCancel, onConfirm }) => {
  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/40"
      onClick={onCancel}
    >
      <div
        className="w-80 rounded-2xl bg-white p-6 shadow-xl"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 className="text-lg font-semibold text-[#50463A] mb-3">
          Are you sure you want to give up?
        </h2>
        <p className="text-sm text-[#6B5D52] mb-6">
          If you give up, a ruined decoration reward will appear in your
          StudyVille for this session.
        </p>

        <div className="flex justify-end gap-3">
          <button
            type="button"
            onClick={onCancel}
            className="rounded-full px-4 py-2 text-sm font-medium text-[#50463A] bg-[#E5E1DC] hover:bg-[#D6D1CB]"
          >
            No
          </button>
          <button
            type="button"
            onClick={onConfirm}
            className="rounded-full px-4 py-2 text-sm font-medium text-white bg-[#D9534F] hover:bg-[#C64540]"
          >
            Give Up
          </button>
        </div>
      </div>
    </div>
  );
};

export default GiveUpModal;
