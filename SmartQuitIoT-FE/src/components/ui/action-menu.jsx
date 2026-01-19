import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Eye, MoreHorizontal, Pencil, Trash2, UserRoundCog } from "lucide-react";
import { useState } from "react";

export default function ActionMenu({
  row,
  onEdit,
  onDelete,
  onViewDetails,
  onReassign,
  editMessage = "Edit",
  deleteMessage = "Delete",
  viewDetailsMessage = "View Details",
  reassignMessage = "Reassign",
}) {
  const [confirmOpen, setConfirmOpen] = useState(false);

  return (
    <>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="icon">
            <MoreHorizontal className="h-4 w-4" />
            <span className="sr-only">Open row actions</span>
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-40">
          {onViewDetails && (
            <DropdownMenuItem onClick={() => onViewDetails?.(row)}>
              <Eye className="mr-2 h-4 w-4" /> {viewDetailsMessage}
            </DropdownMenuItem>
          )}
          {onEdit && (
            <DropdownMenuItem onClick={() => onEdit?.(row)}>
              <Pencil className="mr-2 h-4 w-4" /> {editMessage}
            </DropdownMenuItem>
          )}
          {onReassign && (
            <>
              <DropdownMenuSeparator />
              <DropdownMenuItem onClick={() => onReassign?.(row)}>
                <UserRoundCog className="mr-2 h-4 w-4" /> {reassignMessage}
              </DropdownMenuItem>
            </>
          )}
          {onDelete && (
            <>
              <DropdownMenuSeparator />
              <DropdownMenuItem
                onClick={() => setConfirmOpen(true)}
                className="text-red-500 focus:text-red-500 focus:bg-red-50"
              >
                <Trash2 className="mr-2 h-4 w-4" /> {deleteMessage}
              </DropdownMenuItem>
            </>
          )}
        </DropdownMenuContent>
      </DropdownMenu>

      <AlertDialog open={confirmOpen} onOpenChange={setConfirmOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete this item?</AlertDialogTitle>
            <AlertDialogDescription>
              This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                onDelete?.(row);
                setConfirmOpen(false);
              }}
              className={"bg-red-500"}
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
}
