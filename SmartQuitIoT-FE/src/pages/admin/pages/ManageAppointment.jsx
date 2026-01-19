import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import SearchBar from "@/components/ui/search-bar";
import { DataTable } from "@/components/ui/tables/data-table";
import { appointmentColumns as buildAppointmentColumns } from "@/pages/admin/components/columns/appointmentColumns";
import AppointmentDetailModal from "@/pages/admin/components/modals/AppointmentDetailModal";
import ReassignAppointmentModal from "@/pages/admin/components/modals/ReassignAppointmentModal";
import { getAllAppointments } from "@/services/appointmentService";
import { useEffect, useState, useCallback } from "react";

const ManageAppointment = () => {
  const [appointments, setAppointments] = useState([]);
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [status, setStatus] = useState("");
  const [isOpenDetailModal, setIsOpenDetailModal] = useState(false);
  const [selectedAppointment, setSelectedAppointment] = useState(null);
  const [isOpenReassignModal, setIsOpenReassignModal] = useState(false);
  const [selectedAppointmentForReassign, setSelectedAppointmentForReassign] =
    useState(null);

  const fetchAppointments = useCallback(async () => {
    try {
      const response = await getAllAppointments(currentPage, pageSize, status);
      setAppointments(response.data.content);
      setTotalPages(response.data.page?.totalPages);
      setTotalElements(response.data.page?.totalElements);
    } catch (error) {
      console.error("Error fetching appointments:", error);
    }
  }, [currentPage, pageSize, status]);

  useEffect(() => {
    fetchAppointments();
  }, [fetchAppointments]);

  const handleViewDetail = (row) => {
    console.log("View details for appointment:", row.original);
    setIsOpenDetailModal(true);
    setSelectedAppointment(row.original);
  };

  const handleReassign = (row) => {
    console.log("Reassign appointment:", row.original);
    setIsOpenReassignModal(true);
    setSelectedAppointmentForReassign(row.original);
  };

  const cols = buildAppointmentColumns({
    onEdit: handleViewDetail,
    onReassign: handleReassign,
  });

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };

  return (
    <>
      <div className="p-6 space-y-6">
        <AppBreadcrumb paths={["admin", "manage-appointments"]} />
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
              Manage Appointments
            </h1>
            <p className="text-gray-600 mt-1 dark:text-gray-400">
              Manage and review appointments ({totalElements} appointments)
            </p>
          </div>
        </div>
        <SearchBar
          filterByAppointmentStatus={status}
          setFilterByAppointmentStatus={setStatus}
        />
        <DataTable
          columns={cols}
          data={appointments}
          currentPage={currentPage}
          totalPages={totalPages}
          onPageChange={handlePageChange}
        />
      </div>
      {isOpenDetailModal && selectedAppointment && (
        <AppointmentDetailModal
          isOpen={isOpenDetailModal}
          onOpenChange={setIsOpenDetailModal}
          appointment={selectedAppointment}
        />
      )}
      {isOpenReassignModal && selectedAppointmentForReassign && (
        <ReassignAppointmentModal
          isOpen={isOpenReassignModal}
          onOpenChange={setIsOpenReassignModal}
          appointment={selectedAppointmentForReassign}
          onReassigned={() => {
            // refresh list and close modal
            fetchAppointments();
            setIsOpenReassignModal(false);
          }}
        />
      )}
    </>
  );
};

export default ManageAppointment;
