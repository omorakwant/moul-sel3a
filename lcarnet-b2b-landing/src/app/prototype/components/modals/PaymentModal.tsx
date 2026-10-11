"use client";

import { X } from "lucide-react";
import { LangType } from "../../types";

interface PaymentModalProps {
  isOpen: boolean;
  onClose: () => void;
  paymentAmount: string;
  setPaymentAmount: (amount: string) => void;
  paymentMethod: string;
  setPaymentMethod: (method: string) => void;
  paymentRef: string;
  setPaymentRef: (ref: string) => void;
  onSubmit: (amount: number, method: string, ref: string) => void;
  lang: LangType;
  cur: Record<string, string>;
}

export function PaymentModal({
  isOpen,
  onClose,
  paymentAmount,
  setPaymentAmount,
  paymentMethod,
  setPaymentMethod,
  paymentRef,
  setPaymentRef,
  onSubmit,
  lang,
  cur,
}: PaymentModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
      <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4">
        <div className="flex justify-between items-center border-b border-white/10 pb-3">
          <h3 className="font-extrabold text-sm text-white">{cur.modalPaymentTitle}</h3>
          <button onClick={onClose} className="text-white/40 hover:text-white">
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="space-y-3 text-xs">
          <div>
            <label className="text-white/60 block mb-1">{cur.transferMethodLabel}</label>
            <div className="grid grid-cols-2 gap-1.5">
              {["wafacash", "cashplus", "virement", "especes"].map((m) => (
                <button
                  key={m}
                  onClick={() => setPaymentMethod(m)}
                  className={`rounded-xl py-2 font-bold uppercase transition text-[11px] ${
                    paymentMethod === m ? "bg-[#FF6B00] text-black" : "bg-white/5 text-white/60"
                  }`}
                >
                  {m}
                </button>
              ))}
            </div>
          </div>

          <div>
            <label className="text-white/60 block mb-1">{cur.amountMADLabel}</label>
            <input
              type="number"
              value={paymentAmount}
              onChange={(e) => setPaymentAmount(e.target.value)}
              className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 font-bold text-white outline-none focus:border-[#FF6B00]"
            />
          </div>

          <div>
            <label className="text-white/60 block mb-1">{cur.receiptRefLabel}</label>
            <input
              type="text"
              value={paymentRef}
              onChange={(e) => setPaymentRef(e.target.value)}
              className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 text-white outline-none focus:border-[#FF6B00]"
            />
          </div>

          {/* OCR Demo Simulator Button */}
          <button
            type="button"
            onClick={() => {
              setPaymentAmount("1500");
              setPaymentRef(`WF-${Math.floor(100000 + Math.random() * 900000)}`);
              alert(
                lang === "ar"
                  ? "سيمولاسيون OCR : تم قراءة المبلغ ورقم التوصيل من صورة التوصيل تلقائياً !"
                  : "Simulation OCR (Démo) : Montant et référence extraits de la photo du reçu !"
              );
            }}
            className="w-full rounded-xl border border-dashed border-[#FF6B00]/60 bg-[#FF6B00]/5 py-2 font-bold text-[#FF6B00] text-[11px]"
          >
            {cur.ocrSimulateBtn}
          </button>
        </div>

        <div className="pt-2 flex gap-2">
          <button
            onClick={() => {
              const amt = parseFloat(paymentAmount) || 0;
              onSubmit(amt, paymentMethod, paymentRef);
            }}
            className="flex-1 rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black text-xs"
          >
            {cur.confirmAndNotifyWhatsApp}
          </button>
        </div>
      </div>
    </div>
  );
}
