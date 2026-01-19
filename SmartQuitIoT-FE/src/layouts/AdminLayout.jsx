import AdminSidebar from "@/components/ui/admin-sidebar";
import {
  SidebarProvider,
  SidebarRefreshButton,
  SidebarTrigger,
} from "@/components/ui/sidebar";
import { Navigate, Outlet } from "react-router-dom";

import { isAuthenticated, isAuthenticatedRole } from "@/utils/jwtUtils";

const AdminLayout = () => {
  if (!isAuthenticated() || !isAuthenticatedRole("ADMIN")) {
    return <Navigate to="/login" replace />;
  }

  return (
    <SidebarProvider>
      <AdminSidebar />
      <div className="w-full">
        <SidebarTrigger />
        <SidebarRefreshButton />
        <Outlet />
      </div>
    </SidebarProvider>
  );
};

export default AdminLayout;
