import { Link, useLocation, useNavigate } from "react-router-dom";
import {
  DashboardIcon,
  FileTextIcon,
  PersonIcon,
} from "@radix-ui/react-icons";

import { LogOut, Users, CalendarDays, Clock, Settings, QrCode } from "lucide-react";
import Logo from "../assets/64eb562e223ee070362018.png";
import Logo2 from "../assets/pln-logo-png_seeklogo-355620.png";
import { cn } from "../lib/utils";
import authService from "../services/authService";

// REORDERED NAVIGATION BASED ON ADMIN PRIORITY
const navigation = [
  // 1. Overview (Ringkasan)
  { name: "Dashboard", href: "/", icon: DashboardIcon, requiredRole: null as string | null },
  
  // 2. Core Operations (Paling sering dipantau harian)
  { name: "Manajemen Absensi", href: "/absensi", icon: Clock, requiredRole: null },
  { name: "Manajemen Izin", href: "/izin", icon: CalendarDays, requiredRole: null },
  
  // 3. Reporting (Output data)
  { name: "Laporan Absensi", href: "/laporan", icon: FileTextIcon, requiredRole: null },
  
  // 4. Data Management (Setup data)
  { name: "Manajemen User", href: "/manage-users", icon: Users, requiredRole: null },
  
  // 5. Admin Tools
  { name: "QR Code Check-In", href: "/barcode", icon: QrCode, requiredRole: "ADMIN" },
  
  // 6. Configuration (Jarang diakses)
  { name: "Pengaturan", href: "/pengaturan", icon: Settings, requiredRole: "ADMIN" },
  { name: "Profil Pengguna", href: "/profil-pengguna", icon: PersonIcon, requiredRole: null },
];

interface SidebarProps {
  isOpen: boolean;
  isMinimized: boolean;
  onClose: () => void;
  onToggleMinimize: () => void;
}

export default function Sidebar({ isOpen, isMinimized, onClose }: SidebarProps) {
  const location = useLocation();
  const navigate = useNavigate();
  const currentUser = authService.getCurrentUser();

  const handleLogout = () => {
    // Clear authentication data
    localStorage.removeItem('authToken');
    localStorage.removeItem('userData');
    localStorage.removeItem('isAuthenticated');
    sessionStorage.clear();

    // Close mobile sidebar if open
    onClose();

    // Redirect to login page
    navigate('/login');

    // Optional: Show success message
    console.log('User logged out successfully');
  };

  return (
    <>
      {/* Mobile backdrop */}
      {isOpen && (
        <div
          className="fixed inset-0 bg-gray-600 bg-opacity-75 z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <div
        className={cn(
          "fixed inset-y-0 left-0 z-50 bg-white shadow-lg transform transition-all duration-300 ease-in-out lg:translate-x-0 lg:static lg:h-screen overflow-hidden",
          isOpen ? "translate-x-0" : "-translate-x-full",
          isMinimized ? "lg:w-16 w-16" : "lg:w-64 w-64"
        )}
      >
        {/* COMPACT CHANGE 1: Ubah mt-5 jadi py-2 agar tidak terlalu turun */}
        <div className="flex flex-col h-full py-2 overflow-hidden">
          {/* Logo Section */}
          <div
            className={cn(
              "flex items-center h-14 bg-primary-200 flex-shrink-0 transition-all duration-300", // Ubah h-16 jadi h-14
              isMinimized
                ? "justify-center px-2"
                : "justify-center space-x-5 px-4"
            )}
          >
            {!isMinimized ? (
              <img src={Logo} alt="Iconnet Logo" className="h-12 object-contain" /> // Sesuaikan tinggi logo
            ) : (
              // COMPACT CHANGE 2: Kurangi margin bottom logo
              <img src={Logo2} alt="Iconnet Logo" className="h-8 mb-2 object-contain" /> 
            )}
          </div>

          {/* Navigation */}
          <nav className="flex-grow mt-2 px-2 overflow-y-auto no-scrollbar">
            {/* COMPACT CHANGE 3: Ubah space-y-2 jadi space-y-1 (jarak antar item lebih rapat) */}
            <ul className="space-y-1">
              {navigation
                .filter((item) => {
                  if (item.requiredRole === null) return true;
                  if (item.requiredRole === "ADMIN" && currentUser?.role === "ADMIN") return true;
                  return false;
                })
                .map((item) => {
                  const isActive = location.pathname === item.href || 
                    (item.href === "/manage-users" && (location.pathname === "/peserta-magang" || location.pathname === "/manage-users"));
                  return (
                    <li key={item.name}>
                      <Link
                        to={item.href}
                        className={cn(
                          "flex items-center text-sm font-medium rounded-lg transition-all duration-200 group relative",
                          // COMPACT CHANGE 4: Ubah py-3 jadi py-2 (tombol lebih tipis)
                          isMinimized ? "px-2 py-2 justify-center" : "px-4 py-2",
                          isActive
                            ? "bg-blue-500 text-amber-50"
                            : "text-gray-500 hover:bg-gray-100 hover:text-black"
                        )}
                        onClick={onClose}
                        title={isMinimized ? item.name : ""}
                      >
                        <item.icon
                          className={cn(
                            "h-5 w-5 flex-shrink-0",
                            isMinimized ? "" : "mr-3"
                          )}
                        />
                        {!isMinimized && (
                          <span className="truncate">{item.name}</span>
                        )}
                      </Link>
                    </li>
                  );
                })}
            </ul>
          </nav>

          {/* Logout Button */}
          {/* COMPACT CHANGE 5: Kurangi margin bottom mb-5 jadi mb-2 */}
          <div className="mt-auto p-2 mb-2">
            <button
              className={cn(
                "flex items-center text-sm font-medium text-red-600 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 group relative",
                // COMPACT CHANGE 6: Ubah py-3 jadi py-2
                isMinimized
                  ? "w-full px-2 py-2 justify-center"
                  : "w-full px-4 py-2"
              )}
              onClick={handleLogout}
              title={isMinimized ? "Keluar" : ""}
            >
              <LogOut
                className={cn(
                  "h-5 w-5 flex-shrink-0",
                  isMinimized ? "" : "mr-3"
                )}
              />
              {!isMinimized && <span>Keluar</span>}
            </button>
          </div>
        </div>
      </div>
    </>
  );
}