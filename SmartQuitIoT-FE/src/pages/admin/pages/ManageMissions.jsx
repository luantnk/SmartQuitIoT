import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import { getAllMission, deleteMission } from "@/services/missionService";
import { toast } from "sonner";
import { CloudLightning } from "lucide-react";
import SearchBar from "@/components/ui/search-bar";
import useDebounce from "@/hooks/useDebounce";
import { useNavigate } from "react-router-dom";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import React, { useEffect, useState } from "react";
import { missionsColumns as buildMissionColumns } from "@/pages/admin/components/columns/missionColumns";
import { DataTable } from "@/components/ui/tables/data-table";
import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";
import { Button } from "@/components/ui/button";

const ManageMissions = () => {
  const navigate = useNavigate();
  const [missions, setMissions] = useState([]);
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [searchString, setSearchString] = useState("");
  const [statusFilter, setStatusFilter] = useState("");
  const [phaseFilter, setPhaseFilter] = useState("");
  const inputSearchDebounce = useDebounce(searchString, 300);
  const [isLoading, setIsLoading] = useState(false);

  const fetchMissions = async (page, size, search, status, phase) => {
    try {
      setIsLoading(true);
      const response = await getAllMission(page, size, search, status, phase);
      
      // Parse condition if it's a JSON string
      const missions = response.data?.content?.map(mission => ({
        ...mission,
        condition: typeof mission.condition === 'string' 
          ? JSON.parse(mission.condition) 
          : mission.condition
      }));
      
      setMissions(missions);
      setTotalPages(response.data?.page?.totalPages);
      setTotalElements(response.data?.page?.totalElements);
    } catch (error) {
      console.error("Error fetching missions:", error);
      toast.error("Failed to fetch missions");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchMissions(currentPage, pageSize, inputSearchDebounce, statusFilter, phaseFilter);
  }, [currentPage, pageSize, inputSearchDebounce, statusFilter, phaseFilter]);

  const handleEdit = (row) => {
    const { id } = row.original;
    navigate(`/admin/manage-missions/edit/${id}`);
  };

  const handleViewDetails = (row) => {
    const { id } = row.original;
    navigate(`/admin/manage-missions/${id}`);
  };

  const handleDelete = async (row) => {
    const { id, name } = row.original;
    
    try {
      await deleteMission(id);
      toast.success("Mission deleted successfully");
      fetchMissions(currentPage, pageSize, inputSearchDebounce, statusFilter, phaseFilter);
    } catch (error) {
      console.error("Error deleting mission:", error);
      toast.error("Failed to delete mission");
    }
  };

  const cols = buildMissionColumns({
    onEdit: handleEdit,
    onDelete: handleDelete,
    onViewDetails: handleViewDetails,
  });

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };

  if (isLoading) return <TableLoadingSkeleton />;

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-missions"]} />
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
            Manage Missions
          </h1>
          <p className="text-gray-600 mt-1 dark:text-gray-400">
            Manage and review missions ({totalElements} missions)
          </p>
        </div>
        <Button onClick={() => navigate("/admin/manage-missions/create")}>
          Create Mission
        </Button>
      </div>
      <div className="flex gap-4 items-end">
        <div className="flex-1">
          <SearchBar
            placeholderText={"Search missions by code, name, description or condition"}
            searchString={searchString}
            setSearchString={setSearchString}
          />
        </div>
        <div >
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Filter by Status
          </label>
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger>
              <SelectValue placeholder="All Status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Status</SelectItem>
              <SelectItem value="ACTIVE">Active</SelectItem>
              <SelectItem value="INACTIVE">Inactive</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div >
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Filter by Phase
          </label>
          <Select value={phaseFilter} onValueChange={setPhaseFilter}>
            <SelectTrigger>
              <SelectValue placeholder="All Phases" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Phases</SelectItem>
              <SelectItem value="PREPARATION">Preparation</SelectItem>
              <SelectItem value="ONSET">Onset</SelectItem>
              <SelectItem value="PEAK_CRAVING">Peak Craving</SelectItem>
              <SelectItem value="SUBSIDING">Subsiding</SelectItem>
              <SelectItem value="MAINTENANCE">Maintenance</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>
      <DataTable
        columns={cols}
        data={missions}
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={handlePageChange}
      />
    </div>
  );
};

export default ManageMissions;
