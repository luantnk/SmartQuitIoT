import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import CoachFeedback from "@/pages/admin/components/cards/CoachFeedback";
import { getCoachById } from "@/services/coachService";
import { formatDateTime } from "@/utils/formatDate";
import {
  Award,
  Ban,
  Briefcase,
  CheckCircle2,
  Clock,
  FileText,
  Mail,
  Shield,
  Star,
  TrendingUp,
  User,
  UserCircle,
  Users,
  XCircle,
} from "lucide-react";
import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { toast } from "sonner";

const CoachDetail = () => {
  const [coach, setCoach] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isViewFeedback, setIsViewFeedback] = useState(false);
  const { coachId } = useParams();
  const navigate = useNavigate();

  const fetchCoachDetail = async () => {
    try {
      setLoading(true);
      const response = await getCoachById(coachId);
      setCoach(response.data);
    } catch (error) {
      console.log(error);
      toast.error("Failed to fetch coach detail");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCoachDetail();
  }, [coachId]);

  const getStatusBadge = (isActive, isBanned) => {
    if (isBanned) {
      return <Badge className="bg-red-100 text-red-800">Banned</Badge>;
    }
    if (isActive) {
      return <Badge className="bg-green-100 text-green-800">Active</Badge>;
    }
    return <Badge className="bg-gray-100 text-gray-800">Inactive</Badge>;
  };

  const getRatingStars = (rating) => {
    return (
      <div className="flex items-center gap-1">
        {[1, 2, 3, 4, 5].map((star) => (
          <Star
            key={star}
            className={`h-4 w-4 ${
              star <= rating
                ? "fill-yellow-400 text-yellow-400"
                : "text-gray-300"
            }`}
          />
        ))}
        <span className="ml-2 text-sm font-medium">{rating.toFixed(1)}</span>
      </div>
    );
  };

  if (loading) {
    return (
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-coaches", coachId]} />
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading coach details...</p>
          </div>
        </div>
      </div>
    );
  }

  if (!coach) {
    return (
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-coaches", coachId]} />
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <XCircle className="h-12 w-12 text-red-500 mx-auto" />
            <p className="mt-4 text-gray-600">Coach not found</p>
          </div>
        </div>
      </div>
    );
  }

  const handleViewFeedbacks = () => {
    setIsViewFeedback(true);
  };

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-coaches", coachId]} />

      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
            Coach Details
          </h1>
          <p className="text-gray-600 mt-1">
            Complete information about {coach.firstName} {coach.lastName}
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => navigate(-1)}>
            Back
          </Button>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Profile Card */}
        <Card className="lg:col-span-1">
          <CardHeader>
            <CardTitle>Profile</CardTitle>
            <CardDescription>Coach profile information</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="flex flex-col items-center text-center">
              <Avatar className="h-32 w-32 mb-4">
                <AvatarImage
                  src={coach.avatarUrl}
                  alt={`${coach.firstName} ${coach.lastName}`}
                />
                <AvatarFallback className="text-2xl bg-primary text-primary-foreground">
                  {coach.firstName?.[0]}
                  {coach.lastName?.[0]}
                </AvatarFallback>
              </Avatar>
              <h3 className="text-xl font-semibold">
                {coach.firstName} {coach.lastName}
              </h3>
              <p className="text-sm text-gray-600 mt-1">ID: {coach.id}</p>
              <div className="mt-3">
                {getStatusBadge(
                  coach.account?.isActive,
                  coach.account?.isBanned
                )}
              </div>
            </div>

            <Separator />

            <div className="space-y-3">
              <div className="flex items-center gap-3 text-sm">
                <UserCircle className="h-4 w-4 text-gray-500" />
                <span className="text-gray-600">Gender:</span>
                <span className="font-medium">{coach.gender || "N/A"}</span>
              </div>
              <div className="flex items-center gap-3 text-sm">
                <Briefcase className="h-4 w-4 text-gray-500" />
                <span className="text-gray-600">Experience:</span>
                <span className="font-medium">
                  {coach.experienceYears} years
                </span>
              </div>
              <div className="flex items-center gap-3 text-sm">
                <Star className="h-4 w-4 text-gray-500" />
                <span className="text-gray-600">Rating:</span>
                <div className="font-medium">
                  {getRatingStars(coach.ratingAvg)}
                </div>
              </div>
              <div className="flex items-center gap-3 text-sm">
                <Users className="h-4 w-4 text-gray-500" />
                <span className="text-gray-600">Reviews:</span>
                <span className="font-medium">{coach.ratingCount} reviews</span>
              </div>
            </div>

            {coach.certificateUrl && (
              <>
                <Separator />
                <Button
                  variant="outline"
                  className="w-full justify-start gap-2"
                  onClick={() => window.open(coach.certificateUrl, "_blank")}
                >
                  <Award className="h-4 w-4" />
                  View Certificate
                </Button>
              </>
            )}
          </CardContent>
        </Card>

        {/* Account & Professional Information */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle>Account & Professional Information</CardTitle>
            <CardDescription>
              Login credentials and professional details
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {/* Account Information */}
            <div>
              <h3 className="text-lg font-semibold mb-4">
                Account Information
              </h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Username */}
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <User className="h-4 w-4" />
                    <span className="font-medium">Username</span>
                  </div>
                  <p className="text-base font-semibold pl-6">
                    {coach.account?.username}
                  </p>
                </div>

                {/* Email */}
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <Mail className="h-4 w-4" />
                    <span className="font-medium">Email</span>
                  </div>
                  <p className="text-base font-semibold pl-6">
                    {coach.account?.email}
                  </p>
                </div>

                {/* Role */}
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <Shield className="h-4 w-4" />
                    <span className="font-medium">Role</span>
                  </div>
                  <div className="pl-6">
                    <Badge
                      variant="outline"
                      className="bg-blue-50 text-blue-700 border-blue-200"
                    >
                      {coach.account?.role}
                    </Badge>
                  </div>
                </div>

                {/* Account Type */}
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <Shield className="h-4 w-4" />
                    <span className="font-medium">Account Type</span>
                  </div>
                  <div className="pl-6">
                    <Badge
                      variant="outline"
                      className="bg-purple-50 text-purple-700 border-purple-200"
                    >
                      {coach.account?.accountType}
                    </Badge>
                  </div>
                </div>

                {/* Created At */}
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <Clock className="h-4 w-4" />
                    <span className="font-medium">Created At</span>
                  </div>
                  <p className="text-sm pl-6">
                    {formatDateTime(coach.account?.createdAt)}
                  </p>
                </div>

                {/* Account Status */}
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <CheckCircle2 className="h-4 w-4" />
                    <span className="font-medium">Account Status</span>
                  </div>
                  <div className="pl-6 space-y-1">
                    <div className="flex items-center gap-2">
                      {coach.account?.isActive ? (
                        <CheckCircle2 className="h-4 w-4 text-green-600" />
                      ) : (
                        <XCircle className="h-4 w-4 text-gray-400" />
                      )}
                      <span className="text-sm">Active</span>
                    </div>
                    <div className="flex items-center gap-2">
                      {coach.account?.isBanned ? (
                        <Ban className="h-4 w-4 text-red-600" />
                      ) : (
                        <XCircle className="h-4 w-4 text-gray-400" />
                      )}
                      <span className="text-sm">Banned</span>
                    </div>
                    <div className="flex items-center gap-2">
                      {coach.account?.isFirstLogin ? (
                        <CheckCircle2 className="h-4 w-4 text-blue-600" />
                      ) : (
                        <XCircle className="h-4 w-4 text-gray-400" />
                      )}
                      <span className="text-sm">First Login</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <Separator />

            {/* Professional Information */}
            <div>
              <h3 className="text-lg font-semibold mb-4">
                Professional Information
              </h3>
              <div className="space-y-4">
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <FileText className="h-4 w-4" />
                    <span className="font-medium">Specializations</span>
                  </div>
                  <p className="text-sm pl-6 text-gray-700 whitespace-pre-wrap">
                    {coach.specializations || "No specializations listed"}
                  </p>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="p-4 bg-blue-50 rounded-lg">
                    <div className="flex items-center gap-2 mb-2">
                      <Briefcase className="h-4 w-4 text-blue-600" />
                      <span className="text-sm font-medium text-blue-900">
                        Experience
                      </span>
                    </div>
                    <p className="text-2xl font-bold text-blue-700">
                      {coach.experienceYears} years
                    </p>
                  </div>

                  <div className="p-4 bg-yellow-50 rounded-lg">
                    <div className="flex items-center gap-2 mb-2">
                      <Star className="h-4 w-4 text-yellow-600" />
                      <span className="text-sm font-medium text-yellow-900">
                        Rating
                      </span>
                    </div>
                    <p className="text-2xl font-bold text-yellow-700">
                      {coach.ratingAvg.toFixed(1)} / 5.0
                    </p>
                  </div>

                  <div className="p-4 bg-green-50 rounded-lg">
                    <div className="flex items-center gap-2 mb-2">
                      <Users className="h-4 w-4 text-green-600" />
                      <span className="text-sm font-medium text-green-900">
                        Reviews
                      </span>
                    </div>
                    <p className="text-2xl font-bold text-green-700">
                      {coach.ratingCount}
                    </p>
                  </div>
                </div>
              </div>
            </div>

            <Separator />

            {/* Action Buttons */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {/* <Button
                variant="outline"
                className="justify-start gap-2 border-blue-200 hover:bg-blue-50 hover:text-blue-700 hover:border-blue-300"
              >
                <Users className="h-4 w-4" />
                View Assigned Members
              </Button>
              <Button
                variant="outline"
                className="justify-start gap-2 border-purple-200 hover:bg-purple-50 hover:text-purple-700 hover:border-purple-300"
              >
                <MessageSquare className="h-4 w-4" />
                View Conversations
              </Button>
              <Button
                variant="outline"
                className="justify-start gap-2 border-emerald-200 hover:bg-emerald-50 hover:text-emerald-700 hover:border-emerald-300"
              >
                <BarChart3 className="h-4 w-4" />
                View Performance Stats
              </Button> */}
              <Button
                variant="outline"
                className="justify-start gap-2 border-orange-200 hover:bg-orange-50 hover:text-orange-700 hover:border-orange-300"
                onClick={handleViewFeedbacks}
                disabled={isViewFeedback}
              >
                <TrendingUp className="h-4 w-4" />
                View Feedbacks & Ratings
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
      <div className="">
        {isViewFeedback && <CoachFeedback coachId={coach.id} />}
      </div>
    </div>
  );
};

export default CoachDetail;
