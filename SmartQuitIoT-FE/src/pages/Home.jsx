import CTASection from "@/components/CTASection";
import FeaturesSection from "@/components/FeaturesSection";
import HeroSection from "@/components/HeroSection";
import NewsSection from "@/components/NewsSection";
import StatsSection from "@/components/StatsSections";

const Home = () => {
  return (
    <div className="min-h-screen bg-white">
      <HeroSection />
      <StatsSection />
      <FeaturesSection />
      <NewsSection />
      <CTASection />
    </div>
  );
};

export default Home;
