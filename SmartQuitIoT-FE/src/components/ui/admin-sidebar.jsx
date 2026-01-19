import { LayoutDashboard, List, Newspaper, Bell } from "lucide-react";

import logo from "@/assets/logo.png";
import NavAdminSidebar from "@/components/ui/nav-admin-sidebar";
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { useNavigate } from "react-router-dom";

const items = [
  {
    title: "Dashboard",
    url: "/admin",
    icon: LayoutDashboard,
  },
  {
    title: "Manage Missions",
    url: "/admin/manage-missions",
    icon: List,
  },
  {
    title: "Manage Achievements",
    url: "/admin/manage-achievements",
    icon: List,
  },
  {
    title: "Manage Members",
    url: "/admin/manage-members",
    icon: List,
  },
  {
    title: "Manage Coaches",
    url: "/admin/manage-coaches",
    icon: List,
  },
  {
    title: "Manage Packages",
    url: "/admin/manage-membership-packages",
    icon: List,
  },
  {
    title: "Manage Subscriptions",
    url: "/admin/manage-subscriptions",
    icon: List,
  },
  {
    title: "Manage Payments",
    url: "/admin/manage-payments",
    icon: List,
  },
  {
    title: "Manage Pass Conditions",
    url: "/admin/manage-pass-conditions",
    icon: List,
  },
  // {
  //   title: "Manage Phases",
  //   url: "/admin/manage-phases",
  //   icon: List,
  // },

  {
    title: "Manage Schedules",
    url: "/admin/manage-schedule",
    icon: List,
  },
  {
    title: "Manage Slot Times",
    url: "/admin/manage-slot-times",
    icon: List,
  },
  {
    title: "Manage Appointments",
    url: "/admin/manage-appointments",
    icon: List,
  },
  {
    title: "Manage Reminder Templates",
    url: "/admin/manage-reminder-templates",
    icon: Bell,
  },
  //Feedbacks, Appointments
];

const appItems = [
  {
    title: "News Feed",
    url: "/admin/news-feeds",
    icon: Newspaper,
  },
  {
    title: "Community Posts",
    url: "/admin/community-posts",
    icon: Newspaper,
  },
];

const AdminSidebar = () => {
  const nav = useNavigate();

  return (
    <Sidebar>
      <SidebarHeader>
        <div
          className="flex justify-center items-center space-x-2 cursor-pointer"
          onClick={() => nav("/admin")}
        >
          <img src={logo} alt="Logo" className="h-12 w-auto" />
          <h1 className="text-2xl font-bold">
            <span className="text-green-600">Smart</span>
            <span className="text-emerald-950">Quit</span>
          </h1>
        </div>
      </SidebarHeader>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Applications</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {appItems.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild>
                    <a
                      onClick={() => nav(item.url)}
                      className="flex items-center space-x-2 cursor-pointer"
                    >
                      <item.icon />
                      <span>{item.title}</span>
                    </a>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
        <SidebarGroup>
          <SidebarGroupLabel>Administrator</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {items.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild>
                    <a
                      onClick={() => nav(item.url)}
                      className="flex items-center space-x-2 cursor-pointer"
                    >
                      <item.icon />
                      <span>{item.title}</span>
                    </a>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
      <SidebarFooter>
        <NavAdminSidebar />
      </SidebarFooter>
    </Sidebar>
  );
};

export default AdminSidebar;
