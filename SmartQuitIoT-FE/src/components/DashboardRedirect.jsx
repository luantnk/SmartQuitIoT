import { isAuthenticated, isAuthenticatedRole } from "@/utils/jwtUtils";
import { Navigate } from "react-router-dom";

export default function DashboardRedirect() {
    if (!isAuthenticated() || !isAuthenticatedRole("ADMIN") || !isAuthenticatedRole("COACH")) {
        return <Navigate to="/login" replace />;
    }
    if (isAuthenticatedRole("ADMIN")) return <Navigate to="/admin" replace />;
    if (isAuthenticatedRole("COACH")) return <Navigate to="/coach" replace />;
    return <Navigate to="/login" replace />;
}