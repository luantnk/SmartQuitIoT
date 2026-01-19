import AppBreadcrumb from "@/components/ui/app-breadcrumb";
import {
  getAllSystemPhaseConditions,
  updateSystemPhaseCondition,
} from "@/services/systemPhaseConditionService";
import React, { useEffect, useState } from "react";
import { passConditionColumns as buildPassConditionColumns } from "@/pages/admin/components/columns/passConditionColumns";
import { DataTable } from "@/components/ui/tables/data-table";
import TableLoadingSkeleton from "@/components/loadings/TableLoadingSkeleton";
import EditPassConditionModal from "@/pages/admin/components/modals/EditPassConditionModal";
import useToast from "@/hooks/useToast";

const ManagePassCondition = () => {
  const [passConditions, setPassConditions] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [selectedCondition, setSelectedCondition] = useState(null);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  const toast = useToast();

  const fetchPassConditions = async () => {
    try {
      setIsLoading(true);
      const response = await getAllSystemPhaseConditions();
      setPassConditions(response.data);
    } catch (error) {
      toast.error("Failed to fetch pass conditions");
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchPassConditions();
  }, []);

  const handleEdit = (row) => {
    const values = row.original;
    setSelectedCondition(values);
    setIsEditModalOpen(true);
  };

  const handleSaveCondition = async (updatedCondition) => {
    // Validation 1: Check condition structure
    if (!updatedCondition.condition?.logic || !updatedCondition.condition?.rules) {
      toast.error("Invalid condition structure: must have logic and rules");
      throw new Error("Invalid condition structure");
    }

    // Validation 2: Check logic value
    if (!["AND", "OR"].includes(updatedCondition.condition.logic)) {
      toast.error("Logic must be either AND or OR");
      throw new Error("Invalid logic operator");
    }

    // Validation 3: Check rules array
    if (!Array.isArray(updatedCondition.condition.rules) || updatedCondition.condition.rules.length === 0) {
      toast.error("Condition must have at least one rule");
      throw new Error("Rules must be a non-empty array");
    }
    
    try {
      await updateSystemPhaseCondition(updatedCondition.id, {
        condition: updatedCondition.condition,
      });
      console.log("Updated Condition:", JSON.stringify(updatedCondition, null, 2));
      toast.success("Pass condition updated successfully");
      fetchPassConditions();
    } catch (error) {
      toast.error("Failed to update pass condition");
      throw error;
    }
  };

  const cols = buildPassConditionColumns({
    onEdit: handleEdit,
  });

  if (isLoading) return <TableLoadingSkeleton />;

  return (
    <div className="p-6 space-y-6">
      <AppBreadcrumb paths={["admin", "manage-pass-conditions"]} />
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-gray-900 dark:text-emerald-800">
            Manage Pass Conditions
          </h1>
          <p className="text-gray-600 mt-1 dark:text-gray-400">
            Configure system phase pass conditions ({passConditions.length}{" "}
            conditions)
          </p>
        </div>
      </div>
      <DataTable columns={cols} data={passConditions} />

      <EditPassConditionModal
        open={isEditModalOpen}
        onClose={() => {
          setIsEditModalOpen(false);
          setSelectedCondition(null);
        }}
        condition={selectedCondition}
        onSave={handleSaveCondition}
      />
    </div>
  );
};

export default ManagePassCondition;
