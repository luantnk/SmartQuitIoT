import { useNavigate } from "react-router-dom";
import { motion } from "framer-motion";
import { Sparkles, TrendingUp, Award, DollarSign } from "lucide-react";

const HeroSection = () => {
  const stats = [
    {
      label: "Active Users",
      value: "25+",
      icon: <TrendingUp className="w-4 h-4" />,
    },
    {
      label: "Success Rate",
      value: "78%",
      icon: <Award className="w-4 h-4" />,
    },
    {
      label: "Days Average",
      value: "30",
      icon: <Sparkles className="w-4 h-4" />,
    },
    {
      label: "Money Saved",
      value: "2.5M+",
      icon: <DollarSign className="w-4 h-4" />,
    },
  ];

  const features = [
    {
      title: "Personalized quit plans",
      description: "Tailored strategies based on your smoking habits",
      gradient: "from-emerald-500 to-teal-500",
      bgColor: "bg-emerald-50",
    },
    {
      title: "Achievement tracking",
      description: "Celebrate milestones and stay motivated",
      gradient: "from-yellow-500 to-orange-500",
      bgColor: "bg-yellow-50",
    },
    {
      title: "Financial impact monitoring",
      description: "See how much money you're saving",
      gradient: "from-green-500 to-emerald-500",
      bgColor: "bg-green-50",
    },
  ];

  const navigate = useNavigate();

  // Animation variants
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.15,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        ease: "easeOut",
      },
    },
  };

  const slideInLeft = {
    hidden: { opacity: 0, x: -60 },
    visible: {
      opacity: 1,
      x: 0,
      transition: {
        duration: 0.7,
        ease: "easeOut",
      },
    },
  };

  const slideInRight = {
    hidden: { opacity: 0, x: 60 },
    visible: {
      opacity: 1,
      x: 0,
      transition: {
        duration: 0.7,
        ease: "easeOut",
      },
    },
  };

  return (
    <div className="relative bg-gradient-to-br from-emerald-50 via-teal-50 to-cyan-50 min-h-screen py-12 px-4 sm:px-6 lg:px-8 overflow-hidden">
      {/* Animated liquid blobs background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute top-20 -left-20 w-96 h-96 bg-emerald-300/20 rounded-full mix-blend-multiply filter blur-3xl"
          animate={{
            x: [0, 50, 0],
            y: [0, -30, 0],
            scale: [1, 1.2, 1],
          }}
          transition={{
            duration: 8,
            repeat: Infinity,
            ease: "easeInOut",
          }}
        />
        <motion.div
          className="absolute top-40 -right-20 w-96 h-96 bg-teal-300/20 rounded-full mix-blend-multiply filter blur-3xl"
          animate={{
            x: [0, -40, 0],
            y: [0, 50, 0],
            scale: [1, 1.3, 1],
          }}
          transition={{
            duration: 10,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 1,
          }}
        />
        <motion.div
          className="absolute bottom-20 left-1/3 w-96 h-96 bg-cyan-300/20 rounded-full mix-blend-multiply filter blur-3xl"
          animate={{
            x: [0, 30, 0],
            y: [0, -40, 0],
            scale: [1, 1.1, 1],
          }}
          transition={{
            duration: 9,
            repeat: Infinity,
            ease: "easeInOut",
            delay: 2,
          }}
        />
      </div>

      <div className="max-w-7xl mx-auto relative z-10">
        <div className="grid lg:grid-cols-2 gap-12 items-center">
          {/* Left Content */}
          <motion.div
            className="space-y-8"
            initial="hidden"
            animate="visible"
            variants={slideInLeft}
          >
            <motion.div className="space-y-4" variants={itemVariants}>
              <motion.div
                className="inline-flex items-center gap-2 bg-gradient-to-r from-emerald-500/10 to-teal-500/10 backdrop-blur-sm px-4 py-2 rounded-full border border-emerald-200"
                whileHover={{ scale: 1.05 }}
                transition={{ duration: 0.2 }}
              >
                <Sparkles className="w-4 h-4 text-emerald-600" />
                <span className="text-emerald-700 font-semibold tracking-wide uppercase text-sm">
                  BEGIN TODAY
                </span>
              </motion.div>

              <motion.h1
                className="text-5xl lg:text-6xl font-bold text-gray-900 leading-tight"
                variants={itemVariants}
              >
                Your Journey to a{" "}
                <span className="bg-gradient-to-r from-emerald-600 via-teal-600 to-cyan-600 bg-clip-text text-transparent">
                  Smoke-Free Life
                </span>
              </motion.h1>

              <motion.p
                className="text-lg text-gray-600 leading-relaxed"
                variants={itemVariants}
              >
                Join thousands who have successfully quit with SmartQuitIoT. Get
                personalized support, track progress, and achieve your
                smoke-free goals.
              </motion.p>
            </motion.div>

            {/* CTA Buttons */}
            <motion.div
              className="flex flex-wrap gap-4"
              variants={containerVariants}
            >
              <motion.button
                onClick={() => navigate("/login")}
                className="group relative cursor-pointer bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 text-white font-semibold px-8 py-4 rounded-xl transition-all shadow-lg hover:shadow-xl overflow-hidden"
                variants={itemVariants}
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
              >
                <span className="relative z-10">Start Your Journey</span>
                <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-700"></div>
              </motion.button>

              <motion.button
                onClick={() => navigate("/download")}
                className="group relative cursor-pointer bg-gradient-to-r from-cyan-500 to-blue-600 hover:from-cyan-600 hover:to-blue-700 text-white font-semibold px-8 py-4 rounded-xl transition-all shadow-lg hover:shadow-xl overflow-hidden"
                variants={itemVariants}
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
              >
                <span className="relative z-10">Download App</span>
                <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-700"></div>
              </motion.button>

              <motion.button
                onClick={() => navigate("/resources")}
                className="cursor-pointer bg-white/80 backdrop-blur-sm hover:bg-white text-gray-900 font-semibold px-8 py-4 rounded-xl border-2 border-emerald-200 hover:border-emerald-300 transition-all"
                variants={itemVariants}
                whileHover={{ scale: 1.05, y: -2 }}
                whileTap={{ scale: 0.95 }}
              >
                How It Works
              </motion.button>
            </motion.div>

            {/* Stats */}
            <motion.div
              className="grid grid-cols-2 sm:grid-cols-4 gap-6 pt-8"
              variants={containerVariants}
            >
              {stats.map((stat, index) => (
                <motion.div
                  key={index}
                  className="group relative bg-white/80 backdrop-blur-sm rounded-2xl p-4 shadow-lg border border-emerald-100 hover:border-emerald-300 transition-all overflow-hidden"
                  variants={itemVariants}
                  whileHover={{ scale: 1.05, y: -5 }}
                  transition={{ duration: 0.2 }}
                >
                  <div className="absolute inset-0 bg-gradient-to-br from-emerald-500/5 to-teal-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                  <div className="relative z-10">
                    <div className="flex items-center gap-2 text-emerald-600 mb-2">
                      {stat.icon}
                      <p className="text-sm text-gray-600">{stat.label}</p>
                    </div>
                    <p className="text-2xl font-bold bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
                      {stat.value}
                    </p>
                  </div>
                </motion.div>
              ))}
            </motion.div>
          </motion.div>

          {/* Right Content - Features Card */}
          <motion.div
            className="relative bg-white/80 backdrop-blur-lg rounded-3xl shadow-2xl p-8 space-y-6 border border-emerald-100 overflow-hidden"
            initial="hidden"
            animate="visible"
            variants={slideInRight}
          >
            {/* Animated shimmer effect */}
            <motion.div
              className="absolute inset-0 bg-gradient-to-tr from-emerald-500/0 via-emerald-500/5 to-teal-500/0"
              animate={{
                x: ["-100%", "100%"],
                y: ["-100%", "100%"],
              }}
              transition={{
                duration: 3,
                repeat: Infinity,
                ease: "linear",
              }}
            />

            <div className="relative z-10">
              <motion.div
                className="w-16 h-16 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-2xl flex items-center justify-center mx-auto shadow-lg"
                variants={itemVariants}
                whileHover={{ rotate: 360, scale: 1.1 }}
                transition={{ duration: 0.6 }}
              >
                <svg
                  className="w-8 h-8 text-white"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                </svg>
              </motion.div>

              <motion.h2
                className="text-3xl font-bold text-gray-900 text-center mt-6 bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent"
                variants={itemVariants}
              >
                Why Choose SmartQuitIoT?
              </motion.h2>

              <motion.div
                className="space-y-4 mt-6"
                variants={containerVariants}
              >
                {features.map((feature, index) => (
                  <motion.div
                    key={index}
                    className="group flex items-start gap-3 p-4 rounded-2xl hover:bg-gradient-to-r hover:from-emerald-50/50 hover:to-teal-50/50 transition-all duration-300"
                    variants={itemVariants}
                    whileHover={{ x: 5 }}
                  >
                    <motion.div
                      className={`w-10 h-10 bg-gradient-to-br ${feature.gradient} rounded-xl flex items-center justify-center flex-shrink-0 shadow-md`}
                      whileHover={{ rotate: 360 }}
                      transition={{ duration: 0.5 }}
                    >
                      <svg
                        className="w-5 h-5 text-white"
                        fill="currentColor"
                        viewBox="0 0 20 20"
                      >
                        <path
                          fillRule="evenodd"
                          d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                          clipRule="evenodd"
                        />
                      </svg>
                    </motion.div>
                    <div>
                      <h3 className="font-semibold text-gray-900 group-hover:text-emerald-700 transition-colors">
                        {feature.title}
                      </h3>
                      <p className="text-sm text-gray-600 mt-1">
                        {feature.description}
                      </p>
                    </div>
                  </motion.div>
                ))}
              </motion.div>

              <motion.button
                onClick={() => navigate("/about")}
                className="group relative w-full bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 text-white font-semibold px-6 py-3 rounded-xl transition-all mt-6 shadow-lg overflow-hidden"
                variants={itemVariants}
                whileHover={{ scale: 1.02, y: -2 }}
                whileTap={{ scale: 0.98 }}
              >
                <span className="relative z-10 flex items-center justify-center gap-2">
                  Learn More
                  <motion.span
                    animate={{ x: [0, 5, 0] }}
                    transition={{
                      duration: 1.5,
                      repeat: Infinity,
                      ease: "easeInOut",
                    }}
                  >
                    →
                  </motion.span>
                </span>
                <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-700"></div>
              </motion.button>
            </div>
          </motion.div>
        </div>
      </div>
    </div>
  );
};

export default HeroSection;
