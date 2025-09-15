import { Link, useLocation, useNavigate } from "react-router-dom";
import {
  DashboardIcon,
  FileTextIcon,
  PersonIcon,
} from "@radix-ui/react-icons";

import { LogOut, Users, CalendarDays, Clock, Settings } from "lucide-react";
import Logo from "../assets/64eb562e223ee070362018.png";
import { cn } from "../lib/utils";

const navigation = [
  { name: "Dashboard", href: "/", icon: DashboardIcon },
  { name: "Manajemen Peserta Magang", href: "/peserta-magang", icon: Users },
  { name: "Manajemen Absensi", href: "/absensi", icon: Clock },
  { name: "Manajemen Izin", href: "/izin", icon: CalendarDays },
  { name: "Laporan Absensi", href: "/laporan", icon: FileTextIcon },
  { name: "Pengaturan", href: "/pengaturan", icon: Settings },
  { name: "Profil Pengguna", href: "/profil-pengguna", icon: PersonIcon },
];

interface SidebarProps {
  isOpen: boolean;
  onClose: () => void;
}

export default function Sidebar({ isOpen, onClose }: SidebarProps) {
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
          className="fixed inset-0 bg-gray-600 bg-opacity-75 z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      {/* Sidebar */}
      <div
        className={cn(
          "fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:h-screen overflow-hidden",
          isOpen ? "translate-x-0" : "-translate-x-full"
        )}
      >
        <div className="flex flex-col h-full mt-5 overflow-hidden">
          <div className="flex items-center justify-center h-16 bg-primary-200 space-x-5 flex-shrink-0">
            <img src={Logo} alt="Iconnet Logo" className="h-15" />
          </div>

          {/* <div className="h-0.5 bg-black mx-6" /> */}

          <nav className="flex-grow mt-5 px-4 overflow-hidden">
            <ul className="space-y-2 overflow-hidden">
              {navigation.map((item) => {
                const isActive = location.pathname === item.href;
                return (
                  <li key={item.name}>
                    <Link
                      to={item.href}
                      className={cn(
                        "flex items-center px-4 py-3 text-sm font-medium rounded-lg transition-colors duration-200",
                        isActive
                          ? "bg-blue-500 text-amber-50"
                          : "text-gray-500 hover:bg-gray-100 hover:text-black"
                      )}
                      onClick={onClose}
                    >
                      <item.icon className="mr-3 h-5 w-5" />
                      {item.name}
                    </Link>
                  </li>
                );
              })}
            </ul>
          </nav>

          <div className="mt-auto p-4">
            <button
              className="flex items-center w-full px-4 py-3 text-sm font-medium text-red-600 rounded-lg hover:bg-red-50 hover:text-red-700 transition-colors duration-200"
              onClick={handleLogout}
            >
              <LogOut className="mr-3 h-5 w-5" />
              Keluar
            </button>
          </div>
        </div>
      </div>
    </>
  );
}
