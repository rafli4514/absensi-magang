import {
  Menu,
  Bell,
  User,
  PanelLeftOpen,
  PanelLeftClose,
  Settings,    // Ikon untuk Pengaturan
  UserCircle,  // Ikon untuk Profil
  LogOut       // Ikon untuk Keluar
} from "lucide-react";
import { useState } from "react";
import { Link } from "react-router-dom";
import { cn } from "../lib/utils"; // Pastikan utilitas cn tersedia

interface HeaderProps {
  onMenuClick: () => void;
  onToggleMinimize?: () => void;
  sidebarMinimized?: boolean;
}

// Menambahkan properti icon pada array Navigation
const Navigation = [
  { name: "Pengaturan", href: "/pengaturan", icon: Settings },
  { name: "Profil Pengguna", href: "/profil-pengguna", icon: UserCircle },
  { name: "Keluar", href: "/login", icon: LogOut }
];

export default function Header({ onMenuClick, onToggleMinimize, sidebarMinimized }: HeaderProps) {
  const [showNotifications, setShowNotifications] = useState(false);
  const [showUserMenu, setShowUserMenu] = useState(false);

  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="flex items-center justify-between px-4 py-3 lg:px-6">
        <div className="flex items-center">
          {/* Mobile menu button */}
          <button
            onClick={onMenuClick}
            className="p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100 lg:hidden"
          >
            <Menu className="h-6 w-6" />
          </button>

          {/* Desktop minimize button */}
          {onToggleMinimize && (
            <button
              onClick={onToggleMinimize}
              className="hidden lg:flex p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100 mr-3 transition-colors duration-200"
              title={`${sidebarMinimized ? "Expand" : "Minimize"} sidebar (Ctrl+B)`}
            >
              {sidebarMinimized ? (
                <PanelLeftOpen className="h-5 w-5" />
              ) : (
                <PanelLeftClose className="h-5 w-5" />
              )}
            </button>
          )}

          <h2 className="ml-2 text-lg font-semibold text-gray-900 lg:ml-0">
            Absensi Magang
          </h2>
        </div>

        <div className="flex items-center space-x-4">
          {/* Notifications ... (tetap sama) */}

          {/* User menu */}
          <div className="relative">
            <button
              onClick={() => setShowUserMenu(!showUserMenu)}
              className="flex items-center p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100"
            >
              <User className="h-6 w-6" />
              <span className="ml-2 text-sm font-medium hidden sm:block">
                Admin
              </span>
            </button>

            {showUserMenu && (
              <div className="absolute right-0 mt-2 w-52 bg-white rounded-lg shadow-lg border border-gray-200 z-50">
                <div className="p-2">
                  <ul className="space-y-1">
                    {Navigation.map((item) => {
                      const isLogout = item.name === "Keluar";
                      const Icon = item.icon; // Ambil komponen ikon
                      return (
                        <li key={item.name}>
                          {isLogout && <div className="border-t border-gray-200 my-1"></div>}
                          <Link
                            to={item.href}
                            className={`flex items-center px-4 py-2.5 text-sm font-medium rounded-lg transition-colors duration-200 ${
                              isLogout
                                ? "text-red-600 hover:bg-red-50 hover:text-red-700"
                                : "text-gray-700 hover:bg-gray-100 hover:text-gray-900"
                            }`}
                            onClick={() => setShowUserMenu(false)}
                          >
                            {/* Menampilkan Ikon di sebelah teks */}
                            <Icon className={cn(
                              "h-4 w-4 mr-3",
                              isLogout ? "text-red-500" : "text-gray-400"
                            )} />
                            {item.name}
                          </Link>
                        </li>
                      );
                    })}
                  </ul>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}