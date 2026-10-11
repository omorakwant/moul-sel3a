"use client";

import { X } from "lucide-react";
import { Order, LangType } from "../../types";

interface PartialReceiptModalProps {
  order: Order | null;
  onClose: () => void;
  receivedQtys: Record<string, number>;
  setReceivedQtys: React.Dispatch<React.SetStateAction<Record<string, number>>>;
  onConfirm: (calcTotal: number, diff: number) => void;
  lang: LangType;
  cur: Record<string, string>;
}

export function PartialReceiptModal({
  order,
  onClose,
  receivedQtys,
  setReceivedQtys,
  onConfirm,
  lang,
  cur,
}: PartialReceiptModalProps) {
  if (!order) return null;

  const currentItems = order.items.map((it) => ({
    ...it,
    received: receivedQtys[it.name] ?? it.ordered,
  }));
  const calcTotal = currentItems.reduce((s: number, i) => s + i.price * i.received, 0);
  const diff = order.total - calcTotal;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
      <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4 text-xs">
        <div className="flex justify-between items-center border-b border-white/10 pb-3">
          <div>
            <h3 className="font-extrabold text-sm text-white">{cur.modalPartialTitle}</h3>
            <p className="text-[10px] text-white/40">{cur.modalPartialBon} {order.id}</p>
          </div>
          <button onClick={onClose} className="text-white/40 hover:text-white">
            <X className="h-4 w-4" />
          </button>
        </div>

        <p className="text-white/60">{cur.modalPartialHint}</p>

        <div className="space-y-3 max-h-60 overflow-y-auto pr-1">
          {order.items.map((it) => {
            const currQty = receivedQtys[it.name] ?? it.ordered;
            const isModified = currQty !== it.ordered;

            return (
              <div
                key={it.name}
                className={`rounded-xl border p-3 transition ${
                  isModified ? "border-amber-500/50 bg-amber-500/10" : "border-white/10 bg-black/40"
                }`}
              >
                <div className="flex justify-between font-bold text-white mb-1.5">
                  <span className="truncate pr-2">
                    {lang === "ar" && it.nameAr ? it.nameAr : it.name}
                  </span>
                  <span className="text-[#FF6B00] shrink-0">{it.price} DH/u</span>
                </div>
                {isModified && (
                  <p className="text-[10px] text-amber-400 font-bold mb-1">
                    {cur.qtyAdjustedAlert} {it.ordered} ➔ {currQty} pcs
                  </p>
                )}
                <div className="flex justify-between items-center">
                  <span className="text-white/50 text-[11px]">{cur.orderedLabel} {it.ordered} pcs</span>
                  <div className="flex items-center gap-2">
                    <button
                      onClick={() =>
                        setReceivedQtys((prev) => ({
                          ...prev,
                          [it.name]: Math.max(0, currQty - 1),
                        }))
                      }
                      className="h-7 w-7 rounded-lg bg-white/10 font-bold hover:bg-white/20"
                    >
                      -
                    </button>
                    <span className="w-6 text-center font-bold text-white text-sm">{currQty}</span>
                    <button
                      onClick={() =>
                        setReceivedQtys((prev) => ({
                          ...prev,
                          [it.name]: currQty + 1,
                        }))
                      }
                      className="h-7 w-7 rounded-lg bg-white/10 font-bold hover:bg-white/20"
                    >
                      +
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Live Totals & Diff */}
        <div className="rounded-xl border border-white/10 bg-black/60 p-3 space-y-1">
          <div className="flex justify-between text-white/50 text-[11px]">
            <span>{cur.initialTotalOrder}</span>
            <span>{order.total.toFixed(2)} DH</span>
          </div>
          <div className="flex justify-between font-extrabold text-white text-sm">
            <span>{cur.newTotalAfterAudit}</span>
            <span className="text-emerald-400">{calcTotal.toFixed(2)} DH</span>
          </div>
          {diff > 0 && (
            <p className="text-[10px] text-amber-300 font-bold pt-1 border-t border-white/5">
              {cur.deductionNoticePrefix} {diff.toFixed(2)} DH {cur.deductionNoticeSuffix}
            </p>
          )}
        </div>

        <button
          onClick={() => onConfirm(calcTotal, diff)}
          className="w-full rounded-xl bg-emerald-500 py-2.5 font-bold text-black hover:bg-emerald-400"
        >
          {cur.confirmAdjustmentAction}
        </button>
      </div>
    </div>
  );
}
