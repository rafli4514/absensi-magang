import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { Theme } from "@radix-ui/themes";
import "./App.css";

// Components
import Layout from "./components/Layout";
import ProtectedRoute from "./components/ProtectedRoute";

// Pages
import Login from "./pages/LoginPage";
import UserDashboardPage from "./pages/DashboardPage";
import ServerDashboardPage from "./pages/ServerDashboardPage";
import KehadiranPage from "./pages/KehadiranPage";
import LaporanPage from "./pages/LaporanPage";
import UserManagementPage from "./pages/UserManagementPage";
import PengaturanPage from "./pages/PengaturanPage";
import ProfilPage from "./pages/ProfilPage";
import ProfilPesertaMagangPage from "./pages/ProfilPesertaMagangPage";
import BarcodePage from "./pages/BarcodePage";
import ActivityLogPage from "./pages/ActivityLogPage";

function App() {
  return (
    <Theme>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />

          {/* Main Layout dengan Proteksi */}
          <Route
            path="/"
            element={
              <ProtectedRoute allowedRoles={['ADMIN', 'PEMBIMBING_MAGANG']}>
                <Layout />
              </ProtectedRoute>
            }
          >
            {/* Dashboard Routing */}
            <Route index element={<UserDashboardPage />} />
            <Route path="dashboard/server" element={<ServerDashboardPage />} />

            {/* MODUL KEHADIRAN (Unified) */}
            <Route path="kehadiran" element={<KehadiranPage />} />

            {/* Route lama Absensi & Izin dihapus/di-redirect jika perlu */}
            {/* <Route path="absensi" element={<AbsensiPage />} /> */}
            {/* <Route path="izin" element={<PengajuanIzinPage />} /> */}

            <Route path="laporan" element={<LaporanPage />} />
            <Route path="activity-log" element={<ActivityLogPage />} />

            {/* User Management */}
            <Route path="manage-users" element={<UserManagementPage />} />
            <Route path="peserta-magang" element={<UserManagementPage />} />

            {/* Profile Detail */}
            <Route path="profil-pengguna" element={<ProfilPage />} />
            <Route path="profil-peserta/:id" element={<ProfilPesertaMagangPage />} />

            {/* Admin Only Routes */}
            <Route
              path="pengaturan"
              element={
                <ProtectedRoute requiredRole="ADMIN">
                  <PengaturanPage />
                </ProtectedRoute>
              }
            />
            <Route
              path="barcode"
              element={
                <ProtectedRoute requiredRole="ADMIN">
                  <BarcodePage />
                </ProtectedRoute>
              }
            />
          </Route>
        </Routes>
      </Router>
    </Theme>
  );
}

export default App;