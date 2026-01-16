import {
  Menu,
  PanelLeftOpen,
  PanelLeftClose,
  Settings,
  UserCircle,
  LogOut,
  User as UserIcon
} from "lucide-react";
import { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { cn } from "../lib/utils";
import Avatar from "./Avatar";
import authService from "../services/authService";
import type { User } from "../types";

interface HeaderProps {
  onMenuClick: () => void;
  onToggleMinimize?: () => void;
  sidebarMinimized?: boolean;
}

const Navigation = [
  { name: "Pengaturan", href: "/pengaturan", icon: Settings },
  { name: "Profil Pengguna", href: "/profil-pengguna", icon: UserCircle },
  { name: "Keluar", href: "/login", icon: LogOut }
];

export default function Header({ onMenuClick, onToggleMinimize, sidebarMinimized }: HeaderProps) {
  const [showUserMenu, setShowUserMenu] = useState(false);
  const [currentUser, setCurrentUser] = useState<User | null>(authService.getCurrentUser());

  // FIX: Fetch profile on mount to sync changes made on other devices (like Mobile)
  // This ensures the Avatar is up-to-date even if the user didn't re-login.
  useEffect(() => {
    authService.getProfile().then((response) => {
      if (response.success && response.data) {
        setCurrentUser(response.data);
      }
    }).catch(console.error);
  }, []);

  return (
    <header className="bg-white shadow-sm border-b border-gray-200 z-10">
      <div className="flex items-center justify-between px-4 py-3 lg:px-6">
        <div className="flex items-center gap-2">
          {/* Mobile menu button */}
          <button
            onClick={onMenuClick}
            className="p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100 lg:hidden focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            <Menu className="h-6 w-6" />
          </button>

          {/* Desktop minimize button */}
          {onToggleMinimize && (
            <button
              onClick={onToggleMinimize}
              className="hidden lg:flex p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100 transition-colors duration-200 focus:outline-none focus:ring-2 focus:ring-indigo-500"
              title={`${sidebarMinimized ? "Expand" : "Minimize"} sidebar (Ctrl+B)`}
            >
              {sidebarMinimized ? (
                <PanelLeftOpen className="h-5 w-5" />
              ) : (
                <PanelLeftClose className="h-5 w-5" />
              )}
            </button>
          )}

          <h2 className="text-lg font-semibold text-gray-900">
            Absensi Magang
          </h2>
        </div>

        <div className="flex items-center space-x-4">
          {/* User menu */}
          <div className="relative">
            <button
              onClick={() => setShowUserMenu(!showUserMenu)}
              className="flex items-center p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            >
              <Avatar
                src={currentUser?.avatar}
                name={currentUser?.username || "Admin"}
                alt="Profile"
                size="sm"
                className="mr-2"
                showBorder={false}
              />
              <span className="text-sm font-medium hidden sm:block">
                {currentUser?.username || "Admin"}
              </span>
            </button>

            {showUserMenu && (
              <>
                {/* Backdrop to close menu when clicking outside */}
                <div
                  className="fixed inset-0 z-40"
                  onClick={() => setShowUserMenu(false)}
                />

                <div className="absolute right-0 mt-2 w-56 bg-white rounded-lg shadow-lg border border-gray-200 z-50 py-1 animate-in fade-in zoom-in-95 duration-100">
                  <div className="px-4 py-2 border-b border-gray-100">
                    <p className="text-sm font-medium text-gray-900">
                      {currentUser?.role === 'PESERTA_MAGANG' ? 'Peserta Magang' : (currentUser?.role || 'Admin')}
                    </p>
                    <p className="text-xs text-gray-500 truncate" title={currentUser?.username}>
                      @{currentUser?.username || 'admin'}
                    </p>
                  </div>
                  <ul className="p-1">
                    {Navigation.map((item) => {
                      const isLogout = item.name === "Keluar";
                      const Icon = item.icon;
                      return (
                        <li key={item.name}>
                          {isLogout && <div className="border-t border-gray-100 my-1"></div>}
                          <Link
                            to={item.href}
                            className={cn(
                              "flex items-center px-3 py-2 text-sm font-medium rounded-md transition-colors duration-200",
                              isLogout
                                ? "text-red-600 hover:bg-red-50"
                                : "text-gray-700 hover:bg-gray-100"
                            )}
                            onClick={() => setShowUserMenu(false)}
                          >
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
              </>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}