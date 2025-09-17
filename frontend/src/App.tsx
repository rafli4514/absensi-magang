import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Layout from "./components/Layout";
import ProtectedRoute from "./components/ProtectedRoute";
import { Theme } from "@radix-ui/themes";
import Login from "./pages/LoginPage";
import UserManagementPage from "./pages/UserManagementPage";
import AbsensiPage from "./pages/AbsensiPage";
import "./App.css";
import DashboardPage from "./pages/DashboardPage";
import PengajuanIzinPage from "./pages/PengajuanIzinPage";
import LaporanPage from "./pages/LaporanPage";
import PengaturanPage from "./pages/PengaturanPage";
import ProfilPage from "./pages/ProfilPage";
import ProfilPesertaMagangPage from "./pages/ProfilPesertaMagangPage";
import BarcodePage from "./pages/BarcodePage";

function App() {
  return (
    <Theme>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<DashboardPage />} />
            <Route path="/peserta-magang" element={<UserManagementPage />} />
            <Route path="/absensi" element={<AbsensiPage />} />
            <Route path="/izin" element={<PengajuanIzinPage />} />
            <Route path="/laporan" element={<LaporanPage />} />

            <Route
              path="/pengaturan"
              element={
                <ProtectedRoute requiredRole="ADMIN">
                  <PengaturanPage />
                </ProtectedRoute>
              }
            />
            <Route
              path="/barcode"
              element={
                <ProtectedRoute requiredRole="ADMIN">
                  <BarcodePage />
                </ProtectedRoute>
              }
            />

            <Route path="/profil-pengguna" element={<ProfilPage />} />
            <Route
              path="/profil-peserta/:id"
              element={<ProfilPesertaMagangPage />}
            />
          </Route>
        </Routes>
      </Router>
    </Theme>
  );
}

export default App;
