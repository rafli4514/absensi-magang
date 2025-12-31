import { useState } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import {
  DashboardIcon,
  FileTextIcon,
  ChevronDownIcon,
  ChevronUpIcon,
} from "@radix-ui/react-icons";

import {
  LogOut,
  Users,
  CalendarDays,
  Clock,
  Settings,
  QrCode,
  Server,
  LayoutDashboard
} from "lucide-react";
import Logo from "../assets/64eb562e223ee070362018.png";
import Logo2 from "../assets/pln-logo-png_seeklogo-355620.png";
import { cn } from "../lib/utils";
import authService from "../services/authService";

// Definisi Tipe Navigasi
type NavItem = {
  name: string;
  href?: string;
  icon: any;
  requiredRole: string | null;
  children?: { name: string; href: string; icon: any }[];
};

// Konfigurasi Menu
const navigation: NavItem[] = [
  {
    name: "Dashboard",
    icon: LayoutDashboard,
    requiredRole: null,
    children: [
      { name: "User Monitoring", href: "/", icon: Users },
      { name: "Server Monitoring", href: "/dashboard/server", icon: Server }
    ]
  },
  { name: "Manajemen Absensi", href: "/absensi", icon: Clock, requiredRole: null },
  { name: "Manajemen Izin", href: "/izin", icon: CalendarDays, requiredRole: null },
  { name: "Laporan Absensi", href: "/laporan", icon: FileTextIcon, requiredRole: null },
  { name: "Manajemen User", href: "/manage-users", icon: Users, requiredRole: null },
  { name: "QR Code Check-In", href: "/barcode", icon: QrCode, requiredRole: "ADMIN" },
  { name: "Pengaturan", href: "/pengaturan", icon: Settings, requiredRole: "ADMIN" },
  // "Profil Pengguna" dihapus karena sudah ada di Navbar
];

interface SidebarProps {
  isOpen: boolean;
  isMinimized: boolean;
  onClose: () => void;
  onToggleMinimize: () => void;
}

export default function Sidebar({ isOpen, isMinimized, onClose, onToggleMinimize }: SidebarProps) {
  const location = useLocation();
  const navigate = useNavigate();
  const currentUser = authService.getCurrentUser();

  // Default expanded "Dashboard" agar user langsung melihat sub-menu
  const [expandedMenus, setExpandedMenus] = useState<string[]>(["Dashboard"]);

  const isActive = (href: string) => location.pathname === href;

  const isParentActive = (item: NavItem) => {
    if (item.href && isActive(item.href)) return true;
    if (item.children) {
      return item.children.some(child => isActive(child.href));
    }
    return false;
  };

  const handleParentClick = (item: NavItem) => {
    if (isMinimized) {
      onToggleMinimize();
      if (!expandedMenus.includes(item.name)) {
        setExpandedMenus([...expandedMenus, item.name]);
      }
      return;
    }

    if (expandedMenus.includes(item.name)) {
      setExpandedMenus(expandedMenus.filter(name => name !== item.name));
    } else {
      setExpandedMenus([...expandedMenus, item.name]);
    }
  };

  const handleLogout = () => {
    authService.logout();
    navigate('/login');
  };

  return (
    <>
      {isOpen && (
        <div
          className="fixed inset-0 bg-gray-600 bg-opacity-75 z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      <div
        className={cn(
          "fixed inset-y-0 left-0 z-50 bg-white shadow-lg transform transition-all duration-300 ease-in-out lg:translate-x-0 lg:static lg:h-screen overflow-hidden flex flex-col",
          isOpen ? "translate-x-0" : "-translate-x-full",
          isMinimized ? "lg:w-20 w-20" : "lg:w-64 w-64"
        )}
      >
        {/* Header Logo */}
        <div className="flex items-center justify-center h-16 bg-white border-b border-gray-100 flex-shrink-0">
          {!isMinimized ? (
            <img src={Logo} alt="Iconnet Logo" className="h-10 object-contain" />
          ) : (
            <img src={Logo2} alt="PLN Logo" className="h-8 object-contain" />
          )}
        </div>

        {/* Menu Items */}
        <nav className="flex-grow mt-4 px-3 overflow-y-auto no-scrollbar">
          <ul className="space-y-1">
            {navigation
              .filter((item) => {
                if (item.requiredRole === null) return true;
                if (item.requiredRole === "ADMIN" && currentUser?.role === "ADMIN") return true;
                return false;
              })
              .map((item) => {
                const active = isParentActive(item);
                const expanded = expandedMenus.includes(item.name);
                const hasChildren = item.children && item.children.length > 0;

                return (
                  <li key={item.name} className="relative">
                    {/* Parent Menu */}
                    <div
                      onClick={() => hasChildren ? handleParentClick(item) : navigate(item.href!)}
                      className={cn(
                        "flex items-center text-sm font-medium rounded-lg transition-all duration-200 cursor-pointer group select-none",
                        isMinimized ? "justify-center px-2 py-3" : "px-3 py-2.5",
                        // Logic warna parent
                        active && !hasChildren ? "bg-blue-600 text-white shadow-md" : "text-gray-600 hover:bg-gray-50 hover:text-gray-900",
                        active && hasChildren && !isMinimized ? "bg-blue-50 text-blue-700" : ""
                      )}
                      title={isMinimized ? item.name : ""}
                    >
                      <item.icon
                        className={cn(
                          "flex-shrink-0 transition-colors",
                          isMinimized ? "h-6 w-6" : "h-5 w-5 mr-3",
                          // Icon parent active -> white, inactive -> gray/blue
                          active && !hasChildren ? "text-white" : (active ? "text-blue-600" : "text-gray-400 group-hover:text-gray-600")
                        )}
                      />

                      {!isMinimized && (
                        <>
                          <span className="flex-1 truncate">{item.name}</span>
                          {hasChildren && (
                            <span className="ml-auto">
                              {expanded ? <ChevronUpIcon className="w-4 h-4" /> : <ChevronDownIcon className="w-4 h-4" />}
                            </span>
                          )}
                        </>
                      )}
                    </div>

                    {/* Sub Menu (Children) */}
                    {hasChildren && expanded && !isMinimized && (
                      <ul className="mt-1 ml-4 space-y-1 border-l-2 border-gray-100 pl-2 animate-in slide-in-from-top-2 duration-200">
                        {item.children!.map((child) => {
                          const isChildActive = isActive(child.href);
                          return (
                            <li key={child.name}>
                              <Link
                                to={child.href}
                                onClick={onClose}
                                className={cn(
                                  "flex items-center px-3 py-2 text-sm rounded-md transition-all",
                                  isChildActive
                                    ? "bg-blue-600 text-white font-medium shadow-sm"
                                    : "text-gray-500 hover:text-gray-900 hover:bg-gray-50"
                                )}
                              >
                                {child.icon && (
                                  <child.icon
                                    className={cn(
                                      "h-4 w-4 mr-2",
                                      isChildActive ? "text-white" : "text-gray-400"
                                    )}
                                  />
                                )}
                                {child.name}
                              </Link>
                            </li>
                          );
                        })}
                      </ul>
                    )}
                  </li>
                );
              })}
          </ul>
        </nav>

        {/* Footer (User Info Removed, only Logout remains) */}
        <div className="p-4 border-t border-gray-100 mt-auto bg-gray-50/50">
          <button
            className={cn(
              "flex items-center text-sm font-medium text-red-600 rounded-lg hover:bg-red-50 hover:text-red-700 transition-all duration-200 w-full",
              isMinimized ? "justify-center py-3" : "px-4 py-2"
            )}
            onClick={handleLogout}
            title="Keluar"
          >
            <LogOut className={cn("h-5 w-5 flex-shrink-0", isMinimized ? "" : "mr-3")} />
            {!isMinimized && <span>Keluar</span>}
          </button>
        </div>
      </div>
    </>
  );
}