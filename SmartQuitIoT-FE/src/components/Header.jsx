import appLogo from "@/assets/logo.png";
import { NavLink, useNavigate } from "react-router-dom";

const Header = () => {
  const navigate = useNavigate();

  return (
    <header className="fixed top-0 left-0 right-0 z-50 backdrop-blur-md">
      {/* Animated liquid background */}
      <div className="absolute inset-0 bg-gradient-to-r from-green-50 via-emerald-50 to-teal-50 opacity-90">
        <div className="absolute inset-0 bg-gradient-to-br from-green-100/30 via-transparent to-emerald-100/30 animate-pulse"></div>
      </div>

      {/* Liquid border effect */}
      <div className="absolute bottom-0 left-0 right-0 h-[2px] bg-gradient-to-r from-green-400 via-emerald-500 to-teal-400 animate-gradient-x"></div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative">
        <div className="flex items-center justify-between h-16">
          {/* Logo with liquid effect */}
          <div
            className="flex items-center gap-2 cursor-pointer group"
            onClick={() => navigate("/")}
          >
            <div className="w-10 h-10 bg-gradient-to-br from-green-400 to-emerald-500 rounded-full flex items-center justify-center shadow-lg group-hover:shadow-xl group-hover:scale-110 transition-all duration-300 relative overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-tr from-white/20 to-transparent animate-shimmer"></div>
              <img
                className="ml-1 w-6 h-6 relative z-10"
                src={appLogo}
                alt="Q"
              />
            </div>
            <span className="text-xl bg-gradient-to-r from-green-700 via-emerald-600 to-teal-700 bg-clip-text text-transparent font-bold group-hover:scale-105 transition-transform duration-300">
              SmartQuitIoT
            </span>
          </div>

          {/* Navigation with liquid hover effects */}
          <nav className="hidden md:flex items-center gap-8">
            {[
              { to: "/", label: "Home" },
              { to: "/resources", label: "Resources" },
              { to: "/community", label: "Community" },
              { to: "/news", label: "News" },
              { to: "/about", label: "About" },
              { to: "/download", label: "Download" },
            ].map((item) => (
              <NavLink
                key={item.to}
                to={item.to}
                className={({ isActive }) =>
                  `font-medium transition-all duration-300 relative group ${
                    isActive
                      ? "text-green-700"
                      : "text-gray-700 hover:text-green-600"
                  }`
                }
              >
                {item.label}
                <span
                  className={`absolute -bottom-1 left-0 h-[2px] bg-gradient-to-r from-green-500 to-emerald-500 transition-all duration-300 ${({
                    isActive,
                  }) => (isActive ? "w-full" : "w-0 group-hover:w-full")}`}
                ></span>
              </NavLink>
            ))}
          </nav>

          {/* Auth Buttons with liquid effects */}
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate("/login")}
              className="text-gray-700 hover:text-green-600 font-medium px-4 py-2 cursor-pointer transition-all duration-300 hover:scale-105"
            >
              Login
            </button>
            <button
              onClick={() => navigate("/login")}
              className="relative cursor-pointer bg-gradient-to-r from-green-500 via-emerald-500 to-teal-500 hover:from-green-600 hover:via-emerald-600 hover:to-teal-600 text-white font-medium px-6 py-2 rounded-full transition-all duration-300 hover:scale-105 hover:shadow-lg overflow-hidden group"
            >
              <span className="relative z-10">Get Started</span>
              <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-700"></div>
            </button>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
