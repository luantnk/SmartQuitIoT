import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import SearchBar from "@/components/ui/search-bar";
import { DataTable } from "@/components/ui/tables/data-table";
import useDebounce from "@/hooks/useDebounce";
import { subscriptionColumns as buildSubscriptionColumns } from "@/pages/admin/components/columns/subscriptionColumns";
import { getAllMembershipSubscriptions } from "@/services/membershipPackage";
import { useEffect, useState } from "react";

const ManageSubscriptions = () => {
  const [subscriptions, setSubscriptions] = useState([]);
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [sortBy, setSortBy] = useState("desc");
  const [isLoading, setIsLoading] = useState(false);
  const [searchString, setSearchString] = useState("");
  const inputSearchDebounce = useDebounce(searchString, 300);
  const [filterBy, setFilterBy] = useState("");

  const fetchSubscriptions = async () => {
    setIsLoading(true);
    try {
      const response = await getAllMembershipSubscriptions(
        currentPage,
        pageSize,
        "createdAt",
        sortBy,
        inputSearchDebounce,
        filterBy
      );
      setSubscriptions(response.data?.content);
      setTotalPages(response.data?.page?.totalPages);
      setTotalElements(response.data?.page?.totalElements);
      setIsLoading(false);
    } catch (error) {
      console.log(error);
      toast.error("Failed to fetch subscriptions. Please try again.");
    }
  };

  useEffect(() => {
    fetchSubscriptions();
  }, [currentPage, sortBy, inputSearchDebounce, filterBy]);

  const cols = buildSubscriptionColumns({});

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };

  if (isLoading) return <TableLoadingSkeleton />;

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-subscriptions"]} />
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
            Manage Subscriptions
          </h1>
          <p className="text-gray-600 mt-1 dark:text-gray-400">
            Manage and review subscriptions ({totalElements} subscriptions)
          </p>
        </div>
      </div>
      <SearchBar
        placeholderText={"Search by Subscriptions Order Code"}
        searchString={searchString}
        setSearchString={setSearchString}
        filterBySubscriptionStatus={filterBy}
        setFilterBySubscriptionStatus={setFilterBy}
      />
      <DataTable
        columns={cols}
        data={subscriptions}
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={handlePageChange}
      />
    </div>
  );
};

export default ManageSubscriptions;
