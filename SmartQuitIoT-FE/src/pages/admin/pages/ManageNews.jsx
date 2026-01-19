import { newsColumns as buildNewsColumns } from "@/pages/admin/components/columns/newsColumns";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { Button } from "@/components/ui/button";
import SearchBar from "@/components/ui/search-bar";
import { DataTable } from "@/components/ui/tables/data-table";
import useDebounce from "@/hooks/useDebounce";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";

const ManageNews = () => {
  const [news, setNews] = useState([]);
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [sortBy, setSortBy] = useState("ASC");
  const [searchString, setSearchString] = useState("");
  const inputSearchDebounce = useDebounce(searchString, 300);
  const [isLoading, setIsLoading] = useState(false);
  const nav = useNavigate();

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };

  const handleEdit = (row) => {
    const values = row.original; // your row data
    // open edit modal, navigate, etc.
    console.log("Edit:", values);
  };

  const handleDelete = (row) => {
    const { id } = row.original;
    // call API then refresh table
    console.log("Delete id:", id);
  };

  const cols = buildNewsColumns({
    onEdit: handleEdit,
    onDelete: handleDelete,
  });

  if (isLoading) return <TableLoadingSkeleton />;

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-news"]} />
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
            Manage News
          </h1>
          <p className="text-gray-600 mt-1 dark:text-gray-400">
            Manage and review news articles ({totalElements} articles)
          </p>
        </div>
        <div className="">
          <Button onClick={() => nav("/admin/manage-news/create")}>
            Add News Article
          </Button>
        </div>
      </div>
      <SearchBar
        placeholderText={"Search News"}
        searchString={searchString}
        setSearchString={setSearchString}
        sortBy={sortBy}
        setSortBy={setSortBy}
      />
      <DataTable
        columns={cols}
        data={news}
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={handlePageChange}
      />
    </div>
  );
};

export default ManageNews;
