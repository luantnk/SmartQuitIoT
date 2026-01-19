import React, { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { UserCheck, Users } from "lucide-react";
import { getCoachStatistics } from "@/services/coachService";
import { toast } from "sonner";
import CardLoading from "@/components/loadings/CardLoading";

const CoachDashboardCard = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchData = async () => {
    try {
      const response = await getCoachStatistics();
      setData(response.data);
    } catch (error) {
      console.error(error);
      toast.error("Failed to fetch coach statistics");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  if (loading) {
    return <CardLoading title={"Coach Statistics Loading..."} />;
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">Total Coaches</CardTitle>
        <div className="h-8 w-8 rounded-full bg-indigo-100 flex items-center justify-center">
          <UserCheck className="h-4 w-4 text-indigo-600" />
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-2">
          <div className="text-3xl font-bold">{data?.totalCoaches ?? 0}</div>
          <div className="flex items-center gap-2">
            <Users className="h-4 w-4 text-muted-foreground" />
            <span className="text-xs text-muted-foreground">
              Active coaching staff
            </span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default CoachDashboardCard;
