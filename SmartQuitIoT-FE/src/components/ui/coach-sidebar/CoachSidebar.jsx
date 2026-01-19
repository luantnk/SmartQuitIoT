// src/components/ui/coach-sidebar/CoachSidebar.jsx
import React from "react";
import {
  LayoutDashboard,
  Calendar,
  CalendarCheck,
  MessageSquare,
  Users,
  Settings,
  Star,
  FileText,
} from "lucide-react";
import logo from "@/assets/logo.png";
import NavCoachSidebar from "./NavCoachSidebar";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { useNavigate } from "react-router-dom";

const items = [
  { title: "Dashboard", url: "/coach", icon: LayoutDashboard },
  { title: "Schedule", url: "/coach/schedule", icon: Calendar },
  { title: "Appointments", url: "/coach/appointments", icon: CalendarCheck },
  { title: "Chat", url: "/coach/chat", icon: MessageSquare },
  { title: "Members", url: "/coach/members", icon: Users },
  { title: "Feedback", url: "/coach/feedback", icon: Star },
  {
    title: "Community Posts",
    url: "/coach/community-posts",
    icon: FileText,
  },
  { title: "Profile Setting", url: "/coach/profile-setting", icon: Settings },
];

const CoachSidebar = () => {
  const nav = useNavigate();

  return (
    <Sidebar>
      <SidebarHeader>
        <div
          className="flex items-center gap-3 cursor-pointer px-3 py-2"
          onClick={() => nav("/coach")}
        >
          <img src={logo} alt="Logo" className="h-10 w-auto" />
          <div className="text-lg font-bold">
            <span className="text-green-600">Smart</span>
            <span className="text-emerald-950">Quit</span>
          </div>
        </div>
      </SidebarHeader>

      <SidebarContent>
        <div className="px-2">
          <SidebarMenu>
            {items.map((it) => (
              <SidebarMenuItem key={it.title}>
                <SidebarMenuButton asChild>
                  <a
                    onClick={() => nav(it.url)}
                    className="flex items-center gap-3 cursor-pointer p-2 rounded-md hover:bg-muted"
                  >
                    <it.icon className="w-5 h-5" />
                    <span className="text-sm">{it.title}</span>
                  </a>
                </SidebarMenuButton>
              </SidebarMenuItem>
            ))}
          </SidebarMenu>
        </div>
      </SidebarContent>

      <SidebarFooter>
        <NavCoachSidebar />
      </SidebarFooter>
    </Sidebar>
  );
};

export default CoachSidebar;
