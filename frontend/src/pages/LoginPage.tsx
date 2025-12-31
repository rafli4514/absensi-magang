import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { Eye, EyeOff, Lock, User as UserIcon } from "lucide-react";
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
      // Panggil langsung fungsi logika submit
      submitForm();
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    submitForm();
  };

  const submitForm = async () => {
    setIsLoading(true);
    setError("");

    try {
      const response = await authService.login({
        username: formData.username,
        password: formData.password,
      });

      if (response.success && response.data) {
        const user = response.data.user;
        if (user && user.role === 'PESERTA_MAGANG') {
          authService.logout();
          setError("Akses ditolak. Khusus Admin/Pembimbing.");
          setIsLoading(false);
          return;
        }
        navigate("/");
      } else {
        setError(response.message || "Login gagal");
      }
    } catch (err: unknown) {
      // Type narrowing untuk error handling yang aman
      let errorMessage = "Terjadi kesalahan pada server.";
      if (typeof err === 'object' && err !== null && 'response' in err) {
        const response = (err as { response: { data?: { message?: string } } }).response;
        if (response?.data?.message) {
          errorMessage = response.data.message;
        }
      } else if (err instanceof Error) {
        errorMessage = err.message;
      }
      setError(errorMessage);
    } finally {
      setIsLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  return (
    <div className="h-screen w-full flex overflow-hidden bg-white">

      {/* Sisi Kiri: Branding (Tetap dominan) */}
      <div className="hidden lg:flex lg:w-1/2 bg-blue-600 relative items-center justify-center p-12">
        <div className="absolute top-0 left-0 w-full h-full opacity-20">
          <div className="absolute top-[-10%] left-[-10%] w-[60%] h-[60%] rounded-full bg-blue-400 blur-3xl"></div>
          <div className="absolute bottom-[-10%] right-[-10%] w-[50%] h-[50%] rounded-full bg-blue-800 blur-3xl"></div>
        </div>

        <div className="relative z-10 text-center max-w-lg">
          <div className="bg-white p-5 rounded-2xl shadow-2xl mb-8 inline-block transform hover:scale-105 transition-transform duration-300">
            <img src={Logo} alt="IconPlus Logo" className="h-20 object-contain" />
          </div>
          <h2 className="text-4xl font-extrabold text-white mb-4 leading-tight">
            Selamat Datang di <br /> <span className="text-blue-200">InternPlus 👋</span>
          </h2>
          <p className="text-blue-100 text-lg font-light leading-relaxed">
            Sistem Monitoring Absensi Digital untuk efisiensi dan transparansi peserta magang & PKL.
          </p>
        </div>
      </div>

      {/* Sisi Kanan: Form Login (Lebih Kecil/Compact) */}
      <div className="w-full lg:w-1/2 flex flex-col justify-center items-center p-6 bg-white relative">

        {/* Watermark Logo for Mobile */}
        <img src={Logo} alt="Logo" className="h-10 lg:hidden mb-8" />

        {/* max-w-sm membuat form lebih ramping */}
        <div className="w-full max-w-sm">
          <div className="mb-8 text-center lg:text-left">
            <h1 className="text-2xl font-black text-gray-900 tracking-tight mb-2">
              Login Admin
            </h1>
            <p className="text-gray-500 text-sm">
              Masukkan kredensial untuk masuk ke dashboard.
            </p>
          </div>

          <form className="space-y-5" onSubmit={handleSubmit} onKeyDown={handleKeyDown}>
            {error && (
              <div className="bg-red-50 border-l-4 border-red-500 p-3 rounded-md animate-shake">
                <p className="text-xs text-red-700 font-bold">{error}</p>
              </div>
            )}

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-gray-600 uppercase tracking-widest">Username</label>
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                  <UserIcon className="h-4 w-4 text-gray-400 group-focus-within:text-blue-600 transition-colors" />
                </div>
                <input
                  name="username"
                  type="text"
                  required
                  value={formData.username}
                  onChange={handleChange}
                  className="block w-full pl-10 pr-4 py-3 border-2 border-gray-100 rounded-xl bg-gray-50 focus:bg-white focus:border-blue-600 transition-all outline-none text-sm font-medium text-gray-900"
                  placeholder="admin_iconplus"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-gray-600 uppercase tracking-widest">Password</label>
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none">
                  <Lock className="h-4 w-4 text-gray-400 group-focus-within:text-blue-600 transition-colors" />
                </div>
                <input
                  name="password"
                  type={showPassword ? "text" : "password"}
                  required
                  value={formData.password}
                  onChange={handleChange}
                  className="block w-full pl-10 pr-10 py-3 border-2 border-gray-100 rounded-xl bg-gray-50 focus:bg-white focus:border-blue-600 transition-all outline-none text-sm font-medium text-gray-900"
                  placeholder="••••••••"
                />
                <button
                  type="button"
                  className="absolute inset-y-0 right-0 pr-3 flex items-center text-gray-400 hover:text-blue-600 transition-colors"
                  onClick={() => setShowPassword(!showPassword)}
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </div>

            <div className="flex items-center justify-between py-1">
              <label className="flex items-center cursor-pointer group">
                <input
                  type="checkbox"
                  className="h-4 w-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500 cursor-pointer"
                />
                <span className="ml-2 text-xs font-medium text-gray-500 group-hover:text-gray-900 transition-colors">Ingat saya</span>
              </label>
              <a href="#" className="text-xs font-bold text-blue-600 hover:text-blue-800 transition-all">
                Lupa password?
              </a>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full flex justify-center items-center py-3.5 px-6 bg-blue-600 hover:bg-blue-700 disabled:bg-blue-300 text-white text-sm font-bold rounded-xl shadow-lg shadow-blue-100 transition-all transform active:scale-[0.98]"
            >
              {isLoading ? (
                <div className="flex items-center">
                  <svg className="animate-spin h-4 w-4 text-white mr-2" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Proses...
                </div>
              ) : "MASUK SEKARANG"}
            </button>
          </form>

          <div className="absolute bottom-10 left-0 right-0 text-center">
            <p className="text-[10px] text-gray-400 font-medium uppercase tracking-widest">
              &copy; {new Date().getFullYear()} By Muhammad Rafli Aulia <br />
              PT PLN Icon Plus Aceh
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}