  import { useState } from "react";
  import { useNavigate } from "react-router-dom";
  import { Eye, EyeOff, Lock, Mail } from "lucide-react";
  import Logo from "../assets/64eb562e223ee070362018.png";
  import authService from "../services/authService";

  export default function Login() {
    const [formData, setFormData] = useState({
      username: "",
      password: "",
    });
    const [showPassword, setShowPassword] = useState(false);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState("");
    const navigate = useNavigate();

    const handleKeyDown = (e: React.KeyboardEvent) => {
      if (e.key === 'Enter' && !isLoading) {
        e.preventDefault();
        handleSubmit(e as any);
      }
    };

    const handleSubmit = async (e: React.FormEvent) => {
      e.preventDefault();
      setIsLoading(true);
      setError("");

      try {
        const response = await authService.login({
          username: formData.username,
          password: formData.password,
        });

        if (response.success && response.data) {
          // Validasi role - hanya ADMIN dan PEMBIMBING_MAGANG yang boleh akses web
          const user = response.data.user;
          if (user && user.role === 'USER') {
            // Jika role USER, logout dan tampilkan error
            authService.logout();
            setError("Akses ditolak. Hanya Admin dan Pembimbing Magang yang dapat mengakses aplikasi web. Silakan gunakan aplikasi mobile.");
            setIsLoading(false);
            return;
          }

          // Lanjutkan untuk ADMIN dan PEMBIMBING_MAGANG
          navigate("/");
        } else {
          setError(response.message || "Login failed");
        }
      } catch (error: unknown) {
        console.error("Login error:", error);
        const errorMessage = error && typeof error === 'object' && 'response' in error 
          ? (error as { response?: { data?: { message?: string } } }).response?.data?.message || "Login failed. Please try again."
          : "Login failed. Please try again.";
        setError(errorMessage);
      } finally {
        setIsLoading(false);
      }
    };

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
      setFormData({
        ...formData,
        [e.target.name]: e.target.value,
      });
    };

    return (
      <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8">
        <div className="sm:mx-auto sm:w-full sm:max-w-md">
          <div className="text-center">
            <div className="flex items-center justify-center h-16 bg-primary-200">
              <img src={Logo} alt="Iconnet Logo" className="h-16" />
            </div>
          </div>
        </div>

        <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
          <div className="bg-white py-4 px-4 sha  dow sm:rounded-lg sm:px-10">
            <h1 className="mt-2 text-xl font-bold text-black text-center">
              Sistem Absensi PKL
            </h1>
            <form className="space-y-6 mt-5" onSubmit={handleSubmit} onKeyDown={handleKeyDown}>
              <div>
                <label
                  htmlFor="email"
                  className="block text-sm font-medium text-black"
                >
                  Username
                </label>
                <div className="mt-1 relative border rounded-md shadow-sm border-gray-300 focus-within:border-primary-500 focus-within:ring-1 focus-within:ring-primary-500 w-full">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Mail className="h-5 w-5 text-gray-400" />
                  </div>
                  <input
                    id="username"
                    name="username"
                    type="text"
                    autoComplete="username"
                    required
                    value={formData.username}
                    onChange={handleChange}
                    className="block w-full rounded-md border-0 py-1.5 pl-10 text-gray-900 ring-0 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6"
                    placeholder="Username"
                  />
                </div>
              </div>

              <div>
                <label
                  htmlFor="password"
                  className="block text-sm font-medium text-gray-700"
                >
                  Password
                </label>
                <div className="mt-1 relative border rounded-md shadow-sm border-gray-300 focus-within:border-primary-500 focus-within:ring-1 focus-within:ring-primary-500 w-full">
                  <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <Lock className="h-5 w-5 text-gray-400" />
                  </div>
                  <input
                    id="password"
                    name="password"
                    type={showPassword ? "text" : "password"}
                    autoComplete="current-password"
                    required
                    value={formData.password}
                    onChange={handleChange}
                    className="block w-full rounded-md border-0 py-1.5 pl-10 pr-10 text-gray-900 ring-0 placeholder:text-gray-400 focus:ring-0 sm:text-sm sm:leading-6"
                    placeholder="Masukkan password"
                  />
                  <button
                    type="button"
                    className="absolute inset-y-0 right-0 pr-3 flex items-center"
                    onClick={() => setShowPassword(!showPassword)}
                  >
                    {showPassword ? (
                      <EyeOff className="h-5 w-5 text-gray-400" />
                    ) : (
                      <Eye className="h-5 w-5 text-gray-400" />
                    )}
                  </button>
                </div>
              </div>

              <div className="flex items-center justify-between">
                <div className="flex items-center">
                  <input
                    id="remember-me"
                    name="remember-me"
                    type="checkbox"
                    className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                  />
                  <label
                    htmlFor="remember-me"
                    className="ml-2 block text-sm text-gray-900"
                  >
                    Remember me
                  </label>
                </div>

                <div className="text-sm">
                  <a
                    href="#"
                    className="font-medium text-primary-600 hover:text-primary-500"
                  >
                    Forgot your password?
                  </a>
                </div>
              </div>

              {error && (
                <div className="text-red-600 text-sm text-center bg-red-50 p-3 rounded-md">
                  {error}
                </div>
              )}

              <div>
                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-black bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isLoading ? (
                    <div className="flex items-center">
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                      Signing in...
                    </div>
                  ) : (
                    "Masuk"
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    );
  }
