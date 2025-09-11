import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import { Flex, Box, TextField, IconButton } from "@radix-ui/themes";
import { MagnifyingGlassIcon, DotsHorizontalIcon } from "@radix-ui/react-icons";
import Layout from "./components/Layout";
import { Theme } from "@radix-ui/themes";
import Login from "./pages/Login";
import UserManagement from "./pages/UserManagement";
import "./App.css";

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
                    <Flex direction="column" gap="3" maxWidth="400px">
                      <Box maxWidth="200px">
                        <TextField.Root placeholder="Search the docs…" size="1">
                          <TextField.Slot>
                            <MagnifyingGlassIcon height="16" width="16" />
                          </TextField.Slot>
                        </TextField.Root>
                      </Box>

                      <Box maxWidth="250px">
                        <TextField.Root placeholder="Search the docs…" size="2">
                          <TextField.Slot>
                            <MagnifyingGlassIcon height="16" width="16" />
                          </TextField.Slot>
                          <TextField.Slot>
                            <IconButton size="1" variant="ghost">
                              <DotsHorizontalIcon height="14" width="14" />
                            </IconButton>
                          </TextField.Slot>
                        </TextField.Root>
                      </Box>

                      <Box maxWidth="300px">
                        <TextField.Root placeholder="Search the docs…" size="3">
                          <TextField.Slot>
                            <MagnifyingGlassIcon height="16" width="16" />
                          </TextField.Slot>
                          <TextField.Slot pr="3">
                            <IconButton size="2" variant="ghost">
                              <DotsHorizontalIcon height="16" width="16" />
                            </IconButton>
                          </TextField.Slot>
                        </TextField.Root>
                      </Box>
                    </Flex>
                  }
                />
                <Route path="/peserta-magang" element={<UserManagement />} />
                <Route path="/absensi" element={<div>Absensi</div>} />{" "}
                <Route path="/jadwal" element={<div>Jadwal</div>} />{" "}
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
