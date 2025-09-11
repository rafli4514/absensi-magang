import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Layout from "./components/Layout";
import { Theme } from "@radix-ui/themes";
import Login from "./pages/LoginPage";
import UserManagementPage from "./pages/UserManagementPage";
import AbsensiPage from "./pages/AbsensiPage";
import "./App.css";
import JadwalPage from "./pages/JadwalPage";
import DashboardPage from "./pages/DashboardPage";

function App() {
  return (
        <Theme>
          <Router>
            <Routes>
              <Route path="/login" element={<Login />} />
              <Route path="/" element={<Layout />}>
                <Route
                  index
                  element={
                    <DashboardPage />
                  }
                />
                <Route path="/peserta-magang" element={<UserManagementPage />} />
                <Route path="/absensi" element={<AbsensiPage />} />{" "}
                <Route path="/jadwal" element={<JadwalPage />} />{" "}
                <Route path="/izin" element={<div>Pengajuan Izin</div>} />{" "}
                <Route path="/laporan" element={<div>Laporan</div>} />
                <Route path="/pengaturan" element={<div>Pengaturan</div>} />
              </Route>
            </Routes>
          </Router>
        </Theme>
  );
}

export default App;
