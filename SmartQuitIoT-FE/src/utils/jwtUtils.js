import { jwtDecode } from "jwt-decode";

export const isAuthenticated = () => {
  const token = localStorage.getItem("accessToken");
  return !!token;
};

export const isAuthenticatedRole = (role) => {
  const token = localStorage.getItem("accessToken");
  if (!token) return false;
  const payload = jwtDecode(token);
  return payload?.scope === role;
};
