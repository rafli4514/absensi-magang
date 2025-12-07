import { useEffect, useState } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import authService from '../services/authService';

interface ProtectedRouteProps {
  children: React.ReactNode;
  requiredRole?: 'ADMIN' | 'PESERTA_MAGANG' | 'PEMBIMBING_MAGANG';
  allowedRoles?: ('ADMIN' | 'PESERTA_MAGANG' | 'PEMBIMBING_MAGANG')[];
}

export default function ProtectedRoute({ children, requiredRole, allowedRoles }: ProtectedRouteProps) {
  const [isLoading, setIsLoading] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [hasPermission, setHasPermission] = useState(false);
  const location = useLocation();

  useEffect(() => {
    const checkAuth = async () => {
      try {
        const token = authService.getToken();
        const user = authService.getCurrentUser();

        if (!token || !user) {
          setIsAuthenticated(false);
          setIsLoading(false);
          return;
        }

        // Verify token with backend
        try {
          await authService.getProfile();
          setIsAuthenticated(true);

          // Check role permission
          if (requiredRole) {
            setHasPermission(user.role === requiredRole);
          } else if (allowedRoles) {
            setHasPermission(allowedRoles.includes(user.role as any));
          } else {
            setHasPermission(true);
          }
        } catch (error) {
          // Token invalid or expired
          authService.logout();
          setIsAuthenticated(false);
        }
      } catch (error) {
        console.error('Auth check error:', error);
        setIsAuthenticated(false);
      } finally {
        setIsLoading(false);
      }
    };

    checkAuth();
  }, [requiredRole, allowedRoles]);

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-2 text-gray-600">Verifying authentication...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    // Redirect to login with return URL
    return <Navigate to="/login" state={{ from: location }} replace />;
  }

  // Check permission menggunakan state hasPermission yang sudah di-set di useEffect
  if ((requiredRole || allowedRoles) && !hasPermission) {
    // User doesn't have required role
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-red-600 mb-4">Access Denied</h1>
          <p className="text-gray-600 mb-4">
            Anda tidak memiliki akses untuk halaman ini.
          </p>
          <p className="text-sm text-gray-500 mb-4">
            {allowedRoles ? `Role yang diizinkan: ${allowedRoles.join(', ')}` : `Role yang dibutuhkan: ${requiredRole}`}
          </p>
          <p className="text-sm text-gray-500 mb-4">
            Role Anda: {authService.getCurrentUser()?.role || 'Tidak diketahui'}
          </p>
          <button
            onClick={() => {
              authService.logout();
              window.location.href = '/login';
            }}
            className="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 transition-colors"
          >
            Kembali ke Login
          </button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
