import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import SearchBar from "@/components/ui/search-bar";
import { DataTable } from "@/components/ui/tables/data-table";
import useDebounce from "@/hooks/useDebounce";
import { memberColumns as buildMemberColumns } from "@/pages/admin/components/columns/memberColumns";
import { deletedAccount } from "@/services/accountService";
import { getAllMembers } from "@/services/memberService";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";

const ManageMembers = () => {
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [searchString, setSearchString] = useState("");
  const [members, setMembers] = useState([]);
  const [isActive, setIsActive] = useState(true);
  const inputSearchDebounce = useDebounce(searchString, 300);
  const [isLoading, setIsLoading] = useState(false);
  const nav = useNavigate();

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };

  const fetchMembers = async () => {
    setIsLoading(true);
    try {
      const response = await getAllMembers(
        currentPage,
        pageSize,
        inputSearchDebounce,
        isActive
      );
      const { content } = response.data;
      setMembers(content);
      setTotalPages(response.data.page?.totalPages);
      setTotalElements(response.data.page?.totalElements);
    } catch (error) {
      console.error("Failed to fetch members:", error);
      toast.error("Failed to fetch members");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchMembers();
  }, [currentPage, inputSearchDebounce, isActive]);

  const handleViewDetail = (row) => {
    const { id } = row.original; // your row data
    // open edit modal, navigate, etc.
    nav(`/admin/manage-members/${id}`);
  };

  const handleDelete = async (row) => {
    const id = row.original?.account?.id;

    // call API then refresh table
    try {
      const response = await deletedAccount(id);
      if (response) {
        toast.success(response.data?.data);
        fetchMembers();
      }
    } catch (error) {
      toast.error(error.response.data?.message, {
        duration: 5000,
      });
    }
  };

  const cols = buildMemberColumns({
    onEdit: handleViewDetail,
    onDelete: handleDelete,
  });

  if (isLoading) return <TableLoadingSkeleton />;
  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-members"]} />
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
            Manage Members
          </h1>
          <p className="text-gray-600 mt-1 dark:text-gray-400">
            Manage and review members ({totalElements} members)
          </p>
        </div>
      </div>
      <SearchBar
        placeholderText={"Search members by name"}
        searchString={searchString}
        setSearchString={setSearchString}
        filterBy={isActive}
        setFilterBy={setIsActive}
      />
      <DataTable
        columns={cols}
        data={members}
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={handlePageChange}
      />
    </div>
  );
};

export default ManageMembers;
