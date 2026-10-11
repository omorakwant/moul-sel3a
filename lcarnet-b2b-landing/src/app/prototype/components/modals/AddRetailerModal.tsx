"use client";

import { X } from "lucide-react";

interface AddRetailerModalProps {
  isOpen: boolean;
  onClose: () => void;
  newRetailerPhone: string;
  setNewRetailerPhone: (phone: string) => void;
  newRetailerLimit: string;
  setNewRetailerLimit: (limit: string) => void;
  onAdd: () => void;
  cur: Record<string, string>;
}

export function AddRetailerModal({
  isOpen,
  onClose,
  newRetailerPhone,
  setNewRetailerPhone,
  newRetailerLimit,
  setNewRetailerLimit,
  onAdd,
  cur,
}: AddRetailerModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
      <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4 text-xs">
        <div className="flex justify-between items-center border-b border-white/10 pb-3">
          <h3 className="font-extrabold text-sm text-white">{cur.modalAddRetailerTitle}</h3>
          <button onClick={onClose} className="text-white/40 hover:text-white">
            <X className="h-4 w-4" />
          </button>
        </div>

        <div>
          <label className="text-white/60 block mb-1">{cur.retailerPhoneLabel}</label>
          <input
            type="text"
            value={newRetailerPhone}
            onChange={(e) => setNewRetailerPhone(e.target.value)}
            className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 text-white outline-none focus:border-[#FF6B00]"
          />
        </div>

        <div>
          <label className="text-white/60 block mb-1">{cur.initialCreditLimitLabel}</label>
          <input
            type="number"
            value={newRetailerLimit}
            onChange={(e) => setNewRetailerLimit(e.target.value)}
            className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 text-white outline-none focus:border-[#FF6B00]"
          />
        </div>

        <button
          onClick={onAdd}
          className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black"
        >
          {cur.sendWhatsAppInviteBtn}
        </button>
      </div>
    </div>
  );
}
