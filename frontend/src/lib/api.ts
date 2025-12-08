import axios from 'axios';

// API Base URL
const API_BASE_URL = import.meta.env.BASE_URL ?? "http://localhost:3000/api";

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Helper
const clearAuth = () => {
  localStorage.removeItem("token");
  localStorage.removeItem("user");
};

// Request interceptor
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  Promise.reject
);

// Response interceptor
api.interceptors.response.use(
  (res) => res,
  (err) => {
    const status = err.response?.status;

    if (status === 401) {
      clearAuth();
      window.location.href = '/login';
    } else if (status === 403) {
      alert("Bro lu ga punya akses ke resource ini 😅");
    }

    return Promise.reject(err);
  }
);

export default api;
