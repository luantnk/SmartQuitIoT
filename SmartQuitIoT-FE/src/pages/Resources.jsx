import { motion } from "framer-motion";
import {
  BookOpen,
  Video,
  FileText,
  Headphones,
  Download,
  ExternalLink,
  Sparkles,
} from "lucide-react";

const resources = [
  {
    category: "Educational Articles",
    icon: BookOpen,
    gradient: "from-blue-500 to-indigo-600",
    items: [
      {
        title: "Understanding Nicotine Addiction",
        description:
          "Learn about the science behind nicotine addiction and how it affects your brain and body.",
        link: "https://www.cdc.gov/tobacco/quit_smoking/how_to_quit/index.htm",
        type: "Article",
      },
      {
        title: "Health Benefits Timeline",
        description:
          "Discover the positive changes your body experiences when you quit smoking.",
        link: "https://www.cancer.org/healthy/stay-away-from-tobacco/benefits-of-quitting-smoking-over-time.html",
        type: "Guide",
      },
      {
        title: "Coping with Withdrawal Symptoms",
        description:
          "Effective strategies to manage and overcome nicotine withdrawal symptoms.",
        link: "https://smokefree.gov/challenges-when-quitting/withdrawal",
        type: "Article",
      },
    ],
  },
  {
    category: "Video Resources",
    icon: Video,
    gradient: "from-purple-500 to-pink-600",
    items: [
      {
        title: "Quitting Smoking: A Complete Guide",
        description:
          "Comprehensive video series covering all aspects of the quitting journey.",
        link: "https://www.youtube.com/results?search_query=quit+smoking+guide",
        type: "Video Series",
      },
      {
        title: "Breathing Exercises for Cravings",
        description:
          "Learn breathing techniques to manage cravings and reduce stress.",
        link: "https://www.youtube.com/results?search_query=breathing+exercises+quit+smoking",
        type: "Tutorial",
      },
    ],
  },
  {
    category: "Support & Community",
    icon: Headphones,
    gradient: "from-emerald-500 to-teal-600",
    items: [
      {
        title: "Quitline Support",
        description:
          "Free telephone counseling service available 24/7 to help you quit.",
        link: "tel:1-800-QUIT-NOW",
        type: "Hotline",
      },
      {
        title: "Online Support Groups",
        description:
          "Connect with others on the same journey through moderated forums and chat rooms.",
        link: "https://www.quitnow.net/support-groups",
        type: "Community",
      },
      {
        title: "SmartQuit Community",
        description:
          "Join our exclusive community to share experiences and get support from fellow members.",
        link: "/community",
        type: "Platform",
      },
    ],
  },
  {
    category: "Mobile Apps & Tools",
    icon: Download,
    gradient: "from-orange-500 to-red-600",
    items: [
      {
        title: "Smoke Free App",
        description:
          "Track your progress, save money, and stay motivated with this comprehensive app.",
        link: "https://smokefree.gov/tools-tips/apps",
        type: "Mobile App",
      },
      {
        title: "Quit Tracker",
        description:
          "Monitor your quit journey with detailed statistics and achievements.",
        link: "https://smokefree.gov/tools-tips/apps",
        type: "Mobile App",
      },
    ],
  },
  {
    category: "Downloadable Guides",
    icon: FileText,
    gradient: "from-cyan-500 to-blue-600",
    items: [
      {
        title: "Quit Plan Template",
        description:
          "Personalized quit plan worksheet to help you prepare for success.",
        link: "#",
        type: "PDF Download",
      },
      {
        title: "Craving Management Worksheet",
        description:
          "Track and analyze your cravings to identify triggers and patterns.",
        link: "#",
        type: "PDF Download",
      },
      {
        title: "Daily Progress Journal",
        description:
          "Keep track of your thoughts, challenges, and victories during your quit journey.",
        link: "#",
        type: "PDF Download",
      },
    ],
  },
];

const Resources = () => {
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
      <div className="relative bg-gradient-to-r from-emerald-500 to-teal-600 text-white py-16 overflow-hidden">
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
            <span className="font-semibold text-sm">RESOURCES</span>
          </motion.div>
          <h1 className="text-4xl md:text-5xl font-bold mb-4">
            Resources to Support Your Journey
          </h1>
          <p className="text-xl text-emerald-50 max-w-3xl">
            Access a comprehensive collection of tools, guides, and support
            materials to help you quit smoking successfully.
          </p>
        </motion.div>
      </div>

      {/* Resources Content */}
      <div className="max-w-7xl mx-auto px-6 py-12">
        <div className="space-y-12">
          {resources.map((category, idx) => {
            const IconComponent = category.icon;
            return (
              <motion.div
                key={idx}
                className="relative bg-white rounded-2xl shadow-lg p-8 overflow-hidden"
                initial="hidden"
                whileInView="visible"
                viewport={{ once: true }}
                variants={fadeInUp}
              >
                {/* Decorative gradient blob */}
                <motion.div
                  className={`absolute -top-10 -right-10 w-40 h-40 bg-gradient-to-br ${category.gradient} opacity-5 rounded-full blur-2xl`}
                  animate={{
                    scale: [1, 1.2, 1],
                    rotate: [0, 90, 0],
                  }}
                  transition={{
                    duration: 8,
                    repeat: Infinity,
                    ease: "easeInOut",
                  }}
                />

                <div className="flex items-center gap-3 mb-6 relative z-10">
                  <motion.div
                    className={`p-3 bg-gradient-to-br ${category.gradient} rounded-lg shadow-lg`}
                    whileHover={{ rotate: 360, scale: 1.1 }}
                    transition={{ duration: 0.6 }}
                  >
                    <IconComponent className="w-6 h-6 text-white" />
                  </motion.div>
                  <h2 className="text-2xl font-bold text-gray-900">
                    {category.category}
                  </h2>
                </div>

                <motion.div
                  className="grid md:grid-cols-2 lg:grid-cols-3 gap-6"
                  variants={containerVariants}
                  initial="hidden"
                  whileInView="visible"
                  viewport={{ once: true }}
                >
                  {category.items.map((item, itemIdx) => (
                    <motion.div
                      key={itemIdx}
                      className="group relative border border-gray-200 rounded-xl p-6 hover:shadow-xl transition-all bg-white overflow-hidden"
                      variants={itemVariants}
                      whileHover={{ y: -8, scale: 1.02 }}
                    >
                      {/* Hover gradient effect */}
                      <motion.div
                        className={`absolute inset-0 bg-gradient-to-br ${category.gradient} opacity-0 group-hover:opacity-5 transition-opacity duration-500`}
                      />

                      <div className="relative z-10">
                        <div className="flex items-start justify-between mb-3">
                          <h3 className="font-semibold text-lg text-gray-900 flex-1 group-hover:text-emerald-600 transition-colors">
                            {item.title}
                          </h3>
                          <span className="text-xs bg-emerald-100 text-emerald-700 px-2 py-1 rounded-full whitespace-nowrap ml-2">
                            {item.type}
                          </span>
                        </div>
                        <p className="text-gray-600 text-sm mb-4 line-clamp-3">
                          {item.description}
                        </p>
                        <motion.a
                          href={item.link}
                          target={
                            item.link.startsWith("http") ? "_blank" : undefined
                          }
                          rel={
                            item.link.startsWith("http")
                              ? "noopener noreferrer"
                              : undefined
                          }
                          className="inline-flex items-center gap-2 text-emerald-600 hover:text-emerald-700 font-medium text-sm group"
                          whileHover={{ x: 5 }}
                        >
                          {item.link === "#" ? "Download" : "Access Resource"}
                          <motion.div
                            whileHover={{ x: 3 }}
                            transition={{ duration: 0.2 }}
                          >
                            <ExternalLink className="w-4 h-4" />
                          </motion.div>
                        </motion.a>
                      </div>
                    </motion.div>
                  ))}
                </motion.div>
              </motion.div>
            );
          })}
        </div>

        {/* Call to Action */}
        <motion.div
          className="relative mt-16 bg-gradient-to-r from-emerald-50 to-teal-50 rounded-2xl p-8 border border-emerald-200 overflow-hidden"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={fadeInUp}
        >
          {/* Animated background blob */}
          <motion.div
            className="absolute -top-20 -right-20 w-64 h-64 bg-emerald-300/10 rounded-full blur-3xl"
            animate={{
              scale: [1, 1.3, 1],
              rotate: [0, 180, 0],
            }}
            transition={{
              duration: 10,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />

          <div className="text-center relative z-10">
            <motion.h3
              className="text-2xl font-bold text-gray-900 mb-3 bg-gradient-to-r from-emerald-600 to-teal-600 bg-clip-text text-transparent"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
            >
              Need Personalized Support?
            </motion.h3>
            <motion.p
              className="text-gray-600 mb-6 max-w-2xl mx-auto"
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.1 }}
            >
              Join SmartQuit IoT and get access to personalized coaching,
              tracking tools, and a supportive community to help you succeed.
            </motion.p>
            <motion.a
              href="/download"
              className="group relative inline-block bg-gradient-to-r from-emerald-500 to-teal-600 text-white px-8 py-3 rounded-lg font-semibold shadow-lg overflow-hidden"
              whileHover={{ scale: 1.05, y: -2 }}
              whileTap={{ scale: 0.95 }}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.2 }}
            >
              <span className="relative z-10">Get Started Today</span>
              <div className="absolute inset-0 bg-gradient-to-r from-white/0 via-white/20 to-white/0 translate-x-[-100%] group-hover:translate-x-[100%] transition-transform duration-700"></div>
            </motion.a>
          </div>
        </motion.div>
      </div>
    </div>
  );
};

export default Resources;
