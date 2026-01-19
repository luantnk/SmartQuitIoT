import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { Button } from "@/components/ui/button";
import SearchBar from "@/components/ui/search-bar";
import { DataTable } from "@/components/ui/tables/data-table";
import useDebounce from "@/hooks/useDebounce";
import { coachesColumns as buildCoachesColumns } from "@/pages/admin/components/columns/coachesColumns";
import { deletedAccount } from "@/services/accountService";
import { getAllPagedCoaches } from "@/services/coachService";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";

const ManageCoaches = () => {
  const [coaches, setCoaches] = useState([]);
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [sortBy, setSortBy] = useState("ASC");
  const [searchString, setSearchString] = useState("");
  const [isActive, setIsActive] = useState(true);
  const inputSearchDebounce = useDebounce(searchString, 300);
  const [isLoading, setIsLoading] = useState(false);
  const nav = useNavigate();

  const fetchCoaches = async () => {
    setIsLoading(true);
    try {
      const response = await getAllPagedCoaches(
        currentPage,
        pageSize,
        inputSearchDebounce,
        sortBy,
        isActive
      );
      setCoaches(response.data?.data?.content);
      setTotalPages(response.data?.data?.page?.totalPages);
      setTotalElements(response.data?.data?.page?.totalElements);
      setIsLoading(false);
    } catch (error) {
      console.log(error);
      toast.error("Failed to fetch coaches. Please try again.");
    }
  };

  useEffect(() => {
    fetchCoaches();
  }, [currentPage, inputSearchDebounce, sortBy, isActive]);

  const handleViewDetail = (row) => {
    const { id } = row.original; // your row data
    // open edit modal, navigate, etc.
    console.log("View Detail:", id);
    nav(`/admin/manage-coaches/${id}`);
  };

  const handleDelete = async (row) => {
    const id = row.original.account?.id;
    try {
      const response = await deletedAccount(id);
      if (response) {
        toast.success(response.data?.data);
        fetchCoaches();
      }
    } catch (error) {
      toast.error(error.response.data?.message, {
        duration: 5000,
      });
    }
  };

  const cols = buildCoachesColumns({
    onEdit: handleViewDetail,
    onDelete: handleDelete,
  });

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };

  if (isLoading) return <TableLoadingSkeleton />;

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-coaches"]} />
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
            Manage Coaches
          </h1>
          <p className="text-gray-600 mt-1 dark:text-gray-400">
            Manage and review coaches ({totalElements} coaches)
          </p>
        </div>
        <div className="">
          <Button onClick={() => nav("/admin/manage-coaches/create")}>
            Add Coach
          </Button>
        </div>
      </div>
      <SearchBar
        placeholderText={"Search by Coaches name"}
        searchString={searchString}
        setSearchString={setSearchString}
        sortBy={sortBy}
        setSortBy={setSortBy}
        filterBy={isActive}
        setFilterBy={setIsActive}
      />
      <DataTable
        columns={cols}
        data={coaches}
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={handlePageChange}
      />
    </div>
  );
};

export default ManageCoaches;
