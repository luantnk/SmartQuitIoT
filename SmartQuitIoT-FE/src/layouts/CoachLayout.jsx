// src/layouts/CoachLayout.jsx
import CoachSidebar from "@/components/ui/coach-sidebar/CoachSidebar";
import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar";
import { Navigate, Outlet } from "react-router-dom";

import { isAuthenticated, isAuthenticatedRole } from "@/utils/jwtUtils";
import FloatingNotifications from "@/components/FloatingNotifications";

const CoachLayout = () => {
  if (!isAuthenticated() || !isAuthenticatedRole("COACH")) {
    return <Navigate to="/login" replace />;
  }

  return (
    <SidebarProvider>
      {/* <FloatingNotifications /> */}
      <CoachSidebar />

      <div className="w-full min-h-screen flex flex-col">
        <SidebarTrigger />

        {/* main: chiếm phần còn lại, cuộn nội bộ */}
        <main className="p-2 flex-1 overflow-y-auto">
          <Outlet />
        </main>
      </div>
    </SidebarProvider>
  );
};

export default CoachLayout;
