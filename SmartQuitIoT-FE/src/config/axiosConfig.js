// src/config/axiosConfig.js
import axios from "axios";

const raw = import.meta.env.VITE_URL_API || "http://localhost:8080/api";
const baseURL = String(raw).replace(/\/+$/, ""); // remove trailing slash

const instance = axios.create({
  baseURL, // e.g. http://localhost:8080/api
  headers: { "Content-Type": "application/json" },
});

instance.interceptors.request.use(
  (config) => {
    const accessToken =
      localStorage.getItem("accessToken") ||
      localStorage.getItem("access_token");
    if (accessToken) config.headers.Authorization = `Bearer ${accessToken}`;
    return config;
  },
  (error) => Promise.reject(error)
);

instance.interceptors.response.use(
  (r) => {
    return r;
  },
  async (err) => {
    const originalRequest = err.config;
    
    // Bỏ qua nếu không có response (network error) hoặc đã retry
    if (!err.response || originalRequest._retry) {
      return Promise.reject(err);
    }

    if (err.response.status === 401) {
      originalRequest._retry = true;
      const refreshToken = localStorage.getItem("refreshToken");
      
      if (!refreshToken) {
        // Không có refresh token → redirect login
        localStorage.clear();
        window.location.href = "/login";
        return Promise.reject(err);
      }
    
      try {
        //  Dùng axios.create() mới để tránh trigger interceptor
        const refreshInstance = axios.create({ baseURL });
        const response = await refreshInstance.post(`/auth/refresh`, {
          refreshToken: refreshToken,
        });

        // Lưu token mới
        localStorage.setItem("accessToken", response.data.accessToken);
        localStorage.setItem("refreshToken", response.data.refreshToken);

        // Retry request gốc với token mới
        originalRequest.headers.Authorization = `Bearer ${response.data.accessToken}`;
        return instance(originalRequest);
      } catch (refreshError) {
        // Refresh token failed → logout
        localStorage.removeItem("accessToken");
        localStorage.removeItem("refreshToken");
        localStorage.clear();
        window.location.href = "/login";
        return Promise.reject(refreshError);
      }
    }
    
    return Promise.reject(err);
  }
);

export default instance;
