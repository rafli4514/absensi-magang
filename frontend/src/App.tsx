import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Layout from "./components/Layout";
import { Theme } from "@radix-ui/themes";
import Login from "./pages/LoginPage";
import UserManagementPage from "./pages/UserManagementPage";
import AbsensiPage from "./pages/AbsensiPage";
import "./App.css";
import DashboardPage from "./pages/DashboardPage";
import PengajuanIzinPage from "./pages/PengajuanIzinPage";
import LaporanPage from "./pages/LaporanPage";
import PengaturanPage from "./pages/PengaturanPage";

function App() {
  return (
    <Theme>
      <Router>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/" element={<Layout />}>
            <Route index element={<DashboardPage />} />
            <Route path="/peserta-magang" element={<UserManagementPage />} />
            <Route path="/absensi" element={<AbsensiPage />} />{" "}
            <Route path="/izin" element={<PengajuanIzinPage />} />{" "}
            <Route path="/laporan" element={<LaporanPage />} />
            <Route path="/pengaturan" element={<PengaturanPage />} />
            <Route path="/profil-pengguna" element={<div>profil</div>} />
          </Route>
        </Routes>
      </Router>
    </Theme>
  );
}

export default App;
