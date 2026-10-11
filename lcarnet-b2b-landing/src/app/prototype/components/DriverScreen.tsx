"use client";

import React from "react";
import { DriverTab, DriverJob, LangType } from "../types";

interface DriverScreenProps {
  driverTab: DriverTab;
  setDriverTab: (tab: DriverTab) => void;
  driverCodCollected: boolean;
  setDriverCodCollected: (collected: boolean) => void;
  driverOpenJobs: DriverJob[];
  driverBidInput: Record<string, string>;
  setDriverBidInput: React.Dispatch<React.SetStateAction<Record<string, string>>>;
  driverBidSuccess: string | null;
  setDriverBidSuccess: (id: string | null) => void;
  lang: LangType;
  cur: Record<string, string>;
}

export function DriverScreen({
  driverTab,
  setDriverTab,
  driverCodCollected,
  setDriverCodCollected,
  driverOpenJobs,
  driverBidInput,
  setDriverBidInput,
  driverBidSuccess,
  setDriverBidSuccess,
  lang,
  cur,
}: DriverScreenProps) {
  return (
    <div className="w-full max-w-[430px] rounded-3xl border border-white/15 bg-[#1C1917] p-4 shadow-2xl flex flex-col min-h-[700px]">
      {/* Driver Header */}
      <div className="flex items-center justify-between border-b border-white/10 pb-3">
        <div>
          <p className="text-[11px] font-medium text-white/50">{cur.driverPartner}</p>
          <h2 className="text-base font-extrabold text-white">{cur.driverName}</h2>
          <p className="text-[10px] text-white/40">{cur.driverVehicleSub}</p>
        </div>
        <span className="rounded-full border border-[#FF6B00]/40 bg-[#FF6B00]/10 px-2.5 py-1 text-[10px] font-bold text-[#FF6B00]">
          {cur.inTourBadge}
        </span>
      </div>

      {/* TAB CONTENT */}
      <div className="flex-1 py-3 overflow-y-auto space-y-4">
        {driverTab === "active" && (
          <div className="space-y-4">
            {/* Active Job Card */}
            <div className="rounded-2xl border border-[#FF6B00]/40 bg-gradient-to-br from-[#FF6B00]/20 via-black to-black p-4">
              <span className="text-[10px] font-black uppercase tracking-wider text-[#FF6B00]">
                {cur.activeTripLabel}
              </span>
              <h3 className="mt-1 text-base font-extrabold text-white">{cur.activeTripRoute}</h3>
              <p className="text-xs text-white/60">{cur.activeTripDest}</p>

              {/* Big PIN Display */}
              <div className="mt-4 rounded-xl border border-white/15 bg-black/60 p-3 text-center">
                <p className="text-[11px] font-bold text-white/50 uppercase">{cur.pinToShow}</p>
                <p className="text-4xl font-black tracking-widest text-[#FF6B00] mt-1">4829</p>
                <p className="text-[10px] text-white/40 mt-1">{cur.pinHint}</p>
              </div>

              {/* COD / Frais */}
              <div className="mt-3 flex items-center justify-between text-xs pt-2 border-t border-white/10">
                <span className="text-white/60">{cur.driverRewardLabel}</span>
                <span className="font-bold text-emerald-400">85,00 MAD</span>
              </div>

              <div className="mt-3 flex gap-2">
                <a
                  href="tel:+212661000001"
                  className="flex-1 rounded-xl bg-white/10 py-2 text-center text-xs font-bold text-white hover:bg-white/20"
                >
                  {cur.callHanoutBtn}
                </a>
                <button
                  onClick={() => {
                    setDriverCodCollected(!driverCodCollected);
                  }}
                  className={`flex-1 rounded-xl py-2 text-xs font-bold transition ${
                    driverCodCollected ? "bg-emerald-500 text-black" : "bg-white/10 text-white"
                  }`}
                >
                  {driverCodCollected ? cur.cashCollectedBtn : cur.collectCashBtn}
                </button>
              </div>
            </div>

            {/* Steps timeline */}
            <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-3 text-xs">
              <div className="flex items-center gap-2">
                <div className="h-2 w-2 rounded-full bg-emerald-400" />
                <span className="text-white/50">{cur.pickupDerbOmar}</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="h-2 w-2 rounded-full bg-[#FF6B00] animate-pulse" />
                <span className="font-bold text-white">{cur.deliverySoukAlHad}</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="h-2 w-2 rounded-full bg-white/20" />
                <span className="text-white/40">{cur.handshakePinStep}</span>
              </div>
            </div>
          </div>
        )}

        {driverTab === "marketplace" && (
          <div className="space-y-3">
            <div className="flex justify-between items-center">
              <h4 className="font-bold text-white text-xs">{cur.openOffersTitle}</h4>
              <span className="text-[10px] text-white/40">{cur.directDerbOmarDepots}</span>
            </div>

            {driverOpenJobs.map((job) => (
              <div key={job.id} className="rounded-2xl border border-white/10 bg-black/40 p-3.5 space-y-2 text-xs">
                <div className="flex justify-between items-start">
                  <div>
                    <span className="font-black text-[#FF6B00] text-[10px] uppercase">{cur.missionKourtia}</span>
                    <h5 className="font-bold text-white">
                      {lang === "ar" && job.fromAr ? job.fromAr : job.from} ➔ {lang === "ar" && job.toAr ? job.toAr : job.to}
                    </h5>
                    <p className="text-[11px] text-white/50">
                      📦 {lang === "ar" && job.packagesAr ? job.packagesAr : job.packages}
                    </p>
                  </div>
                  <div className="text-right">
                    <span className="text-[10px] text-white/40">{cur.benchmarkEst}</span>
                    <p className="font-extrabold text-emerald-400 text-sm">~{job.estFee} DH</p>
                  </div>
                </div>

                {driverBidSuccess === job.id ? (
                  <div className="rounded-xl bg-emerald-500/20 border border-emerald-500/40 p-2 text-center text-emerald-400 font-bold text-xs">
                    {cur.bidSubmittedSuccess}
                  </div>
                ) : (
                  <div className="pt-2 border-t border-white/5 flex gap-2">
                    <input
                      type="number"
                      placeholder={cur.yourRatePlaceholder}
                      value={driverBidInput[job.id] || ""}
                      onChange={(e) =>
                        setDriverBidInput({ ...driverBidInput, [job.id]: e.target.value })
                      }
                      className="h-8 w-24 rounded-lg border border-white/15 bg-white/5 px-2 text-center font-bold text-white text-xs"
                    />
                    <button
                      onClick={() => {
                        const val = driverBidInput[job.id];
                        if (val) {
                          setDriverBidSuccess(job.id);
                        }
                      }}
                      className="flex-1 rounded-lg bg-[#FF6B00] py-1.5 font-bold text-black text-xs hover:bg-[#ff8533]"
                    >
                      {cur.submitBidBtn}
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {driverTab === "profile" && (
          <div className="space-y-4 text-xs">
            <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-3">
              <div className="flex items-center gap-3">
                <div className="h-12 w-12 rounded-2xl bg-white/10 flex items-center justify-center text-xl font-black text-[#FF6B00]">
                  ح
                </div>
                <div>
                  <h4 className="font-extrabold text-white text-sm">Hassan El Kourti</h4>
                  <p className="text-white/40 text-[11px]">+212 6 98 00 00 01 • Casablanca</p>
                  <p className="text-[#FF6B00] font-bold text-[10px] mt-0.5">{cur.ratingDriver}</p>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2 pt-2 border-t border-white/5">
                <div className="rounded-xl bg-white/[0.02] p-2.5 border border-white/5">
                  <span className="text-[10px] text-white/40 block">{cur.toursCompleted}</span>
                  <span className="font-black text-white text-sm">142</span>
                </div>
                <div className="rounded-xl bg-white/[0.02] p-2.5 border border-white/5">
                  <span className="text-[10px] text-white/40 block">{cur.earningsDeposited}</span>
                  <span className="font-black text-emerald-400 text-sm">4 280 DH</span>
                </div>
              </div>
            </div>

            <div className="rounded-2xl border border-white/10 bg-black/40 p-4 space-y-2">
              <h5 className="font-bold text-white">{cur.vehicleLogistics}</h5>
              <p className="text-white/60">{cur.vehicleDesc}</p>
            </div>
          </div>
        )}
      </div>

      {/* Driver Navigation */}
      <div className="border-t border-white/10 pt-2 grid grid-cols-3 gap-1 text-[11px] font-bold text-center">
        <button
          onClick={() => setDriverTab("active")}
          className={`py-2 rounded-lg ${
            driverTab === "active" ? "bg-[#FF6B00] text-black" : "text-white/60 hover:text-white"
          }`}
        >
          {cur.navActiveTrip}
        </button>
        <button
          onClick={() => setDriverTab("marketplace")}
          className={`py-2 rounded-lg ${
            driverTab === "marketplace" ? "bg-[#FF6B00] text-black" : "text-white/60 hover:text-white"
          }`}
        >
          {cur.navMarketplace}
        </button>
        <button
          onClick={() => setDriverTab("profile")}
          className={`py-2 rounded-lg ${
            driverTab === "profile" ? "bg-[#FF6B00] text-black" : "text-white/60 hover:text-white"
          }`}
        >
          {cur.navDriverProfile}
        </button>
      </div>
    </div>
  );
}
