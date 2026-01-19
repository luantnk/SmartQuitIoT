import { slotColumns as buildSlotsColumns } from "@/pages/admin/components/columns/slotColumns";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { Button } from "@/components/ui/button";
import { DataTable } from "@/components/ui/tables/data-table";
import { getAllSlots } from "@/services/slotService";
import { useEffect, useState } from "react";
import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";
import ReseedSlotsModal from "@/pages/admin/components/modals/ReseedSlotsModal";
import { AlertTriangle } from "lucide-react";
import { toast } from "sonner";

const ManageSlots = () => {
  const [slots, setSlots] = useState([]);
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [isLoading, setIsLoading] = useState(false);
  const [isReseedModalOpen, setIsReseedModalOpen] = useState(false);

  const fetchSlots = async () => {
    try {
      setIsLoading(true);
      const response = await getAllSlots(currentPage, pageSize);
      setSlots(response.data?.data?.content);
      setTotalPages(response.data?.data?.page?.totalPages);
      setTotalElements(response.data?.data?.page?.totalElements);
    } catch (error) {
      console.log(error);
      toast.error("Failed to fetch slots. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchSlots();
  }, [currentPage, pageSize]);

  if (isLoading) return <TableLoadingSkeleton />;

  const cols = buildSlotsColumns({});

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };

  return (
    <div>
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-slots"]} />
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
              Manage Slots
            </h1>
            <p className="text-gray-600 mt-1 dark:text-gray-400">
              Manage and review slots ({totalElements} slots)
            </p>
          </div>
          <Button
            variant="destructive"
            onClick={() => setIsReseedModalOpen(true)}
            className="bg-red-600 hover:bg-red-700"
          >
            <AlertTriangle className="mr-2 h-4 w-4" />
            Reseed Slots
          </Button>
        </div>

        <DataTable
          columns={cols}
          data={slots}
          currentPage={currentPage}
          totalPages={totalPages}
          onPageChange={handlePageChange}
        />
      </div>

      <ReseedSlotsModal
        open={isReseedModalOpen}
        onOpenChange={setIsReseedModalOpen}
        onSuccess={() => {
          // Refresh the slots list after successful reseed
          fetchSlots();
        }}
      />
    </div>
  );
};

export default ManageSlots;
