// src/pages/coach/CoachPage.jsx
import React, { useEffect, useState, useCallback } from "react";
import {
  Calendar,
  Clock,
  Users,
  CheckCircle2,
  MessageSquare,
  TrendingUp,
  AlertCircle,
  ArrowRight,
  CalendarDays,
  UserCheck,
  Activity,
} from "lucide-react";
import { useNavigate } from "react-router-dom";
import { getDashboardStatistics } from "@/services/statisticsService";
import useToast from "@/hooks/useToast";
import CircleLoading from "@/components/loadings/CircleLoading";

const CoachPage = () => {
  const navigate = useNavigate();
  const toast = useToast();
  const [loading, setLoading] = useState(true);
  const [statistics, setStatistics] = useState(null);

  const fetchDashboardStatistics = useCallback(async () => {
    setLoading(true);
    try {
      const response = await getDashboardStatistics();
      if (response?.status === 200) {
        // Unwrap GlobalResponse
        const data = response.data?.data || response.data;
        setStatistics(data);
      }
    } catch (error) {
      console.error("Failed to fetch dashboard statistics:", error);
      toast.error("Failed to load dashboard statistics. Please try again.");
    } finally {
      setLoading(false);
    }
  }, [toast]);

  useEffect(() => {
    fetchDashboardStatistics();
  }, [fetchDashboardStatistics]);

  // Calculate stats from API data
  const stats = statistics
    ? [
        {
          title: "Appointments Today",
          value: statistics.appointmentsToday || 0,
          icon: Calendar,
          color: "text-emerald-600",
          bgGradient:
            "bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50",
          iconBg: "bg-emerald-100",
          change:
            statistics.appointmentsYesterday !== undefined
              ? statistics.appointmentsToday > statistics.appointmentsYesterday
                ? `+${
                    statistics.appointmentsToday -
                    statistics.appointmentsYesterday
                  } from yesterday`
                : statistics.appointmentsToday <
                  statistics.appointmentsYesterday
                ? `${
                    statistics.appointmentsToday -
                    statistics.appointmentsYesterday
                  } from yesterday`
                : "Same as yesterday"
              : "",
        },
        {
          title: "Pending Appointments",
          value: statistics.pendingRequests || 0,
          icon: AlertCircle,
          color: "text-amber-600",
          bgGradient: "bg-gradient-to-br from-amber-50 to-orange-50",
          iconBg: "bg-amber-100",
          change:
            statistics.pendingRequests > 0 ? "Requires attention" : "All clear",
        },
        {
          title: "Completed This Week",
          value: statistics.completedThisWeek || 0,
          icon: CheckCircle2,
          color: "text-teal-600",
          bgGradient:
            "bg-gradient-to-br from-teal-50 via-cyan-50 to-emerald-50",
          iconBg: "bg-teal-100",
          change:
            statistics.completedLastWeek !== undefined
              ? statistics.completedThisWeek > statistics.completedLastWeek
                ? `+${
                    statistics.completedThisWeek - statistics.completedLastWeek
                  } from last week`
                : statistics.completedThisWeek < statistics.completedLastWeek
                ? `${
                    statistics.completedThisWeek - statistics.completedLastWeek
                  } from last week`
                : "Same as last week"
              : "",
        },
        {
          title: "Active Members",
          value: statistics.activeMembers || 0,
          icon: Users,
          color: "text-cyan-600",
          bgGradient:
            "bg-gradient-to-br from-cyan-50 via-teal-50 to-emerald-50",
          iconBg: "bg-cyan-100",
          change:
            statistics.newMembersThisMonth > 0
              ? `${statistics.newMembersThisMonth} new this month`
              : "No new members this month",
        },
      ]
    : [];

  // Map upcoming appointments from API - limit to 5 items
  const upcomingAppointments = (statistics?.upcomingAppointments || []).slice(
    0,
    5
  );

  const quickActions = [
    {
      label: "View Schedule",
      icon: CalendarDays,
      color: "from-emerald-500 to-teal-600",
      onClick: () => navigate("/coach/schedule"),
    },
    {
      label: "Appointments",
      icon: UserCheck,
      color: "from-teal-500 to-cyan-600",
      onClick: () => navigate("/coach/appointments"),
    },
    {
      label: "Member Management",
      icon: Users,
      color: "from-cyan-500 to-emerald-600",
      onClick: () => navigate("/coach/members"),
    },
    {
      label: "Messages",
      icon: MessageSquare,
      color: "from-emerald-500 to-teal-600",
      onClick: () => navigate("/coach/chat"),
    },
    {
      label: "Feedback",
      icon: Activity,
      color: "from-teal-500 to-cyan-600",
      onClick: () => navigate("/coach/feedback"),
    },
  ];

  // Helper function to get status badge class
  const getStatusBadgeClass = (status) => {
    const statusLower = status?.toLowerCase() || "";
    if (statusLower === "completed") {
      return "bg-emerald-100 text-emerald-700";
    } else if (statusLower === "pending") {
      return "bg-amber-100 text-amber-700";
    } else if (statusLower === "in_progress") {
      return "bg-blue-100 text-blue-700";
    } else if (statusLower === "cancelled") {
      return "bg-red-100 text-red-700";
    }
    return "bg-gray-100 text-gray-700";
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <CircleLoading />
      </div>
    );
  }

  return (
    <div className="px-10 py-6 min-h-screen scrollbar-hidden">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Dashboard</h1>
        <p className="text-gray-600">
          Welcome back! Here's what's happening today.
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat) => {
          const Icon = stat.icon;
          return (
            <div
              key={stat.title}
              className={`${stat.bgGradient} rounded-2xl p-6 border border-gray-100 shadow-sm hover:shadow-md transition-all duration-200`}
            >
              <div className="flex items-start justify-between mb-4">
                <div className={`${stat.iconBg} p-3 rounded-xl ${stat.color}`}>
                  <Icon className="w-6 h-6" />
                </div>
                <TrendingUp className="w-5 h-5 text-gray-400" />
              </div>
              <div className="space-y-1">
                <p className="text-3xl font-bold text-gray-900">{stat.value}</p>
                <p className="text-sm font-semibold text-gray-700">
                  {stat.title}
                </p>
                <p className="text-xs text-gray-500 mt-2">{stat.change}</p>
              </div>
            </div>
          );
        })}
      </div>

      {/* Main Content Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        {/* Upcoming Appointments - Takes 2 columns */}
        <div className="lg:col-span-2 bg-white rounded-2xl border border-gray-200 shadow-sm p-6">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-emerald-100 rounded-lg">
                <Calendar className="w-5 h-5 text-emerald-600" />
              </div>
              <div>
                <h2 className="text-lg font-semibold text-gray-900">
                  Upcoming Appointments
                </h2>
                <p className="text-sm text-gray-500">Today's schedule</p>
              </div>
            </div>
            <button
              onClick={() => navigate("/coach/appointments")}
              className="text-sm text-emerald-600 hover:text-emerald-700 font-medium flex items-center gap-1 transition-colors"
            >
              View all
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>

          {upcomingAppointments.length > 0 ? (
            <div className="space-y-3">
              {upcomingAppointments.map((apt) => (
                <div
                  key={apt.id}
                  className="flex items-center gap-4 p-4 rounded-xl border border-gray-100 hover:border-emerald-200 hover:bg-emerald-50/50 transition-all duration-200 cursor-pointer"
                  // onClick={() =>
                  //   navigate(`/coach/appointments/${apt.appointmentId}`)
                  // }
                >
                  <div className="flex-shrink-0">
                    {apt.memberAvatarUrl ? (
                      <img
                        src={apt.memberAvatarUrl}
                        alt={apt.memberName || "Member"}
                        className="w-12 h-12 rounded-full object-cover"
                      />
                    ) : (
                      <div className="w-12 h-12 rounded-full bg-gradient-to-br from-emerald-400 to-teal-500 flex items-center justify-center text-white font-semibold">
                        {apt.memberName?.charAt(0) || "M"}
                      </div>
                    )}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between mb-1">
                      <p className="font-semibold text-gray-900 truncate">
                        {apt.memberName || "Unknown Member"}
                      </p>
                      <span
                        className={`px-2 py-1 rounded-full text-xs font-medium capitalize ${getStatusBadgeClass(
                          apt.status
                        )}`}
                      >
                        {apt.status?.toLowerCase() || "unknown"}
                      </span>
                    </div>
                    <div className="flex items-center gap-3 text-sm text-gray-600">
                      <div className="flex items-center gap-1">
                        <Clock className="w-4 h-4" />
                        <span>{apt.time || "N/A"}</span>
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          ) : (
            <div className="text-center py-12">
              <Calendar className="w-16 h-16 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-500 font-medium">No appointments today</p>
              <p className="text-sm text-gray-400 mt-1">
                Your schedule is clear
              </p>
            </div>
          )}
        </div>

        {/* Quick Actions - Takes 1 column */}
        <div className="bg-white rounded-2xl border border-gray-200 shadow-sm p-6">
          <div className="flex items-center gap-3 mb-6">
            <div className="p-2 bg-teal-100 rounded-lg">
              <Activity className="w-5 h-5 text-teal-600" />
            </div>
            <div>
              <h2 className="text-lg font-semibold text-gray-900">
                Quick Actions
              </h2>
              <p className="text-sm text-gray-500">Common tasks</p>
            </div>
          </div>

          <div className="space-y-3">
            {quickActions.map((action) => {
              const Icon = action.icon;
              return (
                <button
                  key={action.label}
                  onClick={action.onClick}
                  className={`w-full p-4 rounded-xl bg-gradient-to-r ${action.color} text-white font-medium hover:shadow-lg transform hover:scale-[1.02] transition-all duration-200 flex items-center justify-between group`}
                >
                  <div className="flex items-center gap-3">
                    <Icon className="w-5 h-5" />
                    <span>{action.label}</span>
                  </div>
                  <ArrowRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
                </button>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
};

export default CoachPage;
