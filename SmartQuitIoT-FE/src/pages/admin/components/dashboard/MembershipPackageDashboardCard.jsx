import CardLoading from "@/components/loadings/CardLoading";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Separator } from "@/components/ui/separator";
import { getMembershipPackagesStatistics } from "@/services/membershipPackage";
import { CheckCircle2, Crown, Package, Users } from "lucide-react";
import { useEffect, useState } from "react";

const MembershipPackageDashboardCard = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchData = async () => {
    try {
      const response = await getMembershipPackagesStatistics();
      setData(response.data);
      setLoading(false);
    } catch (error) {
      console.log(error);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  if (loading) {
    return <CardLoading title={"Membership Package Statistics Loading..."} />;
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">
          Membership Packages
        </CardTitle>
        <div className="h-8 w-8 rounded-full bg-purple-100 flex items-center justify-center">
          <Package className="h-4 w-4 text-purple-600" />
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {/* Most Popular Package */}
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Crown className="h-4 w-4 text-amber-500" />
              <span className="text-sm text-muted-foreground">
                Most Popular
              </span>
            </div>
            <Badge className="bg-amber-100 text-amber-700 hover:bg-amber-200">
              {data?.mostPopularPackage ?? "N/A"}
            </Badge>
          </div>

          <Separator />

          {/* Stats Grid */}
          <div className="grid grid-cols-3 gap-3">
            <div className="space-y-1">
              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                <Package className="h-3 w-3" />
                <span>Packages</span>
              </div>
              <div className="text-xl font-bold">
                {data?.totalMembershipPackage ?? 0}
              </div>
            </div>

            <div className="space-y-1">
              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                <Users className="h-3 w-3" />
                <span>Total Subs</span>
              </div>
              <div className="text-xl font-bold">
                {data?.totalSubscriptions ?? 0}
              </div>
            </div>

            <div className="space-y-1">
              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                <CheckCircle2 className="h-3 w-3" />
                <span>Active</span>
              </div>
              <div className="text-xl font-bold text-emerald-600">
                {data?.activeSubscriptions ?? 0}
              </div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default MembershipPackageDashboardCard;
