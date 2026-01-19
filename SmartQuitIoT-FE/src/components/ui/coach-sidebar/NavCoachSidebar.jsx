// src/components/ui/coach-sidebar/NavCoachSidebar.jsx
import React, { useEffect, useState } from "react";
import { MoonIcon, MoreVertical, SunIcon } from "lucide-react";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import {
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { Switch } from "@/components/ui/switch";
import { useTheme } from "@/context/theme-provider";
import { getAdminProfile } from "@/services/accountService";
import { useNavigate } from "react-router-dom";

const NavCoachSidebar = () => {
  const { theme, setTheme } = useTheme();
  const [profile, setProfile] = useState({});
  const nav = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    nav("/login");
  };

  useEffect(() => {
    (async () => {
      try {
        const res = await getAdminProfile(); // đổi sang getCoachProfile nếu có
        if (res?.status === 200) setProfile(res.data);
      } catch (e) {
        console.error("fetch profile failed", e);
      }
    })();
  }, []);

  return (
    <SidebarMenu>
      <SidebarMenuItem>
        <Popover>
          <PopoverTrigger asChild>
            <SidebarMenuButton
              size="lg"
              className="data-[state=open]:bg-sidebar-accent"
            >
              <Avatar className="h-8 w-8 rounded-lg grayscale">
                <AvatarImage
                  src={`https://ui-avatars.com/api/?name=${
                    profile.name || "CO"
                  }`}
                  alt={profile.name}
                />
                <AvatarFallback className="rounded-lg">CO</AvatarFallback>
              </Avatar>

              <div className="grid flex-1 text-left text-sm leading-tight ml-2">
                <span className="truncate font-medium">
                  {profile.name || "Coach"}
                </span>
                <span className="text-muted-foreground truncate text-xs">
                  {profile.email || ""}
                </span>
              </div>

              <MoreVertical className="ml-auto size-4" />
            </SidebarMenuButton>
          </PopoverTrigger>

          <PopoverContent className="w-60" align="end">
            <div className="grid gap-4">
              <div className="space-y-2">
                <h4 className="leading-none font-medium">Coach Panel</h4>
              </div>
              <p className="text-muted-foreground text-sm">{profile.email}</p>
              <div className="grid gap-2">
                <div className="grid grid-cols-3 items-center gap-4">
                  <Switch
                    id="theme-mode-coach"
                    checked={theme === "dark"}
                    onCheckedChange={() =>
                      setTheme(theme === "light" ? "dark" : "light")
                    }
                  />
                  <Label htmlFor="theme-mode-coach">
                    {theme === "dark" ? (
                      <MoonIcon className="w-5 h-5" />
                    ) : (
                      <SunIcon className="w-5 h-5" />
                    )}
                  </Label>
                </div>

                <div className="grid grid-cols-1 items-center gap-4">
                  <Button variant={"destructive"} onClick={handleLogout}>
                    Log Out
                  </Button>
                </div>
              </div>
            </div>
          </PopoverContent>
        </Popover>
      </SidebarMenuItem>
    </SidebarMenu>
  );
};

export default NavCoachSidebar;
