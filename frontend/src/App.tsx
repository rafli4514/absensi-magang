import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Layout from "./components/Layout"
import { Theme } from "@radix-ui/themes"
import Login from "./pages/Login"
import "./App.css";

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route
          path="/"
          element={
            <Theme>
              <Layout />
            </Theme>
          }
        >
          <Route index element={<div>Home</div>} />
          <Route path="/peserta-magang" element={<div>Peserta Magang</div>} />
          <Route
            path="/peserta-magang"
            element={<div>Peserta Magang</div>}
          />{" "}
          <Route path="/absensi" element={<div>Absensi</div>} />{" "}
          <Route path="/jadwal" element={<div>Jadwal</div>} />{" "}
          <Route path="/izin" element={<div>Pengajuan Izin</div>} />{" "}
          <Route path="/laporan" element={<div>Laporan</div>} />
          <Route path="/pengaturan" element={<div>Pengaturan</div>} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
