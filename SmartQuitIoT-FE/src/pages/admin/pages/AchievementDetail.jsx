// src/pages/admin/pages/AchievementDetail.jsx
import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { ArrowLeft, Award, Trophy, Target, CheckCircle } from "lucide-react";
import { getAchievementById } from "@/services/achievementService";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { toast } from "sonner";

const AchievementDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [achievement, setAchievement] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchAchievement = async () => {
      try {
        setLoading(true);
        const response = await getAchievementById(id);
        setAchievement(response.data || response);
      } catch (error) {
        console.error("Failed to fetch achievement:", error);
        toast.error("Failed to load achievement details");
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchAchievement();
    }
  }, [id]);

  const getTypeIcon = (type) => {
    switch (type) {
      case "STREAK":
        return <Trophy className="w-6 h-6" />;
      case "MILESTONE":
        return <Target className="w-6 h-6" />;
      case "CHALLENGE":
        return <Award className="w-6 h-6" />;
      default:
        return <CheckCircle className="w-6 h-6" />;
    }
  };

  const getTypeColor = (type) => {
    switch (type) {
      case "STREAK":
        return "bg-orange-100 text-orange-700 border-orange-200";
      case "MILESTONE":
        return "bg-blue-100 text-blue-700 border-blue-200";
      case "CHALLENGE":
        return "bg-purple-100 text-purple-700 border-purple-200";
      default:
        return "bg-gray-100 text-gray-700 border-gray-200";
    }
  };

  const formatCondition = (condition) => {
    if (!condition) return "No condition specified";
    
    const { field, operator, value } = condition;
    const operatorSymbol = {
      ">=": "≥",
      "<=": "≤",
      ">": ">",
      "<": "<",
      "==": "=",
      "!=": "≠"
    }[operator] || operator;

    const fieldName = field.charAt(0).toUpperCase() + field.slice(1).replace(/_/g, ' ');
    
    return `${fieldName} ${operatorSymbol} ${value}`;
  };

  if (loading) {
    return (
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-achievements", "loading"]} />
        <div className="animate-pulse space-y-6">
          <div className="h-8 bg-gray-200 rounded w-48"></div>
          <div className="bg-white rounded-xl shadow-sm border p-8 space-y-4">
            <div className="h-32 bg-gray-200 rounded-full w-32 mx-auto"></div>
            <div className="h-6 bg-gray-200 rounded w-3/4 mx-auto"></div>
            <div className="h-4 bg-gray-200 rounded w-1/2 mx-auto"></div>
          </div>
        </div>
      </div>
    );
  }

  if (!achievement) {
    return (
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-achievements", "not-found"]} />
        <div className="bg-white rounded-xl shadow-sm border p-8 text-center">
          <Award className="w-16 h-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-gray-900 mb-2">
            Achievement Not Found
          </h3>
          <p className="text-gray-600 mb-6">
            The achievement you're looking for doesn't exist or has been removed.
          </p>
          <button
            onClick={() => navigate("/admin/manage-achievements")}
            className="inline-flex items-center gap-2 px-6 py-3 bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
            Back to Achievements
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb 
        paths={["admin", "manage-achievements", achievement.name]} 
      />

      {/* Header */}
      <div className="flex items-center justify-between">
        <button
          onClick={() => navigate("/admin/manage-achievements")}
          className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
          <span className="font-medium">Back to Achievements</span>
        </button>
      </div>

      {/* Main Content */}
      <div className="grid gap-6">
        {/* Achievement Card */}
        <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
          {/* Hero Section with Icon */}
          <div className="bg-gradient-to-br from-emerald-500 to-teal-600 p-12 text-center relative overflow-hidden">
            <div className="absolute inset-0 bg-black/5 backdrop-blur-sm"></div>
            <div className="relative z-10">
              <div className="inline-flex items-center justify-center w-32 h-32 bg-white rounded-full shadow-xl mb-6 border-4 border-white/50">
                {achievement.icon ? (
                  <img
                    src={achievement.icon}
                    alt={achievement.name}
                    className="w-20 h-20 object-contain"
                  />
                ) : (
                  <Award className="w-16 h-16 text-emerald-600" />
                )}
              </div>
              <h1 className="text-4xl font-bold text-white mb-3">
                {achievement.name}
              </h1>
              <div className="flex items-center justify-center gap-2">
                <span className={`inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-semibold border-2 ${getTypeColor(achievement.type)}`}>
                  {getTypeIcon(achievement.type)}
                  {achievement.type}
                </span>
              </div>
            </div>
          </div>

          {/* Details Section */}
          <div className="p-8 space-y-8">
            {/* Description */}
            <div>
              <h3 className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-3">
                Description
              </h3>
              <p className="text-lg text-gray-700 leading-relaxed">
                {achievement.description}
              </p>
            </div>

            {/* Condition */}
            {achievement.condition && (
              <div className="border-t pt-8">
                <h3 className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-4">
                  Unlock Condition
                </h3>
                <div className="bg-gradient-to-r from-emerald-50 to-teal-50 rounded-xl p-6 border border-emerald-200">
                  <div className="flex items-start gap-4">
                    <div className="flex-shrink-0 w-12 h-12 bg-emerald-600 rounded-full flex items-center justify-center">
                      <Target className="w-6 h-6 text-white" />
                    </div>
                    <div className="flex-1">
                      <p className="text-lg font-semibold text-gray-900 mb-2">
                        {formatCondition(achievement.condition)}
                      </p>
                      <div className="grid grid-cols-3 gap-4 mt-4">
                        <div className="bg-white rounded-lg p-3 border">
                          <p className="text-xs text-gray-500 mb-1">Field</p>
                          <p className="text-sm font-semibold text-gray-900 capitalize">
                            {achievement.condition.field.replace(/_/g, ' ')}
                          </p>
                        </div>
                        <div className="bg-white rounded-lg p-3 border">
                          <p className="text-xs text-gray-500 mb-1">Operator</p>
                          <p className="text-sm font-semibold text-gray-900">
                            {achievement.condition.operator}
                          </p>
                        </div>
                        <div className="bg-white rounded-lg p-3 border">
                          <p className="text-xs text-gray-500 mb-1">Required Value</p>
                          <p className="text-sm font-semibold text-emerald-600">
                            {achievement.condition.value}
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Metadata */}
            <div className="border-t pt-8">
              <h3 className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-4">
                Additional Information
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="bg-gray-50 rounded-lg p-4 border">
                  <p className="text-xs text-gray-500 mb-1">Achievement ID</p>
                  <p className="text-lg font-semibold text-gray-900">#{achievement.id}</p>
                </div>
                <div className="bg-gray-50 rounded-lg p-4 border">
                  <p className="text-xs text-gray-500 mb-1">Type Category</p>
                  <p className="text-lg font-semibold text-gray-900">{achievement.type}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AchievementDetail;
