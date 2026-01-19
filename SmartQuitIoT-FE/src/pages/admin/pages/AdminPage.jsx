import CoachDashboardCard from "@/pages/admin/components/dashboard/CoachDashboardCard";
import MemberDashboardCard from "@/pages/admin/components/dashboard/MemberDashboardCard";
import MembershipPackageDashboardCard from "@/pages/admin/components/dashboard/MembershipPackageDashboardCard";
import PaymentDashboardCard from "@/pages/admin/components/dashboard/PaymentDashboardCard";
import SystemActivityCard from "@/pages/admin/components/dashboard/SystemActivityCard";

const AdminPage = () => {
  return (
    <div className="p-6 space-y-6">
      {/* Header */}
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Admin Dashboard</h1>
          <p className="text-gray-600 mt-1">
            Overview of system statistics and recent activitys
          </p>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <MemberDashboardCard />
        <CoachDashboardCard />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <MembershipPackageDashboardCard />
        <PaymentDashboardCard />
      </div>
      <SystemActivityCard size={5} />
    </div>
  );
};

export default AdminPage;
