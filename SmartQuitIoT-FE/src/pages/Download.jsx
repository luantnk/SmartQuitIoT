import { motion } from "framer-motion";
import {
  Apple,
  Check,
  Download as DownloadIcon,
  PlayCircle,
  Sparkles,
} from "lucide-react";
import { GrAppleAppStore } from "react-icons/gr";
import { FaGooglePlay } from "react-icons/fa";

const Download = () => {
  const features = [
    "Real-time smoking cessation tracking",
    "Personalized quit plans and goals",
    "IoT device integration",
    "Daily missions and achievements",
    "Expert coaching sessions",
    "Community support network",
    "Progress analytics and insights",
    "Craving management tools",
  ];

  // Animation variants
  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.5,
      },
    },
  };

  const fadeInUp = {
    hidden: { opacity: 0, y: 60 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        ease: "easeOut",
      },
    },
  };

  const scaleIn = {
    hidden: { opacity: 0, scale: 0.8 },
    visible: {
      opacity: 1,
      scale: 1,
      transition: {
        duration: 0.5,
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
        duration: 0.6,
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
        duration: 0.6,
        ease: "easeOut",
      },
    },
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-white via-emerald-50/30 to-teal-50/50">
      {/* Hero Section with Liquid Background */}
      <div className="relative overflow-hidden bg-gradient-to-br from-emerald-500 via-teal-600 to-cyan-600 text-white py-20">
        {/* Animated liquid blobs */}
        <div className="absolute inset-0 overflow-hidden">
          <motion.div
            className="absolute top-0 -left-20 w-96 h-96 bg-emerald-400/30 rounded-full mix-blend-multiply filter blur-3xl"
            animate={{
              x: [0, 30, 0],
              y: [0, -50, 0],
              scale: [1, 1.1, 1],
            }}
            transition={{
              duration: 7,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />
          <motion.div
            className="absolute top-0 -right-20 w-96 h-96 bg-teal-400/30 rounded-full mix-blend-multiply filter blur-3xl"
            animate={{
              x: [0, -30, 0],
              y: [0, 50, 0],
              scale: [1, 1.2, 1],
            }}
            transition={{
              duration: 8,
              repeat: Infinity,
              ease: "easeInOut",
              delay: 1,
            }}
          />
          <motion.div
            className="absolute -bottom-20 left-1/2 w-96 h-96 bg-cyan-400/30 rounded-full mix-blend-multiply filter blur-3xl"
            animate={{
              x: [0, 40, 0],
              y: [0, -30, 0],
              scale: [1, 0.9, 1],
            }}
            transition={{
              duration: 9,
              repeat: Infinity,
              ease: "easeInOut",
              delay: 2,
            }}
          />
        </div>

        <div className="max-w-7xl mx-auto px-6 relative z-10">
          <div className="grid lg:grid-cols-2 gap-12 items-center">
            {/* Left Content */}
            <motion.div
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true }}
              variants={slideInLeft}
            >
              <motion.div
                className="inline-flex items-center gap-2 bg-white/20 backdrop-blur-md px-4 py-2 rounded-full mb-6"
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ duration: 0.5 }}
              >
                <Sparkles className="w-4 h-4" />
                <span className="text-sm font-medium">
                  New Features Available
                </span>
              </motion.div>

              <motion.h1
                className="text-5xl md:text-6xl font-bold mb-6 bg-gradient-to-r from-white via-emerald-100 to-white bg-clip-text text-transparent animate-gradient-x"
                variants={itemVariants}
              >
                Download SmartQuit IoT
              </motion.h1>
              <motion.p
                className="text-xl text-emerald-50 mb-8 leading-relaxed"
                variants={itemVariants}
              >
                Take control of your quit smoking journey with our powerful
                mobile app. Track progress, connect with coaches, and achieve
                your goals—all from your phone.
              </motion.p>

              {/* Download Buttons with Liquid Effect */}
              <motion.div
                className="flex flex-col sm:flex-row gap-4 mb-8"
                variants={containerVariants}
              >
                <motion.a
                  href="#"
                  className="group relative inline-flex items-center justify-center gap-3 bg-black text-white px-8 py-4 rounded-2xl font-semibold hover:bg-gray-900 transition-all shadow-xl overflow-hidden"
                  variants={itemVariants}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/10 to-white/0 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-1000"></div>
                  <GrAppleAppStore className="w-6 h-6 relative z-10" />
                  <div className="text-left relative z-10">
                    <div className="text-xs opacity-80">Download on the</div>
                    <div className="text-lg font-bold">App Store</div>
                  </div>
                </motion.a>

                <motion.a
                  href="#"
                  className="group relative inline-flex items-center justify-center gap-3 bg-black text-white px-8 py-4 rounded-2xl font-semibold hover:bg-gray-900 transition-all shadow-xl overflow-hidden"
                  variants={itemVariants}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/10 to-white/0 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-1000"></div>
                  <FaGooglePlay className="w-6 h-6 relative z-10" />
                  <div className="text-left relative z-10">
                    <div className="text-xs opacity-80">Get it on</div>
                    <div className="text-lg font-bold">Google Play</div>
                  </div>
                </motion.a>
              </motion.div>

              <motion.div
                className="flex items-center gap-3 text-emerald-50 bg-white/10 backdrop-blur-md px-4 py-3 rounded-full inline-flex"
                variants={itemVariants}
              >
                <DownloadIcon className="w-5 h-5" />
                <span className="text-sm font-medium">
                  Free to download • Available worldwide
                </span>
              </motion.div>
            </motion.div>

            {/* Right Content - Phone Mockup with Liquid Effect */}
            <motion.div
              className="relative"
              initial="hidden"
              whileInView="visible"
              viewport={{ once: true }}
              variants={slideInRight}
            >
              <motion.div
                className="relative z-10 mx-auto w-64 h-[520px] bg-gray-900 rounded-[3rem] p-3 shadow-2xl"
                whileHover={{ scale: 1.05, rotate: 2 }}
                transition={{ duration: 0.3 }}
              >
                <div className="w-full h-full bg-gradient-to-br from-emerald-400 via-teal-500 to-cyan-500 rounded-[2.5rem] overflow-hidden relative">
                  {/* Animated shimmer effect */}
                  <motion.div
                    className="absolute inset-0 bg-gradient-to-tr from-white/0 via-white/20 to-white/0"
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

                  <div className="p-6 pt-12 relative z-10">
                    <motion.div
                      className="bg-white/10 backdrop-blur-md rounded-2xl p-6 mb-4 border border-white/20 shadow-lg"
                      initial={{ opacity: 0, y: 20 }}
                      whileInView={{ opacity: 1, y: 0 }}
                      viewport={{ once: true }}
                      transition={{ delay: 0.3 }}
                    >
                      <div className="text-white/80 text-sm mb-2">
                        Smoke-Free Days
                      </div>
                      <motion.div
                        className="text-5xl font-bold text-white mb-1 bg-gradient-to-r from-white to-emerald-100 bg-clip-text text-transparent"
                        initial={{ scale: 0 }}
                        whileInView={{ scale: 1 }}
                        viewport={{ once: true }}
                        transition={{
                          delay: 0.5,
                          type: "spring",
                          stiffness: 200,
                        }}
                      >
                        42
                      </motion.div>
                      <div className="text-emerald-200 text-sm flex items-center gap-1">
                        <Sparkles className="w-3 h-3" />
                        Keep going strong! 🎉
                      </div>
                    </motion.div>

                    <motion.div
                      className="space-y-3"
                      variants={containerVariants}
                      initial="hidden"
                      whileInView="visible"
                      viewport={{ once: true }}
                    >
                      <motion.div
                        className="bg-white/10 backdrop-blur-md rounded-xl p-4 border border-white/20 hover:bg-white/20 transition-all duration-300"
                        variants={itemVariants}
                        whileHover={{ x: 5 }}
                      >
                        <div className="flex items-center justify-between text-white">
                          <span className="text-sm">Money Saved</span>
                          <span className="font-bold text-lg">2.5M+</span>
                        </div>
                      </motion.div>
                      <motion.div
                        className="bg-white/10 backdrop-blur-md rounded-xl p-4 border border-white/20 hover:bg-white/20 transition-all duration-300"
                        variants={itemVariants}
                        whileHover={{ x: 5 }}
                      >
                        <div className="flex items-center justify-between text-white">
                          <span className="text-sm">Health Points</span>
                          <span className="font-bold text-lg">+85%</span>
                        </div>
                      </motion.div>
                    </motion.div>
                  </div>
                </div>
              </motion.div>

              {/* Enhanced Decorative Elements */}
              <motion.div
                className="absolute -top-4 -right-4 w-72 h-72 bg-white/20 rounded-full blur-3xl"
                animate={{
                  scale: [1, 1.2, 1],
                  opacity: [0.3, 0.5, 0.3],
                }}
                transition={{
                  duration: 4,
                  repeat: Infinity,
                  ease: "easeInOut",
                }}
              />
              <motion.div
                className="absolute -bottom-8 -left-8 w-64 h-64 bg-cyan-400/30 rounded-full blur-3xl"
                animate={{
                  scale: [1, 1.3, 1],
                  opacity: [0.3, 0.6, 0.3],
                }}
                transition={{
                  duration: 5,
                  repeat: Infinity,
                  ease: "easeInOut",
                  delay: 1,
                }}
              />
            </motion.div>
          </div>
        </div>
      </div>

      {/* Features Section with Liquid Cards */}
      <div className="max-w-7xl mx-auto px-6 py-20">
        <motion.div
          className="text-center mb-12"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={fadeInUp}
        >
          <h2 className="text-4xl font-bold text-gray-900 mb-4 bg-gradient-to-r from-emerald-600 via-teal-600 to-cyan-600 bg-clip-text text-transparent">
            Everything You Need to Quit
          </h2>
          <p className="text-xl text-gray-600">
            Powerful features to support your journey
          </p>
        </motion.div>

        <motion.div
          className="grid md:grid-cols-2 lg:grid-cols-4 gap-6"
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true, margin: "-100px" }}
        >
          {features.map((feature, index) => (
            <motion.div
              key={index}
              className="group relative bg-gradient-to-br from-white to-emerald-50/50 p-6 rounded-2xl border border-emerald-100 hover:border-emerald-300 transition-all duration-300 overflow-hidden"
              variants={itemVariants}
              whileHover={{ scale: 1.05, y: -5 }}
              transition={{ duration: 0.2 }}
            >
              <div className="absolute inset-0 bg-gradient-to-r from-emerald-500/0 via-emerald-500/5 to-emerald-500/0 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-1000"></div>
              <div className="relative z-10 flex items-start gap-3">
                <motion.div
                  className="flex-shrink-0 w-8 h-8 bg-gradient-to-br from-emerald-500 to-teal-500 rounded-full flex items-center justify-center"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.5 }}
                >
                  <Check className="w-4 h-4 text-white" />
                </motion.div>
                <p className="text-gray-700 font-medium">{feature}</p>
              </div>
            </motion.div>
          ))}
        </motion.div>
      </div>

      {/* CTA Section */}
      <motion.div
        className="relative overflow-hidden bg-gradient-to-br from-emerald-600 via-teal-600 to-cyan-600 py-16 mx-6 mb-20 rounded-3xl"
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true }}
        variants={scaleIn}
      >
        <motion.div
          className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/10 to-white/0"
          animate={{
            x: ["-100%", "100%"],
          }}
          transition={{
            duration: 3,
            repeat: Infinity,
            ease: "linear",
          }}
        />
        <div className="max-w-4xl mx-auto text-center px-6 relative z-10">
          <motion.h2
            className="text-4xl font-bold text-white mb-4"
            variants={fadeInUp}
          >
            Ready to Start Your Journey?
          </motion.h2>
          <motion.p
            className="text-xl text-emerald-50 mb-8"
            variants={fadeInUp}
          >
            Join thousands who have successfully quit smoking with SmartQuit IoT
          </motion.p>
          <motion.button
            className="group relative bg-white text-emerald-600 px-8 py-4 rounded-full font-bold text-lg hover:bg-emerald-50 transition-all shadow-xl overflow-hidden"
            variants={fadeInUp}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            <span className="relative z-10 flex items-center gap-2">
              <DownloadIcon className="w-5 h-5" />
              Download Now
            </span>
            <div className="absolute inset-0 bg-gradient-to-r from-emerald-100/0 via-emerald-100/50 to-emerald-100/0 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-700"></div>
          </motion.button>
        </div>
      </motion.div>
    </div>
  );
};

export default Download;
