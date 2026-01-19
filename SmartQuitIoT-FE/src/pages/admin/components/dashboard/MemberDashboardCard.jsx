import React, { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Users, TrendingUp, TrendingDown } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { getMemberStatistics } from "@/services/accountService";
import CardLoading from "@/components/loadings/CardLoading";

const MemberDashboardCard = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchMemberStats = async () => {
    try {
      const response = await getMemberStatistics();
      setData(response.data);
      setLoading(false);
    } catch (error) {
      console.log(error);
    }
  };

  useEffect(() => {
    fetchMemberStats();
  }, []);

  if (loading) {
    return <CardLoading title={"Member Statistics Loading.."} />;
  }

  const isPositiveGrowth = (data?.growthPercentage ?? 0) >= 0;
  const growthValue = Math.abs(data?.growthPercentage ?? 0);

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">Total Members</CardTitle>
        <div className="h-8 w-8 rounded-full bg-blue-100 flex items-center justify-center">
          <Users className="h-4 w-4 text-blue-600" />
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-2">
          <div className="text-3xl font-bold">{data?.totalMember ?? 0}</div>
          <div className="flex items-center gap-2">
            <Badge
              variant={isPositiveGrowth ? "default" : "destructive"}
              className={`flex items-center gap-1 ${
                isPositiveGrowth
                  ? "bg-emerald-100 text-emerald-700 hover:bg-emerald-200"
                  : "bg-red-100 text-red-700 hover:bg-red-200"
              }`}
            >
              {isPositiveGrowth ? (
                <TrendingUp className="h-3 w-3" />
              ) : (
                <TrendingDown className="h-3 w-3" />
              )}
              {growthValue}%
            </Badge>
            <span className="text-xs text-muted-foreground">
              {data?.currentMonthUsers ?? 0} this month
            </span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default MemberDashboardCard;
