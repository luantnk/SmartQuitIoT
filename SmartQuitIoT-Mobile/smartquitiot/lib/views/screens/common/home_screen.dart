import 'package:SmartQuitIoT/views/screens/achievements/achievements_card.dart';
import 'package:SmartQuitIoT/views/screens/appointments/coach_appointment_card.dart';
import 'package:SmartQuitIoT/views/screens/common/membership_shortcut_card.dart';
import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/widgets/headers/home_header.dart';
import 'package:SmartQuitIoT/views/widgets/cards/smoke_free_timer_card.dart';
import 'package:SmartQuitIoT/views/screens/stats_table/stats_table_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/health_improvement_card.dart';
import 'package:SmartQuitIoT/views/screens/quitplans/quit_plan_card.dart';
import 'package:SmartQuitIoT/views/screens/missions/today_mission_card.dart';
// import 'package:SmartQuitIoT/views/widgets/cards/analysis_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/community_trending_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/recent_news_card.dart';
import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_welcome_screen.dart';
import 'package:SmartQuitIoT/views/widgets/cards/diary_record_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/form_metric_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80), // tránh che FAB
          child: Column(
            children: const [
              HomeHeader(),
              SmokeFreeTimerCard(),
              MembershipShortcutCard(),
              DiaryRecordCard(),
              CoachAppointmentCard(),
              StatsTableCard(),
              HealthImprovementCard(),
              AchievementsCard(),
              QuitPlanCard(),
              TodayMissionCard(),
              FormMetricCard(),
              // AnalysisCard(),
              CommunityTrendingCard(),

              RecentNewsCard(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AiChatWelcomeScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF00D09E), // màu xanh chủ đạo
        elevation: 8,
        child: const Icon(
          Icons.smart_toy, // AI icon
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
