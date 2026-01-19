import logoBanner from "@/assets/login-banner.png";
import logo from "@/assets/logo.png";
import LoginForm from "@/components/ui/login-form";
import { ArrowLeft } from "lucide-react";
import { useNavigate } from "react-router-dom";

const Login = () => {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen flex flex-col lg:flex-row">
      {/* Left Side - Form */}
      <div className="flex-1 flex items-center justify-center p-4 sm:p-8 bg-background relative">
        <button
          onClick={() => navigate("/")}
          className="absolute top-4 left-4 sm:top-6 sm:left-6 flex items-center gap-2 text-gray-600 hover:text-emerald-600 transition-colors z-10"
        >
          <ArrowLeft className="w-4 h-4 sm:w-5 sm:h-5" />
          <span className="font-medium text-sm sm:text-base">Back to Home</span>
        </button>

        <div className="w-full max-w-md space-y-4 sm:space-y-6 pt-12 sm:pt-0">
          <div className="text-center space-y-2">
            <img
              src={logo}
              alt="Logo"
              className="mx-auto h-16 sm:h-20 w-auto"
            />
            <h1 className="text-2xl sm:text-3xl font-bold tracking-tight text-emerald-500 px-4">
              Smart Quit IoT Management
            </h1>
          </div>
          <LoginForm />
        </div>
      </div>

      {/* Right Side - Image */}
      <div className="hidden lg:flex flex-1 relative bg-muted">
        <div className="absolute inset-0" />
        <div className="relative h-full w-full flex items-center justify-center overflow-hidden">
          <img
            src={logoBanner}
            alt="Login Banner"
            className="w-full h-full object-cover"
          />
        </div>
      </div>

      {/* Mobile/Tablet Banner - Optional decorative element */}
      <div className="lg:hidden w-full h-32 sm:h-40 bg-gradient-to-r from-emerald-500 to-teal-600 relative overflow-hidden">
        <div className="absolute inset-0 opacity-20">
          <img
            src={logoBanner}
            alt="Login Banner"
            className="w-full h-full object-cover blur-sm"
          />
        </div>
      </div>
    </div>
  );
};

export default Login;
