import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { ArrowLeft, Award, Calendar, Info } from "lucide-react";
import { getMissionById } from "@/services/missionService";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { toast } from "sonner";

const MissionDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [mission, setMission] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchMission = async () => {
      try {
        setLoading(true);
        const response = await getMissionById(id);
        const missionData = response.data || response;
        
        // Parse condition if it's a JSON string
        if (missionData.condition && typeof missionData.condition === 'string') {
          missionData.condition = JSON.parse(missionData.condition);
        }
        
        setMission(missionData);
      } catch (error) {
        console.error("Failed to fetch mission:", error);
        toast.error("Failed to load mission details");
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchMission();
    }
  }, [id]);

  const getPhaseColor = (phase) => {
    switch (phase) {
      case "PREPARATION":
        return "bg-blue-100 text-blue-700";
      case "ONSET":
        return "bg-green-100 text-green-700";
      case "PEAK_CRAVING":
        return "bg-red-100 text-red-700";
      case "SUBSIDING":
        return "bg-purple-100 text-purple-700";
      case "MAINTENANCE":
        return "bg-yellow-100 text-yellow-700";
      default:
        return "bg-gray-100 text-gray-700";
    }
  };

  const getStatusColor = (status) => {
    return status === "ACTIVE"
      ? "bg-green-100 text-green-700"
      : "bg-gray-100 text-gray-700";
  };

  const formatDate = (dateString) => {
    if (!dateString) return "—";
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const formatCondition = (condition) => {
    if (!condition) return null;
    
    // Handle new condition format with logic and rules
    if (condition.logic && condition.rules) {
      const formatRules = (rules, level = 0) => {
        return rules.map((rule, index) => {
          const indent = '  '.repeat(level);
          
          // If rule has nested rules
          if (rule.logic && rule.rules) {
            return (
              <div key={index} className="ml-4">
                <div className="font-semibold text-blue-600">{rule.logic}:</div>
                {formatRules(rule.rules, level + 1)}
              </div>
            );
          }
          
          // Simple rule
          return (
            <div key={index} className="ml-4">
              <span className="font-mono text-sm">
                {rule.field} {rule.operator} {String(rule.value)}
              </span>
            </div>
          );
        });
      };
      
      return (
        <div className="space-y-1">
          <div className="font-semibold text-blue-600 mb-2">{condition.logic}:</div>
          {formatRules(condition.rules)}
        </div>
      );
    }
    
    // Handle old simple condition format
    const { field, operator, value } = condition;
    return `${field} ${operator} ${value}`;
  };

  if (loading) {
    return (
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-missions", "loading"]} />
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-48"></div>
          <div className="bg-white rounded-xl shadow-sm border p-8 space-y-4">
            <div className="h-32 bg-gray-200 rounded w-full"></div>
            <div className="h-6 bg-gray-200 rounded w-3/4"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!mission) {
    return (
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-missions", "not-found"]} />
        <Card>
          <CardContent className="p-8 text-center">
            <Info className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-gray-900 mb-2">
              Mission Not Found
            </h3>
            <p className="text-gray-600 mb-6">
              The mission you're looking for doesn't exist or has been removed.
            </p>
            <button
              onClick={() => navigate("/admin/manage-missions")}
              className="inline-flex items-center gap-2 px-6 py-3 bg-gray-900 text-white rounded-lg hover:bg-gray-800 transition-colors"
            >
              <ArrowLeft className="w-5 h-5" />
              Back to Missions
            </button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-missions", mission.name]} />

      {/* Header */}
      <div className="flex items-center justify-between">
        <button
          onClick={() => navigate("/admin/manage-missions")}
          className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
          <span className="font-medium">Back to Missions</span>
        </button>
      </div>

      {/* Main Content */}
      <div className="grid gap-6">
        {/* Basic Information Card */}
        <Card>
          <CardHeader>
            <CardTitle className="text-2xl">{mission.name}</CardTitle>
            <p className="text-gray-600 mt-2">{mission.description || "—"}</p>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Key Info Grid */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <div>
                <p className="text-sm text-gray-600 mb-1">Mission ID</p>
                <p className="font-semibold">#{mission.id}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Code</p>
                <p className="font-mono text-sm">{mission.code}</p>
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Experience</p>
                <div className="flex items-center gap-1">
                  <Award className="w-4 h-4 text-amber-600" />
                  <span className="font-semibold">{mission.exp} EXP</span>
                </div>
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Status</p>
                <Badge className={getStatusColor(mission.status)}>
                  {mission.status}
                </Badge>
              </div>
            </div>

            {/* Phase & Condition */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4 border-t">
              <div>
                <p className="text-sm text-gray-600 mb-2">Phase</p>
                <Badge className={getPhaseColor(mission.phase)}>
                  {mission.phase}
                </Badge>
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-2">Condition</p>
                {mission.condition ? (
                  <div className="bg-gray-100 px-4 py-3 rounded-lg">
                    {formatCondition(mission.condition)}
                  </div>
                ) : (
                  <span className="text-gray-400">—</span>
                )}
              </div>
            </div>

            {/* Mission Type */}
            {mission.missionType && (
              <div className="pt-4 border-t">
                <p className="text-sm text-gray-600 mb-2">Mission Type</p>
                <div className="bg-gray-50 rounded-lg p-4">
                  <p className="font-semibold text-gray-900 mb-1">
                    {mission.missionType.name}
                  </p>
                  <p className="text-sm text-gray-600">
                    {mission.missionType.description || "—"}
                  </p>
                </div>
              </div>
            )}

            {/* Interest Category */}
            <div className="pt-4 border-t">
              <p className="text-sm text-gray-600 mb-2">Interest Category</p>
              {mission.interestCategory ? (
                <div className="bg-gray-50 rounded-lg p-4">
                  <p className="font-semibold text-gray-900 mb-1">
                    {mission.interestCategory.name}
                  </p>
                  {mission.interestCategory.description && (
                    <p className="text-sm text-gray-600">
                      {mission.interestCategory.description}
                    </p>
                  )}
                </div>
              ) : (
                <div className="bg-blue-50 rounded-lg p-4">
                  <p className="text-sm text-blue-900 font-medium">
                    All Interests (No specific category)
                  </p>
                </div>
              )}
            </div>

            {/* Timestamps */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pt-4 border-t">
              <div>
                <p className="text-sm text-gray-600 mb-1">Created At</p>
                <div className="flex items-center gap-2 text-sm">
                  <Calendar className="w-4 h-4 text-gray-400" />
                  <span>{formatDate(mission.createdAt)}</span>
                </div>
              </div>
              <div>
                <p className="text-sm text-gray-600 mb-1">Updated At</p>
                <div className="flex items-center gap-2 text-sm">
                  <Calendar className="w-4 h-4 text-gray-400" />
                  <span>{formatDate(mission.updatedAt)}</span>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
};

export default MissionDetail;
