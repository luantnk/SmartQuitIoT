import React, { useEffect, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { DollarSign, Receipt, TrendingUp } from "lucide-react";
import { Separator } from "@/components/ui/separator";
import { getPaymentStatistics } from "@/services/membershipPackage";
import CardLoading from "@/components/loadings/CardLoading";

const PaymentDashboardCard = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchData = async () => {
    try {
      const response = await getPaymentStatistics();
      setData(response.data);
      setLoading(false);
    } catch (error) {
      console.log(error);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const formatCurrency = (value) =>
    new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(value || 0);

  const averagePayment =
    data?.totalPayments > 0
      ? Math.round(data.totalAmount / data.totalPayments)
      : 0;

  if (loading) {
    return <CardLoading title={"Payment Statistics Loading.."} />;
  }

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">Total Revenue</CardTitle>
        <div className="h-8 w-8 rounded-full bg-emerald-100 flex items-center justify-center">
          <DollarSign className="h-4 w-4 text-emerald-600" />
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {/* Total Amount */}
          <div>
            <div className="text-3xl font-bold text-emerald-600">
              {formatCurrency(data?.totalAmount)}
            </div>
            <p className="text-xs text-muted-foreground mt-1">
              Total revenue from all payments
            </p>
          </div>

          <Separator />

          {/* Payment Stats */}
          <div className="grid grid-cols-2 gap-4">
            <div className="space-y-1">
              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                <Receipt className="h-3 w-3" />
                <span>Total Payments</span>
              </div>
              <div className="text-xl font-bold">
                {data?.totalPayments ?? 0}
              </div>
            </div>

            <div className="space-y-1">
              <div className="flex items-center gap-1 text-xs text-muted-foreground">
                <TrendingUp className="h-3 w-3" />
                <span>Avg/Payment</span>
              </div>
              <div className="text-xl font-bold text-blue-600">
                {formatCurrency(averagePayment)}
              </div>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};

export default PaymentDashboardCard;
