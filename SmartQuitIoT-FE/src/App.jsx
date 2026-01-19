import AppLoading from "@/components/loadings/AppLoading";
import AdminLayout from "@/layouts/AdminLayout";
import AddCoachPage from "@/pages/admin/pages/AddCoachPage";
import AdminPage from "@/pages/admin/pages/AdminPage";
import CreateNewsPage from "@/pages/admin/pages/CreateNewsPage";
import ManageCoaches from "@/pages/admin/pages/ManageCoaches";
import ManageMembershipPackage from "@/pages/admin/pages/ManageMembershipPackage";
import ManageMissions from "@/pages/admin/pages/ManageMissions";
import MissionDetail from "@/pages/admin/pages/MissionDetail";
import CreateMission from "@/pages/admin/pages/CreateMission";
import EditMission from "@/pages/admin/pages/EditMission";
import ManageNews from "@/pages/admin/pages/ManageNews";
import ManageSlots from "@/pages/admin/pages/ManageSlots";
import SchedulePage from "@/pages/admin/pages/SchedulePage";
import NotFound from "@/pages/error/NotFound";
import Home from "@/pages/Home";
import Login from "@/pages/Login";
import { useEffect, useState } from "react";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import DashboardRedirect from "./components/DashboardRedirect";
import ConfirmProvider from "./context/ConfirmProvider";
import ToastProvider from "./context/ToastProvider";
import CoachLayout from "./layouts/CoachLayout";
import MainLayout from "./layouts/MainLayout";
import About from "./pages/About";
import CoachPage from "./pages/coach/CoachPage";
import Community from "./pages/Community";
import News from "./pages/News";
import NewsDetail from "./pages/NewsDetail";
import Resources from "./pages/Resources";
import Download from "./pages/Download";
import CoachSchedulePage from "@/pages/coach/CoachSchedulePage";
import CoachAppointmentsPage from "@/pages/coach/CoachAppointmentsPage";
import CoachChatPage from "@/pages/coach/CoachChatPage";
import MeetingPage from "@/pages/coach/MeetingPage";
import ManageAchievements from "@/pages/admin/pages/ManageAchievements";
import AchievementDetail from "@/pages/admin/pages/AchievementDetail";
import CreateAchievement from "@/pages/admin/pages/CreateAchievement";
import EditAchievement from "@/pages/admin/pages/EditAchievement";
import ManagePhases from "@/pages/admin/pages/ManagePhases";
import ManagePassCondition from "@/pages/admin/pages/ManagePassCondition";
import ManagePayment from "@/pages/admin/pages/ManagePayment";
import ManageReminderTemplates from "@/pages/admin/pages/ManageReminderTemplates";
import ManageSubscriptions from "@/pages/admin/pages/ManageSubscriptions";
import ManageMembers from "@/pages/admin/pages/ManageMembers";
import ManagePosts from "@/pages/admin/pages/ManagePosts";
import MemberDetail from "@/pages/admin/pages/MemberDetail";
import CoachDetail from "@/pages/admin/pages/CoachDetail";
import MemberDiaryRecords from "@/pages/admin/pages/MemberDiaryRecords";
import MemberManagementPage from "@/pages/coach/MemberManagementPage";
import CommunityPosts from "./pages/admin/pages/CommunityPosts";
import WebsocketProvider from "./context/WebsocketProvider";
import FeedbackPage from "./pages/coach/FeedbackPage";
import NewsFeeds from "./pages/admin/pages/NewsFeeds";
import NewsFeedDetail from "./pages/admin/pages/NewsFeedDetail";
import CommunityPostsPage from "./pages/coach/CommunityPosts";
import ManageAppointment from "@/pages/admin/pages/ManageAppointment";
import ProfileSettingPage from "./pages/coach/ProfileSettingPage";
function App() {
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setTimeout(() => {
      setIsLoading(false);
    }, 1500);
  }, []);
  if (isLoading) {
    return <AppLoading />;
  }

  const router = createBrowserRouter([
    {
      path: "*",
      element: <NotFound />,
    },
    { path: "/dashboard", element: <DashboardRedirect /> },
    {
      path: "/login",
      element: <Login />,
    },

    {
      element: <MainLayout />,
      children: [
        { path: "/", element: <Home /> },
        { path: "/resources", element: <Resources /> },
        { path: "/community", element: <Community /> },
        { path: "/news", element: <News /> },
        { path: "/news/:id", element: <NewsDetail /> },
        { path: "/about", element: <About /> },
        { path: "/download", element: <Download /> },
      ],
    },
    {
      element: <CoachLayout />,
      children: [
        { path: "/coach", element: <CoachPage /> },
        { path: "/coach/schedule", element: <CoachSchedulePage /> },
        { path: "/coach/appointments", element: <CoachAppointmentsPage /> },
        { path: "/coach/chat", element: <CoachChatPage /> },
        { path: "/meeting/:appointmentId", element: <MeetingPage /> },
        { path: "/coach/members", element: <MemberManagementPage /> },
        { path: "/coach/feedback", element: <FeedbackPage /> },
        { path: "/coach/community-posts", element: <CommunityPostsPage /> },
        { path: "/coach/profile-setting", element: <ProfileSettingPage /> },
      ],
    },
    {
      element: <AdminLayout />,
      children: [
        {
          path: "/admin/news-feeds",
          element: <NewsFeeds />,
        },
        {
          path: "/admin/news-feeds/:id",
          element: <NewsFeedDetail />,
        },
        {
          path: "/admin/community-posts",
          element: <CommunityPosts />,
        },
        {
          path: "/admin",
          element: <AdminPage />,
        },
        {
          path: "/admin/manage-schedule",
          element: <SchedulePage />,
        },
        {
          path: "/admin/manage-coaches",
          element: <ManageCoaches />,
        },
        {
          path: "/admin/manage-coaches/create",
          element: <AddCoachPage />,
        },
        {
          path: "/admin/manage-membership-packages",
          element: <ManageMembershipPackage />,
        },
        {
          path: "/admin/manage-slot-times",
          element: <ManageSlots />,
        },
        {
          path: "/admin/manage-news",
          element: <ManageNews />,
        },
        {
          path: "/admin/manage-news/create",
          element: <CreateNewsPage />,
        },
        {
          path: "/admin/manage-missions",
          element: <ManageMissions />,
        },
        {
          path: "/admin/manage-missions/create",
          element: <CreateMission />,
        },
        {
          path: "/admin/manage-missions/edit/:id",
          element: <EditMission />,
        },
        {
          path: "/admin/manage-missions/:id",
          element: <MissionDetail />,
        },
        {
          path: "/admin/manage-achievements",
          element: <ManageAchievements />,
        },
        {
          path: "/admin/manage-achievements/create",
          element: <CreateAchievement />,
        },
        {
          path: "/admin/manage-achievements/edit/:id",
          element: <EditAchievement />,
        },
        {
          path: "/admin/manage-achievements/:id",
          element: <AchievementDetail />,
        },
        {
          path: "/admin/manage-phases",
          element: <ManagePhases />,
        },
        {
          path: "/admin/manage-pass-conditions",
          element: <ManagePassCondition />,
        },
        {
          path: "/admin/manage-payments",
          element: <ManagePayment />,
        },
        {
          path: "/admin/manage-reminder-templates",
          element: <ManageReminderTemplates />,
        },
        {
          path: "/admin/manage-subscriptions",
          element: <ManageSubscriptions />,
        },
        {
          path: "/admin/manage-members",
          element: <ManageMembers />,
        },
        {
          path: "/admin/manage-posts",
          element: <ManagePosts />,
        },
        {
          path: "/admin/manage-members/:memberId",
          element: <MemberDetail />,
        },
        {
          path: "/admin/manage-coaches/:coachId",
          element: <CoachDetail />,
        },
        {
          path: "/admin/manage-members/diary/:memberId",
          element: <MemberDiaryRecords />,
        },
        {
          path: "/admin/manage-appointments",
          element: <ManageAppointment />,
        },
      ],
    },
  ]);

  return (
    <ToastProvider>
      <WebsocketProvider>
        <ConfirmProvider>
          <RouterProvider router={router} />
        </ConfirmProvider>
      </WebsocketProvider>
    </ToastProvider>
  );
}

export default App;
