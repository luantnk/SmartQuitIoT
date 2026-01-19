import Footer from "@/components/Footer";
import Header from "@/components/Header";
import { Outlet } from "react-router-dom";

export default function MainLayout() {
  return (
    <div className="min-h-screen bg-white pt-16">
      <Header />
      <Outlet />
      <Footer />
    </div>
  );
}
