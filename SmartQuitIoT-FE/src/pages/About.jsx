import { motion } from "framer-motion";
import {
  Award,
  CheckCircle,
  Clock,
  DollarSign,
  Heart,
  Mail,
  MapPin,
  Phone,
  Smartphone,
  Sparkles,
  Target,
  TrendingUp,
  Users,
} from "lucide-react";
import { useNavigate } from "react-router-dom";

const About = () => {
  const navigate = useNavigate();

  const stats = [
    {
      icon: Users,
      value: "25+",
      label: "Active Users",
      gradient: "from-blue-500 to-blue-600",
      bgGradient: "from-blue-50 to-blue-100",
    },
    {
      icon: Award,
      value: "78%",
      label: "Success Rate",
      gradient: "from-emerald-500 to-emerald-600",
      bgGradient: "from-emerald-50 to-emerald-100",
    },
    {
      icon: Clock,
      value: "30",
      label: "Days Average",
      gradient: "from-purple-500 to-purple-600",
      bgGradient: "from-purple-50 to-purple-100",
    },
    {
      icon: DollarSign,
      value: "2.5M+",
      label: "Money Saved",
      gradient: "from-orange-500 to-orange-600",
      bgGradient: "from-orange-50 to-orange-100",
    },
  ];

  const features = [
    {
      icon: Smartphone,
      title: "IoT Integration",
      description:
        "Real-time monitoring through smart devices that track your progress and provide instant feedback.",
      gradient: "from-cyan-500 to-blue-500",
    },
    {
      icon: Target,
      title: "Personalized Plans",
      description:
        "Custom quit plans tailored to your smoking habits, triggers, and personal goals.",
      gradient: "from-emerald-500 to-teal-500",
    },
    {
      icon: Users,
      title: "Expert Support",
      description:
        "Access to certified coaches and a supportive community available 24/7.",
      gradient: "from-purple-500 to-pink-500",
    },
    {
      icon: TrendingUp,
      title: "Progress Tracking",
      description:
        "Detailed analytics and insights to visualize your journey and celebrate milestones.",
      gradient: "from-orange-500 to-amber-500",
    },
  ];

  const values = [
    {
      icon: Heart,
      title: "Health First",
      description:
        "We prioritize your health and wellbeing above all else, providing evidence-based solutions.",
      gradient: "from-rose-500 to-red-500",
    },
    {
      icon: Users,
      title: "Community Support",
      description:
        "Building a supportive community where everyone helps each other succeed.",
      gradient: "from-blue-500 to-indigo-500",
    },
    {
      icon: Target,
      title: "Results Driven",
      description:
        "Focused on measurable outcomes and proven methods to help you quit for good.",
      gradient: "from-emerald-500 to-teal-500",
    },
  ];

  const team = [
    {
      name: "Nguyễn Hà Viết Anh",
      role: "Professional Smoker",
      description: "Addiction Medicine Specialist",
      avatarUrl:
        "https://res.cloudinary.com/dmp8hzwup/image/upload/v1763904550/657b6b513ddcb182e8cd_ktrbwd.jpg",
    },
    {
      name: "Nguyễn Hải Linh",
      role: "Coach",
      description: "Developer",
      avatarUrl: "",
    },
    {
      name: "Trần Ngọc Kinh Luân",
      role: "Coach",
      description: "Developer",
      avatarUrl: "",
    },
    {
      name: "Thi Minh Đạt",
      role: "Coach",
      description: "Developer",
      avatarUrl: "",
    },
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
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.5,
        ease: "easeOut",
      },
    },
  };

  const fadeInUp = {
    hidden: { opacity: 0, y: 40 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        ease: "easeOut",
      },
    },
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-white to-gray-50">
      {/* Hero Section */}
      <div className="relative bg-gradient-to-r from-emerald-500 to-teal-600 text-white py-20 overflow-hidden">
        {/* Animated background blobs */}
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <motion.div
            className="absolute top-20 -right-20 w-96 h-96 bg-white/10 rounded-full blur-3xl"
            animate={{
              x: [0, -30, 0],
              y: [0, 50, 0],
              scale: [1, 1.2, 1],
            }}
            transition={{
              duration: 10,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />
          <motion.div
            className="absolute bottom-20 -left-20 w-96 h-96 bg-teal-300/10 rounded-full blur-3xl"
            animate={{
              x: [0, 30, 0],
              y: [0, -50, 0],
              scale: [1, 1.3, 1],
            }}
            transition={{
              duration: 12,
              repeat: Infinity,
              ease: "easeInOut",
              delay: 1,
            }}
          />
        </div>

        <motion.div
          className="max-w-7xl mx-auto px-6 relative z-10"
          initial="hidden"
          animate="visible"
          variants={fadeInUp}
        >
          <motion.div
            className="inline-flex items-center gap-2 bg-white/10 backdrop-blur-sm px-4 py-2 rounded-full border border-white/20 mb-6"
            whileHover={{ scale: 1.05 }}
          >
            <Sparkles className="w-4 h-4" />
            <span className="font-semibold text-sm">ABOUT US</span>
          </motion.div>
          <h1 className="text-5xl md:text-6xl font-bold mb-6">
            About SmartQuit IoT
          </h1>
          <p className="text-xl text-emerald-50 max-w-3xl leading-relaxed">
            Empowering individuals to quit smoking through innovative IoT
            technology, personalized support, and a community-driven approach to
            lasting change.
          </p>
        </motion.div>
      </div>

      {/* Stats Section */}
      <motion.div
        className="max-w-7xl mx-auto px-6 -mt-12 relative z-10"
        variants={containerVariants}
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true }}
      >
        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          {stats.map((stat, idx) => {
            const IconComponent = stat.icon;
            return (
              <motion.div
                key={idx}
                className="group relative bg-white rounded-2xl p-6 shadow-lg hover:shadow-2xl transition-all text-center overflow-hidden"
                variants={itemVariants}
                whileHover={{ y: -8, scale: 1.02 }}
              >
                <motion.div
                  className={`absolute inset-0 bg-gradient-to-br ${stat.bgGradient} opacity-0 group-hover:opacity-100 transition-opacity duration-500`}
                />
                <div className="relative z-10">
                  <motion.div
                    className={`w-16 h-16 bg-gradient-to-br ${stat.gradient} rounded-xl flex items-center justify-center mx-auto mb-3 shadow-lg`}
                    whileHover={{ rotate: 360, scale: 1.1 }}
                    transition={{ duration: 0.6 }}
                  >
                    <IconComponent className="w-8 h-8 text-white" />
                  </motion.div>
                  <motion.div
                    className="text-3xl font-bold text-gray-900 mb-1"
                    initial={{ scale: 0 }}
                    whileInView={{ scale: 1 }}
                    viewport={{ once: true }}
                    transition={{ delay: idx * 0.1, type: "spring" }}
                  >
                    {stat.value}
                  </motion.div>
                  <div className="text-sm text-gray-600 font-medium">
                    {stat.label}
                  </div>
                </div>
              </motion.div>
            );
          })}
        </div>
      </motion.div>

      {/* Mission Section */}
      <div className="max-w-7xl mx-auto px-6 py-16">
        <motion.div
          className="grid lg:grid-cols-2 gap-12 items-center"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={containerVariants}
        >
          <motion.div variants={itemVariants}>
            <h2 className="text-4xl font-bold text-gray-900 mb-6 bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
              Our Mission
            </h2>
            <p className="text-lg text-gray-600 mb-4 leading-relaxed">
              SmartQuit IoT was founded with a clear mission: to revolutionize
              smoking cessation by combining cutting-edge technology with proven
              behavioral science.
            </p>
            <p className="text-lg text-gray-600 mb-6 leading-relaxed">
              We believe that quitting smoking shouldn't be a lonely journey.
              Our platform provides the tools, support, and community needed to
              make lasting change possible.
            </p>
            <motion.button
              onClick={() => navigate("/login")}
              className="group relative bg-gradient-to-r from-emerald-500 to-teal-600 hover:from-emerald-600 hover:to-teal-700 text-white px-8 py-3 rounded-lg font-semibold transition-all shadow-lg overflow-hidden"
              whileHover={{ scale: 1.05, y: -2 }}
              whileTap={{ scale: 0.95 }}
            >
              <span className="relative z-10">Start Your Journey</span>
              <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-700"></div>
            </motion.button>
          </motion.div>

          <motion.div
            className="relative bg-gradient-to-br from-emerald-100 to-teal-100 rounded-2xl p-8 lg:p-12 overflow-hidden"
            variants={itemVariants}
          >
            <motion.div
              className="absolute top-0 right-0 w-32 h-32 bg-emerald-300/20 rounded-full blur-2xl"
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ duration: 5, repeat: Infinity }}
            />
            <div className="space-y-6 relative z-10">
              {[
                {
                  title: "Evidence-Based Approach",
                  desc: "Using scientifically proven methods backed by research.",
                },
                {
                  title: "Personalized Support",
                  desc: "Tailored plans that adapt to your unique needs.",
                },
                {
                  title: "24/7 Availability",
                  desc: "Support whenever you need it, day or night.",
                },
              ].map((item, idx) => (
                <motion.div
                  key={idx}
                  className="flex items-start gap-4"
                  initial={{ opacity: 0, x: -20 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: idx * 0.2 }}
                  whileHover={{ x: 5 }}
                >
                  <CheckCircle className="w-6 h-6 text-emerald-600 flex-shrink-0 mt-1" />
                  <div>
                    <h3 className="font-bold text-gray-900 mb-1">
                      {item.title}
                    </h3>
                    <p className="text-gray-600">{item.desc}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>
        </motion.div>
      </div>

      {/* Features Section */}
      <div className="relative bg-white py-16 overflow-hidden">
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <motion.div
            className="absolute top-40 -left-20 w-96 h-96 bg-emerald-200/20 rounded-full blur-3xl"
            animate={{
              x: [0, 40, 0],
              y: [0, -30, 0],
            }}
            transition={{
              duration: 15,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />
        </div>

        <div className="max-w-7xl mx-auto px-6 relative z-10">
          <motion.div
            className="text-center mb-12"
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={fadeInUp}
          >
            <h2 className="text-4xl font-bold text-gray-900 mb-4 bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
              How We Help You Succeed
            </h2>
          </motion.div>
          <motion.div
            className="grid md:grid-cols-2 lg:grid-cols-4 gap-8"
            variants={containerVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
          >
            {features.map((feature, idx) => {
              const IconComponent = feature.icon;
              return (
                <motion.div
                  key={idx}
                  className="group text-center"
                  variants={itemVariants}
                  whileHover={{ y: -8 }}
                >
                  <motion.div
                    className={`w-16 h-16 bg-gradient-to-br ${feature.gradient} rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg`}
                    whileHover={{ rotate: 360, scale: 1.1 }}
                    transition={{ duration: 0.6 }}
                  >
                    <IconComponent className="w-8 h-8 text-white" />
                  </motion.div>
                  <h3 className="text-xl font-bold text-gray-900 mb-3 group-hover:text-emerald-600 transition-colors">
                    {feature.title}
                  </h3>
                  <p className="text-gray-600">{feature.description}</p>
                </motion.div>
              );
            })}
          </motion.div>
        </div>
      </div>

      {/* Values Section */}
      <div className="max-w-7xl mx-auto px-6 py-16">
        <motion.h2
          className="text-4xl font-bold text-gray-900 text-center mb-12 bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={fadeInUp}
        >
          Our Values
        </motion.h2>
        <motion.div
          className="grid md:grid-cols-3 gap-8"
          variants={containerVariants}
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
        >
          {values.map((value, idx) => {
            const IconComponent = value.icon;
            return (
              <motion.div
                key={idx}
                className="group relative bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all overflow-hidden"
                variants={itemVariants}
                whileHover={{ y: -8, scale: 1.02 }}
              >
                <motion.div
                  className={`absolute top-0 right-0 w-20 h-20 bg-gradient-to-br ${value.gradient} opacity-5 rounded-bl-full`}
                />
                <motion.div
                  whileHover={{ rotate: 360, scale: 1.1 }}
                  transition={{ duration: 0.6 }}
                >
                  <IconComponent
                    className={`w-12 h-12 bg-gradient-to-br ${value.gradient} bg-clip-text text-transparent mb-4`}
                  />
                </motion.div>
                <h3 className="text-2xl font-bold text-gray-900 mb-3">
                  {value.title}
                </h3>
                <p className="text-gray-600">{value.description}</p>
              </motion.div>
            );
          })}
        </motion.div>
      </div>

      {/* Team Section */}
      <div className="relative bg-gradient-to-br from-emerald-50 to-teal-50 py-16 overflow-hidden">
        <div className="absolute inset-0 overflow-hidden pointer-events-none">
          <motion.div
            className="absolute bottom-20 -right-20 w-96 h-96 bg-teal-200/20 rounded-full blur-3xl"
            animate={{
              x: [0, -40, 0],
              y: [0, 30, 0],
            }}
            transition={{
              duration: 14,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />
        </div>

        <div className="max-w-7xl mx-auto px-6 relative z-10">
          <motion.div
            className="text-center mb-12"
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
            variants={fadeInUp}
          >
            <h2 className="text-4xl font-bold text-gray-900 mb-4 bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent">
              Meet Our Team
            </h2>
            <p className="text-xl text-gray-600 max-w-2xl mx-auto">
              Experts dedicated to helping you achieve a smoke-free life
            </p>
          </motion.div>
          <motion.div
            className="grid md:grid-cols-2 lg:grid-cols-4 gap-8"
            variants={containerVariants}
            initial="hidden"
            whileInView="visible"
            viewport={{ once: true }}
          >
            {team.map((member, idx) => (
              <motion.div
                key={idx}
                className="group bg-white rounded-2xl p-8 shadow-lg hover:shadow-2xl transition-all text-center"
                variants={itemVariants}
                whileHover={{ y: -8, scale: 1.02 }}
              >
                {member.avatarUrl ? (
                  <motion.img
                    src={member.avatarUrl}
                    alt={member.name}
                    className="w-24 h-24 rounded-full mx-auto mb-4 object-cover border-4 border-emerald-100"
                    whileHover={{ scale: 1.1, rotate: 5 }}
                    transition={{ duration: 0.3 }}
                  />
                ) : (
                  <motion.div
                    className="w-24 h-24 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full mx-auto mb-4 flex items-center justify-center text-white text-2xl font-bold shadow-lg"
                    whileHover={{ scale: 1.1, rotate: 5 }}
                    transition={{ duration: 0.3 }}
                  >
                    {member.name
                      .split(" ")
                      .map((n) => n[0])
                      .join("")}
                  </motion.div>
                )}
                <h3 className="text-xl font-bold text-gray-900 mb-1">
                  {member.name}
                </h3>
                <div className="text-emerald-600 font-semibold mb-2">
                  {member.role}
                </div>
                <p className="text-gray-600 text-sm">{member.description}</p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </div>

      {/* Contact Section */}
      <div className="max-w-7xl mx-auto px-6 py-16">
        <motion.div
          className="relative bg-gradient-to-r from-emerald-500 to-teal-600 rounded-3xl p-12 text-white overflow-hidden"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={fadeInUp}
        >
          {/* Animated background blobs */}
          <div className="absolute inset-0 overflow-hidden pointer-events-none">
            <motion.div
              className="absolute top-20 -right-20 w-96 h-96 bg-white/10 rounded-full blur-3xl"
              animate={{
                x: [0, -30, 0],
                scale: [1, 1.2, 1],
              }}
              transition={{
                duration: 10,
                repeat: Infinity,
                ease: "easeInOut",
              }}
            />
          </div>

          <div className="grid lg:grid-cols-2 gap-12 relative z-10">
            <motion.div variants={itemVariants}>
              <h2 className="text-4xl font-bold mb-6">Get In Touch</h2>
              <p className="text-xl text-emerald-50 mb-8">
                Have questions? We're here to help you on your journey to quit
                smoking.
              </p>

              <div className="space-y-4">
                {[
                  {
                    icon: Mail,
                    href: "mailto:info@smartquitiot.com",
                    text: "info@smartquitiot.com",
                  },
                  {
                    icon: Phone,
                    href: "tel:1-800-QUIT-NOW",
                    text: "1-800-QUIT-NOW",
                  },
                  {
                    icon: MapPin,
                    text: "123 Health Street, Wellness City, WC 12345",
                  },
                ].map((item, idx) => {
                  const IconComponent = item.icon;
                  return (
                    <motion.div
                      key={idx}
                      className="flex items-center gap-4"
                      whileHover={{ x: 5 }}
                    >
                      <IconComponent className="w-6 h-6" />
                      {item.href ? (
                        <a href={item.href} className="hover:underline">
                          {item.text}
                        </a>
                      ) : (
                        <span>{item.text}</span>
                      )}
                    </motion.div>
                  );
                })}
              </div>
            </motion.div>

            <motion.div
              className="flex items-center justify-center"
              variants={itemVariants}
            >
              <div className="text-center">
                <h3 className="text-2xl font-bold mb-4">Ready to Quit?</h3>
                <p className="text-emerald-50 mb-6">
                  Join thousands of others who have successfully quit smoking
                  with SmartQuit IoT.
                </p>
                <motion.button
                  onClick={() => navigate("/login")}
                  className="group relative bg-white text-emerald-600 px-8 py-3 rounded-lg font-semibold hover:bg-emerald-50 transition-colors overflow-hidden"
                  whileHover={{ scale: 1.05, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                >
                  <span className="relative z-10">Get Started Today</span>
                </motion.button>
              </div>
            </motion.div>
          </div>
        </motion.div>
      </div>
    </div>
  );
};

export default About;
