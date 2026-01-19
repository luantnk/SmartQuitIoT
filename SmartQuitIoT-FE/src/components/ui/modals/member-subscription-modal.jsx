import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Separator } from "@/components/ui/separator";
import { getMemberSubscriptions } from "@/services/membershipPackage";
import { formatCurrency } from "@/utils/currencyFormat";
import { formatDate, formatDateTime } from "@/utils/formatDate";
import {
  Calendar,
  CheckCircle2,
  Clock,
  CreditCard,
  GiftIcon,
  Hash,
  Mail,
  Package,
  User,
} from "lucide-react";
import { useEffect, useState } from "react";

// const formatCurrency = (value) =>
//   new Intl.NumberFormat("vi-VN", {
//     style: "currency",
//     currency: "VND",
//   }).format(value || 0);

// const formatDate = (dateString) => {
//   if (!dateString) return "N/A";
//   return new Date(dateString).toLocaleDateString("en-US", {
//     year: "numeric",
//     month: "short",
//     day: "2-digit",
//   });
// };

// const formatDateTime = (dateTimeString) => {
//   if (!dateTimeString) return "N/A";
//   return new Date(dateTimeString).toLocaleString("en-US", {
//     year: "numeric",
//     month: "short",
//     day: "2-digit",
//     hour: "2-digit",
//     minute: "2-digit",
//   });
// };

const getStatusBadge = (status) => {
  switch (status) {
    case "AVAILABLE":
      return (
        <Badge className="bg-emerald-500 hover:bg-emerald-600">Available</Badge>
      );
    case "EXPIRED":
      return <Badge variant="secondary">Expired</Badge>;
    case "UNAVAILABLE":
      return <Badge className="bg-red-500 hover:bg-red-600">Unavailable</Badge>;
    default:
      return <Badge variant="outline">{status}</Badge>;
  }
};

const getPackageTypeBadge = (type) => {
  switch (type) {
    case "TRIAL":
      return (
        <Badge
          variant="outline"
          className="bg-blue-50 text-blue-700 border-blue-200"
        >
          Trial
        </Badge>
      );
    case "STANDARD":
      return (
        <Badge className="bg-green-500 hover:bg-green-600">Standard</Badge>
      );
    case "PREMIUM":
      return (
        <Badge className="bg-purple-500 hover:bg-purple-600">Premium</Badge>
      );
    default:
      return <Badge variant="outline">{type}</Badge>;
  }
};

const SubscriptionCard = ({ subscription }) => {
  const { member, membershipPackage } = subscription;

  return (
    <Card className="border-2 hover:border-primary/50 transition-colors h-full">
      <CardContent className="p-4 space-y-3">
        {/* Header: ID & Status */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-1.5">
            <Hash className="h-3.5 w-3.5 text-muted-foreground" />
            <span className="font-semibold text-sm">#{subscription.id}</span>
          </div>
          {getStatusBadge(subscription.status)}
        </div>

        <Separator />

        {/* Member Information */}
        <div className="flex items-center gap-2">
          <Avatar className="h-10 w-10">
            <AvatarImage
              src={member?.avatarUrl}
              alt={`${member?.firstName} ${member?.lastName}`}
            />
            <AvatarFallback className="text-xs">
              {member?.firstName?.[0]}
              {member?.lastName?.[0]}
            </AvatarFallback>
          </Avatar>
          <div className="flex-1 min-w-0">
            <div className="font-medium text-sm truncate">
              {member?.firstName} {member?.lastName}
            </div>
            <div className="flex items-center gap-1 text-xs text-muted-foreground truncate">
              <Mail className="h-3 w-3 flex-shrink-0" />
              <span className="truncate">
                {member?.account?.email || "N/A"}
              </span>
            </div>
          </div>
        </div>

        <Separator />

        {/* Package Information */}
        <div className="space-y-2">
          <div className="flex items-center gap-2 flex-wrap">
            <Package className="h-3.5 w-3.5 text-purple-600 flex-shrink-0" />
            <span className="font-medium text-sm">
              {membershipPackage?.name}
            </span>
            {getPackageTypeBadge(membershipPackage?.type)}
          </div>
          <div className="flex items-center gap-2 text-xs text-muted-foreground">
            <Clock className="h-3 w-3 flex-shrink-0" />
            <span>
              {membershipPackage?.duration}{" "}
              {membershipPackage?.durationUnit?.toLowerCase()}
            </span>
          </div>
        </div>

        <Separator />

        {/* Subscription Dates */}
        <div className="space-y-2">
          <div className="flex items-center justify-between text-xs">
            <span className="text-muted-foreground">Start</span>
            <span className="font-medium">
              {formatDate(subscription.startDate)}
            </span>
          </div>
          <div className="flex items-center justify-between text-xs">
            <span className="text-muted-foreground">End</span>
            <span className="font-medium">
              {formatDate(subscription.endDate)}
            </span>
          </div>
        </div>

        <Separator />

        {/* Payment Amount */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-1.5">
            <CreditCard className="h-3.5 w-3.5 text-emerald-600" />
            <span className="text-xs text-muted-foreground">Amount</span>
          </div>
          <span className="text-sm font-bold text-emerald-600">
            {formatCurrency(subscription.totalAmount)}
          </span>
        </div>

        {/* Account Status Badges */}
        {member?.account && (
          <div className="flex flex-wrap gap-1.5 pt-2">
            {member.account.isActive && (
              <Badge variant="outline" className="text-xs h-5">
                Active
              </Badge>
            )}
            {member.account.isBanned && (
              <Badge variant="destructive" className="text-xs h-5">
                Banned
              </Badge>
            )}
            {member.isUsedFreeTrial && (
              <Badge variant="secondary" className="text-xs h-5">
                Trial Used
              </Badge>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
};

const MemberSubscriptionModal = ({ isOpen, onOpenChange, memberId }) => {
  if (!memberId) return null;
  const [subscriptions, setSubscriptions] = useState([]);
  const fetchMemberSubscriptions = async () => {
    try {
      const response = await getMemberSubscriptions(memberId);
      setSubscriptions(response.data || []);
    } catch (error) {
      console.log(error);
    }
  };
  useEffect(() => {
    fetchMemberSubscriptions();
  }, [memberId]);

  return (
    <Dialog open={isOpen} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-3xl max-h-[90vh]">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <GiftIcon className="h-5 w-5 text-primary" />
            Member Subscriptions
          </DialogTitle>
          <DialogDescription>
            Detailed information about member subscription history
          </DialogDescription>
        </DialogHeader>

        <ScrollArea className="max-h-[calc(90vh-120px)] pr-4">
          {subscriptions.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12 text-center">
              <Package className="h-12 w-12 text-muted-foreground mb-3" />
              <p className="text-muted-foreground">No subscriptions found</p>
            </div>
          ) : (
            <div className="space-y-4">
              {subscriptions.map((subscription) => (
                <SubscriptionCard
                  key={subscription.id}
                  subscription={subscription}
                />
              ))}
            </div>
          )}
        </ScrollArea>
      </DialogContent>
    </Dialog>
  );
};

export default MemberSubscriptionModal;
