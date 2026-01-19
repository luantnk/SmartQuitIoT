import { useNavigate } from "react-router-dom";

const CTASection = () => {
  const navigate = useNavigate();
  return (
    <section className="py-16 px-4 sm:px-6 lg:px-8 bg-white">
      <div className="max-w-4xl mx-auto text-center">
        <h2 className="text-4xl font-bold text-gray-900 mb-8">
          Ready to Start Your Journey?
        </h2>
        <div className="flex flex-wrap justify-center gap-4">
          <button onClick={() => navigate("/login")} className="cursor-pointer bg-green-600 hover:bg-green-700 text-white font-semibold px-8 py-4 rounded-lg transition-colors shadow-lg hover:shadow-xl">
            Get Started Now →
          </button>
          <button onClick={() => navigate("/about")} className="cursor-pointer bg-white hover:bg-gray-50 text-gray-900 font-semibold px-8 py-4 rounded-lg border-2 border-gray-300 transition-colors">
            Learn More →
          </button>
        </div>
      </div>
    </section>
  );
};
export default CTASection;