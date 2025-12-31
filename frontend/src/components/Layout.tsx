import { useState, useEffect } from "react";
import { Outlet } from "react-router-dom";
import Sidebar from "./Sidebar";
import Header from "./Navbar"; // Pastikan Navbar Anda tidak double dengan Sidebar

export default function Layout() {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarMinimized, setSidebarMinimized] = useState(() => {
    // Load from localStorage
    const saved = localStorage.getItem('sidebarMinimized');
    return saved ? JSON.parse(saved) : false;
  });

  useEffect(() => {
    localStorage.setItem('sidebarMinimized', JSON.stringify(sidebarMinimized));
  }, [sidebarMinimized]);

  return (
    <div className="flex h-screen bg-gray-50 overflow-hidden">
      {/* Sidebar */}
      <Sidebar
        isOpen={sidebarOpen}
        isMinimized={sidebarMinimized}
        onClose={() => setSidebarOpen(false)}
        onToggleMinimize={() => setSidebarMinimized(!sidebarMinimized)}
      />

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden transition-all duration-300">
        {/* Header/Navbar di atas konten (untuk toggle mobile) */}
        <Header
          onMenuClick={() => setSidebarOpen(true)}
          onToggleMinimize={() => setSidebarMinimized(!sidebarMinimized)}
          sidebarMinimized={sidebarMinimized}
        />

        <main className="flex-1 overflow-x-hidden overflow-y-auto bg-gray-50 p-4 lg:p-6">
           <Outlet />
        </main>
      </div>
    </div>
  );
}