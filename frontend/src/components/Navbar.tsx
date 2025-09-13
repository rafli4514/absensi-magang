import { Menu, Bell, User } from "lucide-react";
import { useState } from "react";
import { Link } from "react-router-dom";

interface HeaderProps {
  onMenuClick: () => void;
}

const Navigation = [
  { name: "Pengaturan", href: "/pengaturan"},
  { name: "Profil Pengguna", href: "/profil-pengguna" },
  { name: "Keluar", href: "/login" }
];
export default function Header({ onMenuClick }: HeaderProps) {
  const [showNotifications, setShowNotifications] = useState(false);
  const [showUserMenu, setShowUserMenu] = useState(false);

  return (
    <header className="bg-white shadow-sm border-b border-gray-200">
      <div className="flex items-center justify-between px-4 py-3 lg:px-6">
        <div className="flex items-center">
          <button
            onClick={onMenuClick}
            className="p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100 lg:hidden"
          >
            <Menu className="h-6 w-6" />
          </button>
          <h2 className="ml-2 text-lg font-semibold text-gray-900 lg:ml-0">
            Absensi Magang
          </h2>
        </div>

        <div className="flex items-center space-x-4">
          {/* Notifications */}
          <div className="relative">
            <button
              onClick={() => setShowNotifications(!showNotifications)}
              className="p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-100 relative"
            >
              <Bell className="h-6 w-6" />
              <span className="absolute top-1 right-1 h-2 w-2 bg-danger-500 rounded-full"></span>
            </button>

            {showNotifications && (
              <div className="absolute right-0 mt-2 w-80 bg-white rounded-lg shadow-lg border border-gray-200 z-50">
                <div className="p-4 border-b border-gray-200">
                  <h3 className="text-sm font-medium text-gray-900">
                    Notifikasi
                  </h3>
                </div>
                <div className="max-h-64 overflow-y-auto">
                  <div className="p-4 border-b border-gray-100">
                    <p className="text-sm text-gray-600">
                      Siswa John Doe melakukan absensi terlambat
                    </p>
                    <p className="text-xs text-gray-400 mt-1">
                      5 menit yang lalu
                    </p>
                  </div>
                  <div className="p-4 border-b border-gray-100">
                    <p className="text-sm text-gray-600">
                      Laporan absensi bulan ini telah siap
                    </p>
                    <p className="text-xs text-gray-400 mt-1">
                      1 jam yang lalu
                    </p>
                  </div>
                </div>
                <div className="p-3 border-t border-gray-200">
                  <button className="text-sm text-primary-600 hover:text-primary-700">
                    Lihat semua notifikasi
                  </button>
                </div>
              </div>
            )}
          </div>

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
              <div className="absolute right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-200 z-50">
                <div className="p-2">
                  <ul className="space-y-1">
                    {Navigation.map((item) => {
                      const isLogout = item.name === "Keluar";
                      return (
                        <li key={item.name}>
                          {isLogout && <div className="border-t border-gray-200 my-1"></div>}
                          <Link
                            to={item.href}
                            className={`flex items-center px-4 py-2 text-sm font-medium rounded-lg transition-colors duration-200 ${
                              isLogout 
                                ? "text-red-600 hover:bg-red-50 hover:text-red-700" 
                                : "text-gray-700 hover:bg-gray-100 hover:text-gray-900"
                            }`}
                            onClick={() => setShowUserMenu(false)}
                          >
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
