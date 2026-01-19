// src/pages/MemberManagementPage.jsx
import React, { useEffect, useState, useRef } from "react";
import MemberCard from "../../pages/coach/components/MemberCard";
import MemberDetailsModal from "../../pages/coach/components/MemberDetailsModal";
import { getMembersForCoach, getMemberById } from "@/services/memberService";
import { postMessage } from "@/services/conversationService";
import { useNavigate, useSearchParams } from "react-router-dom";
import { AlertCircle, User } from "lucide-react";
import Paginator from "@/components/ui/paginator";

export default function MemberManagementPage() {
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Pagination state
  const [page, setPage] = useState(0);
  const size = 6;
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);

  const [selectedMember, setSelectedMember] = useState(null);
  const [detailsTab, setDetailsTab] = useState("metric");
  const abortRef = useRef(null);
  const allMembersCacheRef = useRef(null);

  // ===== 🔍 SEARCH STATE (NEW) =====
  const [keyword, setKeyword] = useState("");

  // ===== 🔍 SEARCH FILTER (NEW) =====
  function filterMembers(list, keyword) {
    if (!keyword) return list;
    const q = keyword.toLowerCase();

    return list.filter((m) => {
      const fullName = `${m.firstName || ""} ${m.lastName || ""}`.toLowerCase();
      return (
        fullName.includes(q) ||
        m.email?.toLowerCase().includes(q) ||
        m.phone?.includes(q)
      );
    });
  }

  useEffect(() => {
    if (
      allMembersCacheRef.current &&
      Array.isArray(allMembersCacheRef.current)
    ) {
      const filtered = filterMembers(allMembersCacheRef.current, keyword);

      const total = filtered.length;
      const pages = Math.ceil(total / size);
      const startIndex = page * size;
      const endIndex = startIndex + size;

      setMembers(filtered.slice(startIndex, endIndex));
      setTotalPages(pages);
      setTotalElements(total);
      setLoading(false);
    } else {
      loadList();
    }

    const currentAbortRef = abortRef.current;
    return () => {
      if (currentAbortRef && currentAbortRef.abort) currentAbortRef.abort();
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page, size, keyword]);

  async function loadList() {
    setLoading(true);
    setError(null);
    try {
      const resp = await getMembersForCoach({ page, size });
      const payload = resp && resp.data ? resp.data : resp;

      let list = [];
      let pages = 0;
      let total = 0;
      let isServerSidePagination = false;

      if (Array.isArray(payload)) {
        const allMembers = payload.map(normalizeApiMemberToView);
        allMembersCacheRef.current = allMembers;

        const filtered = filterMembers(allMembers, keyword);
        total = filtered.length;
        pages = Math.ceil(total / size);

        const startIndex = page * size;
        const endIndex = startIndex + size;
        list = filtered.slice(startIndex, endIndex);
      } else if (payload?.content) {
        allMembersCacheRef.current = null;
        list = payload.content || [];
        pages = payload.totalPages || 0;
        total = payload.totalElements || list.length;
        isServerSidePagination = true;
      } else if (payload?.data?.content) {
        allMembersCacheRef.current = null;
        list = payload.data.content || [];
        pages = payload.data.totalPages || 0;
        total = payload.data.totalElements || list.length;
        isServerSidePagination = true;
      }

      const mapped = isServerSidePagination
        ? list.map(normalizeApiMemberToView)
        : list;

      setMembers(mapped);
      setTotalPages(pages);
      setTotalElements(total);
    } catch (err) {
      allMembersCacheRef.current = null;
      setError(
        err?.response?.data?.message ||
          err?.message ||
          "Failed to load members list."
      );
      setMembers([]);
      setTotalPages(0);
      setTotalElements(0);
    } finally {
      setLoading(false);
    }
  }

  function normalizeApiMemberToView(api) {
    const isUsedFreeTrial = api.isUsedFreeTrial ?? api.usedFreeTrial ?? false;

    const metric =
      api.metric ||
      (api.streaks !== undefined ||
      api.smokeFreeDayPercentage !== undefined ||
      api.reductionPercentage !== undefined
        ? {
            streaks: api.streaks ?? 0,
            smokeFreeDayPercentage: api.smokeFreeDayPercentage ?? 0,
            reductionPercentage: api.reductionPercentage ?? 0,
          }
        : null);

    return {
      ...api,
      id: api.id,
      firstName: api.firstName,
      lastName: api.lastName,
      avatarUrl: api.avatarUrl,
      dob: api.dob,
      isUsedFreeTrial,
      metric,
      usedFreeTrial: isUsedFreeTrial,
    };
  }

  async function handleOpenDetails(memberId, initialTab = "metric") {
    setDetailsTab(initialTab);
    setSelectedMember(null);
    try {
      const resp = await getMemberById(memberId);
      const payload = resp && resp.data ? resp.data : resp;
      setSelectedMember(normalizeApiMemberToView(payload));
    } catch (err) {
      setError(
        err?.response?.data?.message ||
          err?.message ||
          "Failed to load member details."
      );
    }
  }

  useEffect(() => {
    const memberId = searchParams.get("memberId");
    if (memberId && !selectedMember) {
      handleOpenDetails(memberId, "metric");
      setSearchParams({});
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [searchParams]);

  async function openInboxForMember(member) {
    try {
      const clientMessageId = crypto?.randomUUID?.() || `cmsg-${Date.now()}`;

      const payload = {
        targetMemberId: member.id,
        content: "Hello! I'd like to start a conversation.",
        messageType: "TEXT",
        clientMessageId,
      };

      const resp = await postMessage(payload);
      const body = resp?.data || resp;
      const message = body?.data || body;
      const conversationId = message?.conversationId;

      navigate(
        conversationId
          ? `/coach/chat?conversationId=${conversationId}`
          : "/coach/chat"
      );
    } catch {
      alert("Failed to open inbox.");
    }
  }

  return (
    <div className="px-10 min-h-screen scrollbar-hidden">
      <header className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-semibold text-gray-900">
            Member Management
          </h1>
          <p className="text-sm text-gray-600 mt-1">
            Manage and track your members' progress
          </p>
        </div>
      </header>

      {/* 🔍 SEARCH BAR */}
      <div className="mb-6 flex items-center gap-3">
        <input
          value={keyword}
          onChange={(e) => {
            setKeyword(e.target.value);
            setPage(0);
          }}
          placeholder="Search by name..."
          className="w-full max-w-sm rounded-xl border border-gray-300 px-4 py-2 text-sm
                     focus:outline-none focus:ring-2 focus:ring-indigo-500"
        />
        {keyword && (
          <button
            onClick={() => {
              setKeyword("");
              setPage(0);
            }}
            className="text-sm text-gray-500 hover:text-gray-800"
          >
            Clear
          </button>
        )}
      </div>

      {error && (
        <div className="mb-4 p-4 rounded-lg bg-amber-50 text-amber-800 border">
          <AlertCircle className="inline w-5 h-5 mr-2" />
          {error}
        </div>
      )}

      <div className="grid gap-4 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
        {loading ? (
          Array.from({ length: size }).map((_, i) => (
            <div
              key={i}
              className="animate-pulse bg-white p-6 rounded-2xl h-64 border"
            />
          ))
        ) : members.length ? (
          members.map((m) => (
            <MemberCard
              key={m.id}
              member={m}
              onOpenDetails={(tab) => handleOpenDetails(m.id, tab)}
              onOpenInbox={() => openInboxForMember(m)}
            />
          ))
        ) : (
          <div className="col-span-full text-center py-16">
            <User className="w-8 h-8 mx-auto text-gray-400 mb-2" />
            <p className="font-semibold">No members found</p>
          </div>
        )}
      </div>

      {!loading && totalPages > 1 && (
        <div className="mt-6">
          <Paginator
            currentPage={page}
            totalPages={totalPages}
            onPageChange={(p) => {
              setPage(p);
              window.scrollTo({ top: 0, behavior: "smooth" });
            }}
          />
        </div>
      )}

      {!loading && totalElements > 0 && (
        <div className="mt-4 text-center text-sm text-gray-600">
          Showing {members.length} of {totalElements} members
        </div>
      )}

      <MemberDetailsModal
        member={selectedMember}
        open={!!selectedMember}
        onClose={() => setSelectedMember(null)}
        initialTab={detailsTab}
      />
    </div>
  );
}
