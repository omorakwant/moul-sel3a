"use client";

import { X } from "lucide-react";
import { Product, LangType } from "../../types";

interface AddProductModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAdd: (product: Product) => void;
  lang: LangType;
  cur: Record<string, string>;
}

export function AddProductModal({
  isOpen,
  onClose,
  onAdd,
  lang,
  cur,
}: AddProductModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
      <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-3 text-xs">
        <div className="flex justify-between items-center border-b border-white/10 pb-3">
          <h3 className="font-extrabold text-sm text-white">{cur.modalAddProductTitle}</h3>
          <button onClick={onClose} className="text-white/40 hover:text-white">
            <X className="h-4 w-4" />
          </button>
        </div>

        <div>
          <label className="text-white/60 block mb-1">{cur.productNameLabel}</label>
          <input
            type="text"
            id="new-prod-name"
            defaultValue="Batterie iPhone 12 Pro (Haute Capacité)"
            className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-3 text-white outline-none focus:border-[#FF6B00]"
          />
        </div>

        <div className="grid grid-cols-3 gap-2">
          <div>
            <label className="text-white/60 block mb-1 text-[10px]">{cur.colT1} (DH)</label>
            <input
              type="number"
              id="new-prod-t1"
              defaultValue="95"
              className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-2 text-white"
            />
          </div>
          <div>
            <label className="text-white/60 block mb-1 text-[10px]">{cur.colT2}</label>
            <input
              type="number"
              id="new-prod-t2"
              defaultValue="80"
              className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-2 text-white"
            />
          </div>
          <div>
            <label className="text-white/60 block mb-1 text-[10px]">{cur.colT3}</label>
            <input
              type="number"
              id="new-prod-t3"
              defaultValue="68"
              className="h-9 w-full rounded-xl border border-white/15 bg-white/5 px-2 text-white"
            />
          </div>
        </div>

        <button
          onClick={() => {
            const nameEl = document.getElementById("new-prod-name") as HTMLInputElement;
            const t1El = document.getElementById("new-prod-t1") as HTMLInputElement;
            const t2El = document.getElementById("new-prod-t2") as HTMLInputElement;
            const t3El = document.getElementById("new-prod-t3") as HTMLInputElement;

            const newProd: Product = {
              id: "prod-" + Date.now(),
              name: nameEl?.value || "Nouvel Accessoire",
              nameAr: nameEl?.value || "أكسسوار جديد",
              brand: "Accessoires Pro",
              stock: 100,
              t1: parseFloat(t1El?.value) || 95,
              t2: parseFloat(t2El?.value) || 80,
              t3: parseFloat(t3El?.value) || 68,
              status: "Actif",
              compatibility: ["Tous les modèles"],
            };

            onAdd(newProd);
            alert(
              lang === "ar"
                ? "تمت إضافة المنتوج الجديد إلى كاطالوج المولي بنجاح !"
                : "Nouveau produit ajouté au catalogue grossiste avec succès !"
            );
          }}
          className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black mt-2"
        >
          {cur.saveToInventoryBtn}
        </button>
      </div>
    </div>
  );
}
