import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { DataTable } from "@/components/ui/tables/data-table";
import { membershipPackageColumns as buildMembershipPackageColumns } from "@/pages/admin/components/columns/membershipPackageColumns";
import MembershipDetailModal from "@/pages/admin/components/modals/MembershipDetailModal";
import { getAllMembershipPackages } from "@/services/membershipPackage";
import { useEffect, useState } from "react";
import { toast } from "sonner";

const ManageMembershipPackage = () => {
  const [packages, setPackages] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [selectedId, setSelectedId] = useState(null);
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);

  const fetchMembershipPackages = async () => {
    setIsLoading(true);
    try {
      const response = await getAllMembershipPackages();
      setPackages(response.data?.data);
    } catch (error) {
      console.log(error);
      toast.error("Failed to fetch membership packages. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleEdit = (row) => {
    const values = row.original.id; // your row data
    // open edit modal, navigate, etc.
    setSelectedId(values);
    setIsDetailModalOpen(true);
  };

  const cols = buildMembershipPackageColumns({
    onEdit: handleEdit,
  });

  useEffect(() => {
    fetchMembershipPackages();
  }, []);

  if (isLoading) return <TableLoadingSkeleton />;

  return (
    <>
      <div>
        <div className="p-6 space-y-6">
          <AppBreadcrumb paths={["admin", "manage-membership-packages"]} />
          <div className="flex justify-between items-center">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
                Manage Membership Packages
              </h1>
              <p className="text-gray-600 mt-1 dark:text-gray-400">
                Manage and review membership packages ({packages.length}{" "}
                packages)
              </p>
            </div>
          </div>
          {/* Table component goes here, using `cols` and `packages` as data */}
          <DataTable columns={cols} data={packages} />
        </div>
      </div>
      {isDetailModalOpen && (
        <MembershipDetailModal
          isOpen={isDetailModalOpen}
          onOpenChange={setIsDetailModalOpen}
          id={selectedId}
        />
      )}
    </>
  );
};

export default ManageMembershipPackage;
