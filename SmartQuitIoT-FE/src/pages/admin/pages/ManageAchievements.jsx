import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { Button } from "@/components/ui/button";
import SearchBar from "@/components/ui/search-bar";
import { DataTable } from "@/components/ui/tables/data-table";
import useDebounce from "@/hooks/useDebounce";
import { achievementColumns as buildAchievementColumns } from "@/pages/admin/components/columns/achivementColumns";
import {
  deleteAchievement,
  getAllAchievements,
} from "@/services/achievementService";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";

const ManageAchievements = () => {
  const navigate = useNavigate();
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [searchString, setSearchString] = useState("");
  const [achievements, setAchievements] = useState([]);
  const inputSearchDebounce = useDebounce(searchString, 300);
  const [isLoading, setIsLoading] = useState(false);

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };

  const handleEdit = (row) => {
    const { id } = row.original;
    navigate(`/admin/manage-achievements/edit/${id}`);
  };

  const handleDelete = async (row) => {
    const { id, name } = row.original;

    try {
      await deleteAchievement(id);
      toast.success("Achievement deleted successfully");
      fetchAchievements();
    } catch (error) {
      console.error("Error deleting achievement:", error);
      toast.error("Failed to delete achievement");
    }
  };

  const handleViewDetails = (row) => {
    const { id } = row.original;
    navigate(`/admin/manage-achievements/${id}`);
  };

  const cols = buildAchievementColumns({
    onEdit: handleEdit,
    onDelete: handleDelete,
    onViewDetails: handleViewDetails,
  });

  const fetchAchievements = async () => {
    setIsLoading(true);
    try {
      const response = await getAllAchievements(
        currentPage,
        pageSize,
        inputSearchDebounce
      );
      setTotalPages(response.data?.page?.totalPages);
      setTotalElements(response.data?.page?.totalElements);
      setAchievements(response.data?.content);
      setIsLoading(false);
    } catch (error) {
      toast.error("Failed to fetch achievements. Please try again.");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchAchievements();
  }, [currentPage, inputSearchDebounce]);

  if (isLoading) return <TableLoadingSkeleton />;

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-achievements"]} />
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
            Manage Achievements
          </h1>
          <p className="text-gray-600 mt-1 dark:text-gray-400">
            Manage and review achievements ({totalElements} achievements)
          </p>
        </div>
        <Button onClick={() => navigate("/admin/manage-achievements/create")}>
          Create Achievement
        </Button>
      </div>
      <SearchBar
        placeholderText={"Search achievements by name or description"}
        searchString={searchString}
        setSearchString={setSearchString}
      />
      <DataTable
        columns={cols}
        data={achievements}
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={handlePageChange}
      />
    </div>
  );
};

export default ManageAchievements;
