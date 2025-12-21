import { useState, useEffect } from "react";
import { Outlet } from "react-router-dom";
import Sidebar from "./Sidebar";
import Header from "./Navbar";

export default function Layout() {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarMinimized, setSidebarMinimized] = useState(() => {
    // Load from localStorage if available
    const saved = localStorage.getItem('sidebarMinimized');
    return saved ? JSON.parse(saved) : false;
  });

  // Save minimize state to localStorage
  useEffect(() => {
    localStorage.setItem('sidebarMinimized', JSON.stringify(sidebarMinimized));
  }, [sidebarMinimized]);

  // Keyboard shortcut for toggle minimize (Ctrl/Cmd + B)
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'b') {
        e.preventDefault();
        setSidebarMinimized(!sidebarMinimized);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [sidebarMinimized]);

  return (
    <div className="flex h-screen bg-gray-50 overflow-hidden">
      {/* Sidebar sits in the flex flow, no need for absolute positioning or margins */}
      <Sidebar
        isOpen={sidebarOpen}
        isMinimized={sidebarMinimized}
        onClose={() => setSidebarOpen(false)}
        onToggleMinimize={() => setSidebarMinimized(!sidebarMinimized)}
      />

      {/* Main Content Wrapper */}
      {/* Removed 'lg:ml-' classes which caused the scrollbar/layout break */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden transition-all duration-300">
        <Header
          onMenuClick={() => setSidebarOpen(true)}
          onToggleMinimize={() => setSidebarMinimized(!sidebarMinimized)}
          sidebarMinimized={sidebarMinimized}
        />

        <main className="flex-1 overflow-x-hidden overflow-y-auto bg-gray-50">
          <div className="container mx-auto px-4 py-6 lg:px-6">
            <Outlet />
          </div>
        </main>
      </div>
    </div>
  );
}