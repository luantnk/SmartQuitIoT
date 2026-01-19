import { getAllPayments } from "@/services/paymentService";
import React, { useEffect, useState } from "react";
import { paymentColumns as buildPaymentColumns } from "@/pages/admin/components/columns/paymentColumns";
import { DataTable } from "@/components/ui/tables/data-table";
import useDebounce from "@/hooks/useDebounce";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";
import SearchBar from "@/components/ui/search-bar";

const ManagePayment = () => {
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [searchString, setSearchString] = useState("");
  const [payments, setPayments] = useState([]);
  const inputSearchDebounce = useDebounce(searchString, 300);
  const [isLoading, setIsLoading] = useState(false);
  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };
  const fetchPayments = async () => {
    setIsLoading(true);
    try {
      const response = await getAllPayments(
        currentPage,
        pageSize,
        inputSearchDebounce
      );
      console.log(response.data);
      setTotalPages(response.data?.page?.totalPages);
      setTotalElements(response.data?.page?.totalElements);
      setPayments(response.data?.content);
      setIsLoading(false);
    } catch (error) {
      console.log(error);
    }
  };

  useEffect(() => {
    fetchPayments();
  }, [currentPage, inputSearchDebounce]);

  const cols = buildPaymentColumns();

  if (isLoading) return <TableLoadingSkeleton />;

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-payments"]} />
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
            Manage Payments
          </h1>
          <p className="text-gray-600 mt-1 dark:text-gray-400">
            Manage and review payments ({totalElements} payments)
          </p>
        </div>
      </div>
      <SearchBar
        placeholderText={"Search by Member name, Order code..."}
        searchString={searchString}
        setSearchString={setSearchString}
      />
      <DataTable
        columns={cols}
        data={payments}
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={handlePageChange}
      />
    </div>
  );
};

export default ManagePayment;
