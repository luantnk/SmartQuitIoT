import React from "react";
import { Navigate, Outlet } from "react-router-dom";

const getAccessToken = () => {
  return localStorage.getItem("accessToken");
};

const isAuthenticated = () => {
  return !!getAccessToken();
};

const ProtectedRoutes = () => {
  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
};

export default ProtectedRoutes;
