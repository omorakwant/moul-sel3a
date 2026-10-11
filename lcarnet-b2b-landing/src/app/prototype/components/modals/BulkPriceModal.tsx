"use client";

import { X } from "lucide-react";
import { Product, LangType } from "../../types";

interface BulkPriceModalProps {
  isOpen: boolean;
  onClose: () => void;
  bulkAdjustmentType: "percentage" | "fixed";
  setBulkAdjustmentType: (type: "percentage" | "fixed") => void;
  bulkAdjustmentValue: number;
  setBulkAdjustmentValue: (val: number) => void;
  products: Product[];
  onApply: () => void;
  lang: LangType;
  cur: Record<string, string>;
}

export function BulkPriceModal({
  isOpen,
  onClose,
  bulkAdjustmentType,
  setBulkAdjustmentType,
  bulkAdjustmentValue,
  setBulkAdjustmentValue,
  products,
  onApply,
  lang,
  cur,
}: BulkPriceModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
      <div className="w-full max-w-md rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4 text-xs">
        <div className="flex justify-between items-center border-b border-white/10 pb-3">
          <div>
            <h3 className="font-extrabold text-sm text-white">{cur.modalBulkTitle}</h3>
            <p className="text-[10px] text-white/40">{cur.modalBulkSub}</p>
          </div>
          <button onClick={onClose} className="text-white/40 hover:text-white">
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="flex gap-2">
          <button
            onClick={() => setBulkAdjustmentType("percentage")}
            className={`flex-1 rounded-xl py-2 font-bold ${
              bulkAdjustmentType === "percentage" ? "bg-[#FF6B00] text-black" : "bg-white/5 text-white/60"
            }`}
          >
            {cur.percentageMode}
          </button>
          <button
            onClick={() => setBulkAdjustmentType("fixed")}
            className={`flex-1 rounded-xl py-2 font-bold ${
              bulkAdjustmentType === "fixed" ? "bg-[#FF6B00] text-black" : "bg-white/5 text-white/60"
            }`}
          >
            {cur.fixedMode}
          </button>
        </div>

        <div>
          <label className="text-white/60 block mb-1">
            {cur.adjustmentValueLabel} ({bulkAdjustmentType === "percentage" ? "%" : "DH"}) :
          </label>
          <input
            type="number"
            value={bulkAdjustmentValue}
            onChange={(e) => setBulkAdjustmentValue(parseFloat(e.target.value) || 0)}
            className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 font-bold text-white outline-none focus:border-[#FF6B00]"
          />
        </div>

        {/* Preview Table */}
        <div className="rounded-xl border border-white/10 bg-black/40 p-2.5">
          <p className="text-[10px] font-bold text-white/50 uppercase mb-2">{cur.livePreviewLabel}</p>
          <div className="space-y-1.5">
            {products.slice(0, 3).map((p) => {
              const newPrice =
                bulkAdjustmentType === "percentage"
                  ? +(p.t2 * (1 + bulkAdjustmentValue / 100)).toFixed(2)
                  : +(p.t2 + bulkAdjustmentValue).toFixed(2);
              return (
                <div key={p.id} className="flex justify-between items-center text-[11px]">
                  <span className="text-white/70 truncate max-w-[200px]">
                    {lang === "ar" && p.nameAr ? p.nameAr : p.name}
                  </span>
                  <div>
                    <span className="text-white/40 line-through mr-2">{p.t2} DH</span>
                    <span className="font-bold text-[#FF6B00]">{newPrice} DH</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        <button
          onClick={onApply}
          className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black"
        >
          {cur.applyToCatalogBtn}
        </button>
      </div>
    </div>
  );
}
