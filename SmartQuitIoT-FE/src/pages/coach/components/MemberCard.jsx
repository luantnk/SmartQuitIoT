// src/pages/coach/components/MemberCard.jsx
import React from "react";
import { MessageSquare, TrendingUp, Flame, User, Eye } from "lucide-react";

function ageFromDob(dob) {
  if (!dob) return "-";
  const b = new Date(dob);
  const diff = new Date() - b;
  return Math.floor(diff / (1000 * 60 * 60 * 24 * 365.25));
}

function MemberCard({ member, onOpenDetails, onOpenInbox }) {
  const fullName = `${member.firstName ?? ""} ${member.lastName ?? ""}`.trim();
  const age = ageFromDob(member.dob);
  const smokeFreePct = member.metric?.smokeFreeDayPercentage ?? 0;
  const reductionPct = member.metric?.reductionPercentage ?? 0;
  const streaks = member.metric?.streaks ?? 0;
  const hasAvatar = member.avatarUrl && member.avatarUrl.trim() !== "";

  return (
    <div className="bg-white rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300 overflow-hidden border border-gray-100 group">
      {/* Header với gradient subtle */}
      <div className="bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50 p-5 relative overflow-hidden">
        {/* Decorative background pattern */}
        <div className="absolute inset-0 opacity-5">
          <div className="absolute top-0 right-0 w-32 h-32 bg-emerald-400 rounded-full blur-3xl"></div>
          <div className="absolute bottom-0 left-0 w-24 h-24 bg-teal-400 rounded-full blur-2xl"></div>
        </div>

        <div className="relative flex items-start gap-4">
          {/* Avatar với ring effect */}
          <div className="relative flex-shrink-0">
            <div className="absolute inset-0 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full blur-sm opacity-30 group-hover:opacity-50 transition-opacity"></div>
            {hasAvatar ? (
              <img
                src={member.avatarUrl}
                alt={fullName}
                className="relative w-16 h-16 rounded-full object-cover ring-2 ring-white shadow-md"
                onError={(e) => {
                  e.target.style.display = 'none';
                  e.target.nextSibling.style.display = 'flex';
                }}
              />
            ) : null}
            <div 
              className={`relative w-16 h-16 rounded-full bg-gradient-to-br from-emerald-400 to-teal-500 ring-2 ring-white shadow-md flex items-center justify-center ${hasAvatar ? 'hidden' : 'flex'}`}
            >
              <User className="w-8 h-8 text-white" />
            </div>
          </div>

          <div className="flex-1 min-w-0">
            <h3 className="font-semibold text-gray-900 text-lg truncate group-hover:text-emerald-700 transition-colors">
              {fullName || "Unknown Member"}
            </h3>
            <div className="flex items-center gap-2 mt-1.5 flex-wrap">
              <span className="text-sm text-gray-600 font-medium">
                {age !== "-" ? `${age} years old` : "Age unknown"}
              </span>
              <span className="text-gray-300">•</span>
              <span
                className={`text-xs px-2.5 py-1 rounded-full font-semibold transition-colors ${
                  member.isUsedFreeTrial
                    ? "bg-amber-100 text-amber-700 border border-amber-200"
                    : "bg-emerald-100 text-emerald-700 border border-emerald-200"
                }`}
              >
                {member.isUsedFreeTrial ? "Free Trial" : "Member"}
              </span>
            </div>
          </div>

          {/* Streak badge */}
          {streaks > 0 && (
            <div className="flex flex-col items-center bg-white/80 backdrop-blur-sm rounded-xl px-3 py-2 shadow-sm border border-orange-100 group-hover:scale-105 transition-transform">
              <div className="flex items-center gap-1.5 text-orange-500">
                <Flame size={18} fill="currentColor" className="drop-shadow-sm" />
                <span className="font-bold text-lg">{streaks}</span>
              </div>
              <span className="text-xs text-gray-600 font-medium mt-0.5">
                {streaks === 1 ? "day" : "days"}
              </span>
            </div>
          )}
        </div>
      </div>

      {/* Metrics */}
      <div className="p-5 bg-gray-50/50">
        <div className="grid grid-cols-2 gap-3">
          {/* Smoke-free metric */}
          <div className="relative group/metric">
            <div className="absolute inset-0 bg-gradient-to-br from-emerald-500 to-teal-600 rounded-xl opacity-0 group-hover/metric:opacity-10 transition-opacity duration-300"></div>
            <div className="relative bg-white rounded-xl p-4 border border-gray-200 group-hover/metric:border-emerald-300 transition-colors shadow-sm">
              <div className="flex items-center gap-2 mb-2.5">
                <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-emerald-100 to-emerald-200 flex items-center justify-center shadow-sm">
                  <span className="text-xl">🚭</span>
                </div>
                <span className="text-xs text-gray-600 font-semibold uppercase tracking-wide">
                  Smoke-Free
                </span>
              </div>
              <div className="text-2xl font-bold text-gray-900 flex items-baseline gap-1">
                {smokeFreePct.toFixed(1)}
                <span className="text-base text-emerald-600 font-semibold">%</span>
              </div>
            </div>
          </div>

          {/* Reduction metric */}
          <div className="relative group/metric">
            <div className="absolute inset-0 bg-gradient-to-br from-teal-500 to-emerald-600 rounded-xl opacity-0 group-hover/metric:opacity-10 transition-opacity duration-300"></div>
            <div className="relative bg-white rounded-xl p-4 border border-gray-200 group-hover/metric:border-teal-300 transition-colors shadow-sm">
              <div className="flex items-center gap-2 mb-2.5">
                <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-teal-100 to-teal-200 flex items-center justify-center shadow-sm">
                  <TrendingUp size={18} className="text-teal-600" strokeWidth={2.5} />
                </div>
                <span className="text-xs text-gray-600 font-semibold uppercase tracking-wide">
                  Reduction
                </span>
              </div>
              <div className="text-2xl font-bold text-gray-900 flex items-baseline gap-1">
                {reductionPct.toFixed(1)}
                <span className="text-base text-teal-600 font-semibold">%</span>
              </div>
            </div>
          </div>
        </div>

        {/* Action buttons */}
        <div className="flex gap-3 mt-5">
          <button
            onClick={onOpenInbox}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl border-2 border-gray-200 text-gray-700 font-semibold text-sm hover:border-emerald-400 hover:bg-emerald-50 hover:text-emerald-700 transition-all duration-200 shadow-sm hover:shadow-md active:scale-[0.98]"
          >
            <MessageSquare size={18} strokeWidth={2} />
            <span>Message</span>
          </button>

          <button
            onClick={() => onOpenDetails("metric")}
            className="flex-1 flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-600 text-white font-semibold text-sm hover:from-emerald-600 hover:to-teal-700 shadow-md hover:shadow-lg transition-all duration-200 active:scale-[0.98]"
          >
            <Eye size={18} strokeWidth={2} />
            <span>Details</span>
          </button>
        </div>
      </div>
    </div>
  );
}

export default MemberCard;
