import React, { useEffect, useState } from "react";
import { toast } from "sonner";
import { DataTable } from "@/components/ui/tables/data-table";
import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import SearchBar from "@/components/ui/search-bar";
import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";
import useDebounce from "@/hooks/useDebounce";
import { reminderColumns as buildReminderColumns } from "@/pages/admin/components/columns/reminderColumns";
import {
  getAllReminderTemplates,
  updateReminderTemplate,
} from "@/services/reminderTemplateService";
import EditReminderModal from "@/pages/admin/components/modals/EditReminderModal";

const ManageReminderTemplates = () => {
  const [currentPage, setCurrentPage] = useState(0);
  const [pageSize, setPageSize] = useState(10);
  const [totalPages, setTotalPages] = useState(0);
  const [totalElements, setTotalElements] = useState(0);
  const [searchString, setSearchString] = useState("");
  const [reminders, setReminders] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [editingReminder, setEditingReminder] = useState(null);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  
  const inputSearchDebounce = useDebounce(searchString, 300);

  const handlePageChange = (newPage) => {
    setCurrentPage(newPage);
  };

  const fetchReminders = async () => {
    setIsLoading(true);
    try {
      const response = await getAllReminderTemplates(
        currentPage,
        pageSize,
        inputSearchDebounce
      );
      const { content, page } = response.data;
      setReminders(content || []);
      setTotalPages(page?.totalPages || 0);
      setTotalElements(page?.totalElements || 0);
    } catch (error) {
      console.error("Failed to fetch reminder templates:", error);
      toast.error("Failed to fetch reminder templates");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchReminders();
  }, [currentPage, inputSearchDebounce]);

  const handleEdit = (reminder) => {
    setEditingReminder(reminder);
    setIsEditModalOpen(true);
  };

  const handleUpdateReminder = async (id, data) => {
    try {
      await updateReminderTemplate(id, data);
      toast.success("Reminder template updated successfully");
      setIsEditModalOpen(false);
      setEditingReminder(null);
      fetchReminders();
    } catch (error) {
      console.error("Failed to update reminder template:", error);
      const errorMsg = error?.response?.data?.message || "Failed to update reminder template";
      toast.error(errorMsg);
    }
  };

  const cols = buildReminderColumns({
    onEdit: handleEdit,
  });

  if (isLoading && reminders.length === 0) return <TableLoadingSkeleton />;

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-reminder-templates"]} />
      
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
            Manage Reminder Templates
          </h1>
          <p className="text-gray-600 mt-1 dark:text-gray-400">
            Manage and edit reminder templates ({totalElements} templates)
          </p>
        </div>
      </div>

      <SearchBar
        placeholderText={"Search by content..."}
        searchString={searchString}
        setSearchString={setSearchString}
      />

      <DataTable
        columns={cols}
        data={reminders}
        currentPage={currentPage}
        totalPages={totalPages}
        onPageChange={handlePageChange}
      />

      <EditReminderModal
        open={isEditModalOpen}
        onClose={() => {
          setIsEditModalOpen(false);
          setEditingReminder(null);
        }}
        reminder={editingReminder}
        onSubmit={handleUpdateReminder}
      />
    </div>
  );
};

export default ManageReminderTemplates;
