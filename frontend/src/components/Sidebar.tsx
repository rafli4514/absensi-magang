import { Link, useLocation, useNavigate } from "react-router-dom";
import {
  DashboardIcon,
  FileTextIcon,
  PersonIcon,
} from "@radix-ui/react-icons";

import { LogOut, Users, CalendarDays, Clock, Settings, QrCode} from "lucide-react";
import Logo from "../assets/64eb562e223ee070362018.png";
import Logo2 from "../assets/pln-logo-png_seeklogo-355620.png"
import { cn } from "../lib/utils";

const navigation = [
  { name: "Dashboard", href: "/", icon: DashboardIcon },
  { name: "Manajemen Peserta Magang", href: "/peserta-magang", icon: Users },
  { name: "Manajemen Absensi", href: "/absensi", icon: Clock },
  { name: "Manajemen Izin", href: "/izin", icon: CalendarDays },
  { name: "QR Code & Barcode", href: "/barcode", icon: QrCode },
  { name: "Laporan Absensi", href: "/laporan", icon: FileTextIcon },
  { name: "Pengaturan", href: "/pengaturan", icon: Settings },
  { name: "Profil Pengguna", href: "/profil-pengguna", icon: PersonIcon },
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

  const handleLogout = () => {
    // Show confirmation dialog

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
          // className="fixed inset-0 bg-gray-600 bg-opacity-75 z-40 lg:hidden"
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
        <div className="flex flex-col h-full mt-5 overflow-hidden">
          {/* Logo Section */}
          <div
            className={cn(
              "flex items-center h-16 bg-primary-200 flex-shrink-0 transition-all duration-300",
              isMinimized
                ? "justify-center px-2"
                : "justify-center space-x-5 px-4"
            )}
          >
            {!isMinimized ? (
              <img src={Logo} alt="Iconnet Logo" className="h-15" />
            ) : (
              <img src={Logo2} alt="Iconnet Logo" className="h-10 mb-5  " />
            )}
          </div>

          {/* Navigation */}
          <nav className="flex-grow mt-2 px-2 overflow-hidden">
            <ul className="space-y-2 overflow-hidden">
              {navigation.map((item) => {
                const isActive = location.pathname === item.href;
                return (
                  <li key={item.name}>
                    <Link
                      to={item.href}
                      className={cn(
                        "flex items-center text-sm font-medium rounded-lg transition-all duration-200 group relative",
                        isMinimized ? "px-3 py-3 justify-center" : "px-4 py-3",
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

                      {/* Tooltip for minimized state */}
                      {isMinimized && (
                        <div className="absolute left-full ml-2 px-3 py-2 bg-gray-900 text-white text-sm rounded-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 whitespace-nowrap z-50">
                          {item.name}
                          <div className="absolute top-1/2 left-0 transform -translate-y-1/2 -translate-x-1 w-2 h-2 bg-gray-900 rotate-45"></div>
                        </div>
                      )}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </nav>

          {/* Logout Button */}
          <div className="mt-auto p-2 mb-5">
            <button
              className={cn(
                "flex items-center text-sm font-medium text-red-600 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 group relative",
                isMinimized
                  ? "w-full px-3 py-3 justify-center"
                  : "w-full px-4 py-3"
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

              {/* Tooltip for minimized state */}
              {isMinimized && (
                <div className="absolute left-full ml-2 px-3 py-2 bg-gray-900 text-white text-sm rounded-lg opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 whitespace-nowrap z-50">
                  Keluar
                  <div className="absolute top-1/2 left-0 transform -translate-y-1/2 -translate-x-1 w-2 h-2 bg-gray-900 rotate-45"></div>
                </div>
              )}
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
