"use client";

import { X, CheckCircle2, Phone } from "lucide-react";
import { Order, LangType } from "../../types";

interface HandshakePinModalProps {
  order: Order | null;
  onClose: () => void;
  handshakePinInput: string;
  setHandshakePinInput: (pin: string) => void;
  handshakeSuccess: boolean;
  setHandshakeSuccess: (success: boolean) => void;
  onSuccessDelivered: () => void;
  lang: LangType;
  cur: Record<string, string>;
}

export function HandshakePinModal({
  order,
  onClose,
  handshakePinInput,
  setHandshakePinInput,
  handshakeSuccess,
  setHandshakeSuccess,
  onSuccessDelivered,
  lang,
  cur,
}: HandshakePinModalProps) {
  if (!order) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4">
      <div className="w-full max-w-sm rounded-3xl border border-white/15 bg-[#1C1917] p-5 space-y-4 text-xs">
        {!handshakeSuccess ? (
          <>
            <div className="flex justify-between items-center border-b border-white/10 pb-3">
              <div>
                <h3 className="font-extrabold text-sm text-white">{cur.modalHandshakeTitle}</h3>
                <p className="text-[10px] text-white/40">{cur.modalHandshakeSub}</p>
              </div>
              <button onClick={onClose} className="text-white/40 hover:text-white">
                <X className="h-4 w-4" />
              </button>
            </div>

            <p className="text-white/60">{cur.modalHandshakeHint}</p>

            <div className="my-4 text-center">
              <input
                type="text"
                maxLength={4}
                placeholder="PIN"
                value={handshakePinInput}
                onChange={(e) => setHandshakePinInput(e.target.value)}
                className="h-12 w-32 rounded-2xl border-2 border-white/20 bg-white/5 text-center text-xl font-black tracking-widest text-[#FF6B00] outline-none focus:border-[#FF6B00]"
              />
              <p className="text-[10px] text-white/40 mt-1">{cur.demoPinCode} {order.pin}</p>
            </div>

            <button
              onClick={() => {
                if (handshakePinInput === order.pin) {
                  setHandshakeSuccess(true);
                  onSuccessDelivered();
                } else {
                  alert(
                    lang === "ar"
                      ? `كود غالط، عاود. الكود الصحيح هو ${order.pin}`
                      : `Code PIN incorrect. Le code valide est ${order.pin}`
                  );
                }
              }}
              className="w-full rounded-xl bg-[#FF6B00] py-2.5 font-bold text-black hover:bg-[#ff8533]"
            >
              {cur.verifyHandshakeBtn}
            </button>
          </>
        ) : (
          /* SCREEN 11: FULL HANDSHAKE CONFIRMATION VIEW */
          <div className="space-y-4 text-center">
            <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-emerald-500/20 text-emerald-400">
              <CheckCircle2 className="h-10 w-10 text-emerald-400" />
            </div>

            <div>
              <h3 className="text-lg font-extrabold text-white">{cur.handshakeSuccessTitle}</h3>
              <p className="text-[11px] text-white/50">{cur.handshakeSuccessSub}</p>
            </div>

            <div className="rounded-2xl border border-white/10 bg-black/40 p-3.5 text-left space-y-2 text-xs">
              <div className="flex justify-between text-white/60">
                <span>{cur.deliverySlipLabel}</span>
                <span className="font-bold text-white">BON-{order.id}</span>
              </div>
              <div className="flex justify-between text-white/60">
                <span>{cur.articlesVerifiedLabel}</span>
                <span className="font-bold text-emerald-400">
                  {order.items?.reduce((s: number, i) => s + (i.received || i.ordered), 0)} {lang === "ar" ? "قطع" : "unités"}
                </span>
              </div>
              <div className="flex justify-between text-white/60">
                <span>{cur.anomaliesLabel}</span>
                <span className="font-bold text-white/80">{cur.zeroAnomalies}</span>
              </div>
              <div className="border-t border-white/5 pt-1.5 flex justify-between font-bold text-sm">
                <span className="text-white">{cur.amountValidatedLabel}</span>
                <span className="text-[#FF6B00]">{order.total.toFixed(2)} DH</span>
              </div>
            </div>

            <div className="rounded-2xl border border-white/10 bg-black/40 p-3 text-left space-y-1 text-xs">
              <p className="text-[10px] uppercase font-bold text-white/40">{cur.partiesPresent}</p>
              <p className="text-white/80 font-medium">{cur.driverParty} {order.driverName}</p>
              <p className="text-white/80 font-medium">{cur.retailerParty}</p>
            </div>

            <a
              href={`https://wa.me/212661000001?text=${encodeURIComponent(
                lang === "ar"
                  ? `السلام عليكم، تم استلام الطلبية BON-${order.id} بنجاح. المبلغ: ${order.total.toFixed(2)} درهم. الاستلام مأكد بالكود.`
                  : `Bonjour, confirmation de réception pour le bon BON-${order.id}. Montant total: ${order.total.toFixed(2)} DH. Remise physique validée.`
              )}`}
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center justify-center gap-2 w-full rounded-xl bg-[#25D366] py-2.5 font-bold text-white hover:bg-[#20ba59] transition"
            >
              <Phone className="h-4 w-4" />
              <span>{cur.shareWhatsAppBtn}</span>
            </a>

            <button
              onClick={onClose}
              className="w-full rounded-xl border border-white/15 bg-white/5 py-2 font-bold text-white hover:bg-white/10"
            >
              {cur.closeAndFinishBtn}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
