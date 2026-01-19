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
import MemberCurrentPlanModal from "@/components/ui/modals/member-current-plan-modal";
import MemberHealthModal from "@/components/ui/modals/member-health-modal";
import MemberSubscriptionModal from "@/components/ui/modals/member-subscription-modal";
import { Separator } from "@/components/ui/separator";
import { getMemberById } from "@/services/memberService";
import {
  Activity,
  Ban,
  BookOpen,
  Cake,
  Calendar,
  CheckCircle2,
  Clock,
  CreditCard,
  Mail,
  Shield,
  Target,
  User,
  UserCheck,
  UserCircle,
  XCircle,
} from "lucide-react";
import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { toast } from "sonner";

const MemberDetail = () => {
  const [member, setMember] = useState(null);
  const [loading, setLoading] = useState(true);
  const { memberId } = useParams();
  const [healthOpen, setHealthOpen] = useState(false);
  const [currentPlanOpen, setCurrentPlanOpen] = useState(false);
  const [subscriptionOpen, setSubscriptionOpen] = useState(false);
  const navigate = useNavigate();

  const fetchMemberDetail = async () => {
    try {
      setLoading(true);
      const response = await getMemberById(memberId);
      setMember(response.data);
    } catch (error) {
      console.log(error);
      toast.error("Failed to fetch member detail");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMemberDetail();
  }, [memberId]);

  const formatDate = (dateString) => {
    if (!dateString) return "N/A";
    return new Date(dateString).toLocaleDateString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  const formatDateTime = (dateString) => {
    if (!dateString) return "N/A";
    return new Date(dateString).toLocaleString("en-US", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const getStatusBadge = (isActive, isBanned) => {
    if (isBanned) {
      return <Badge className="bg-red-100 text-red-800">Banned</Badge>;
    }
    if (isActive) {
      return <Badge className="bg-green-100 text-green-800">Active</Badge>;
    }
    return <Badge className="bg-gray-100 text-gray-800">Inactive</Badge>;
  };

  const handleViewHealthData = () => {
    setHealthOpen(true);
  };

  const handleViewCurrentQuitPlan = () => {
    setCurrentPlanOpen(true);
  };

  const handleViewDiaryRecord = () => {
    navigate(`/admin/manage-members/diary/${memberId}`);
  };

  const handleViewSubscriptions = () => {
    setSubscriptionOpen(true);
  };

  if (loading) {
    return (
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-members", memberId]} />
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto"></div>
            <p className="mt-4 text-gray-600">Loading member details...</p>
          </div>
        </div>
      </div>
    );
  }

  if (!member) {
    return (
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-members", memberId]} />
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <XCircle className="h-12 w-12 text-red-500 mx-auto" />
            <p className="mt-4 text-gray-600">Member not found</p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <>
      {healthOpen && (
        <MemberHealthModal
          memberId={memberId}
          isOpen={healthOpen}
          onOpenChange={setHealthOpen}
        />
      )}
      {currentPlanOpen && (
        <MemberCurrentPlanModal
          memberId={memberId}
          isOpen={currentPlanOpen}
          onOpenChange={setCurrentPlanOpen}
        />
      )}
      {subscriptionOpen && (
        <MemberSubscriptionModal
          memberId={memberId}
          isOpen={subscriptionOpen}
          onOpenChange={setSubscriptionOpen}
        />
      )}
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-members", memberId]} />

        {/* Header */}
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
              Member Detail - {member.firstName} {member.lastName}
            </h1>
            <p className="text-gray-600 mt-1">
              Complete information about {member.firstName} {member.lastName}
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
              <CardDescription>Member profile information</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              <div className="flex flex-col items-center text-center">
                <Avatar className="h-32 w-32 mb-4">
                  <AvatarImage
                    src={member.avatarUrl}
                    alt={`${member.firstName} ${member.lastName}`}
                  />
                  <AvatarFallback className="text-2xl bg-primary text-primary-foreground">
                    {member.firstName?.[0]}
                    {member.lastName?.[0]}
                  </AvatarFallback>
                </Avatar>
                <h3 className="text-xl font-semibold">
                  {member.firstName} {member.lastName}
                </h3>
                <p className="text-sm text-gray-600 mt-1">ID: {member.id}</p>
                <div className="mt-3">
                  {getStatusBadge(
                    member.account?.isActive,
                    member.account?.isBanned
                  )}
                </div>
              </div>

              <Separator />

              <div className="space-y-3">
                <div className="flex items-center gap-3 text-sm">
                  <UserCircle className="h-4 w-4 text-gray-500" />
                  <span className="text-gray-600">Gender:</span>
                  <span className="font-medium">{member.gender || "N/A"}</span>
                </div>
                <div className="flex items-center gap-3 text-sm">
                  <Cake className="h-4 w-4 text-gray-500" />
                  <span className="text-gray-600">Date of Birth:</span>
                  <span className="font-medium">{formatDate(member.dob)}</span>
                </div>
                <div className="flex items-center gap-3 text-sm">
                  <Calendar className="h-4 w-4 text-gray-500" />
                  <span className="text-gray-600">Age:</span>
                  <span className="font-medium">{member.age} years old</span>
                </div>
                <div className="flex items-center gap-3 text-sm">
                  <UserCheck className="h-4 w-4 text-gray-500" />
                  <span className="text-gray-600">Free Trial:</span>
                  <span className="font-medium">
                    {member.usedFreeTrial ? "Used" : "Not Used"}
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Account Information */}
          <Card className="lg:col-span-2">
            <CardHeader>
              <CardTitle>Account Information</CardTitle>
              <CardDescription>
                Login credentials and account status
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Username */}
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <User className="h-4 w-4" />
                    <span className="font-medium">Username</span>
                  </div>
                  <p className="text-base font-semibold pl-6">
                    {member.account?.username}
                  </p>
                </div>

                {/* Email */}
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-gray-600">
                    <Mail className="h-4 w-4" />
                    <span className="font-medium">Email</span>
                  </div>
                  <p className="text-base font-semibold pl-6">
                    {member.account?.email}
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
                      {member.account?.role}
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
                      {member.account?.accountType}
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
                    {formatDateTime(member.account?.createdAt)}
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
                      {member.account?.isActive ? (
                        <CheckCircle2 className="h-4 w-4 text-green-600" />
                      ) : (
                        <XCircle className="h-4 w-4 text-gray-400" />
                      )}
                      <span className="text-sm">Active</span>
                    </div>
                    <div className="flex items-center gap-2">
                      {member.account?.isBanned ? (
                        <Ban className="h-4 w-4 text-red-600" />
                      ) : (
                        <XCircle className="h-4 w-4 text-gray-400" />
                      )}
                      <span className="text-sm">Banned</span>
                    </div>
                    <div className="flex items-center gap-2">
                      {member.account?.isFirstLogin ? (
                        <CheckCircle2 className="h-4 w-4 text-blue-600" />
                      ) : (
                        <XCircle className="h-4 w-4 text-gray-400" />
                      )}
                      <span className="text-sm">First Login</span>
                    </div>
                  </div>
                </div>
              </div>

              <Separator className="my-6" />

              {/* Actions */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                <Button
                  variant="outline"
                  className="justify-start gap-2 border-blue-200 hover:bg-blue-50 hover:text-blue-700 hover:border-blue-300"
                  onClick={handleViewHealthData}
                >
                  <Activity className="h-4 w-4" />
                  View Health Data
                </Button>
                <Button
                  variant="outline"
                  className="justify-start gap-2 border-purple-200 hover:bg-purple-50 hover:text-purple-700 hover:border-purple-300"
                  onClick={handleViewDiaryRecord}
                >
                  <BookOpen className="h-4 w-4" />
                  View Diary Records
                </Button>
                <Button
                  variant="outline"
                  className="justify-start gap-2 border-emerald-200 hover:bg-emerald-50 hover:text-emerald-700 hover:border-emerald-300"
                  onClick={handleViewCurrentQuitPlan}
                >
                  <Target className="h-4 w-4" />
                  View Current Quit Plan
                </Button>
                <Button
                  variant="outline"
                  className="justify-start gap-2 border-orange-200 hover:bg-orange-50 hover:text-orange-700 hover:border-orange-300"
                  onClick={handleViewSubscriptions}
                >
                  <CreditCard className="h-4 w-4" />
                  View Subscriptions
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </>
  );
};

export default MemberDetail;
