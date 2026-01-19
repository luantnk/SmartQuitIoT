import '../models/leaderboard_member.dart';
import '../services/achievement_service.dart';

class LeaderboardRepository {
  final AchievementService _achievementService;

  LeaderboardRepository(this._achievementService);

  /// Get top leaderboards
  Future<List<LeaderboardMember>> getTopLeaderBoards() async {
    try {
      print('📝 [LeaderboardRepository] Fetching top leaderboards...');
      
      final response = await _achievementService.getTopLeaderBoards();
      
      print('✅ [LeaderboardRepository] Response status: ${response.statusCode}');
      print('📦 [LeaderboardRepository] Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        
        print('📊 [LeaderboardRepository] Found ${data.length} members in leaderboard');
        
        final leaderboard = data
            .map((json) => LeaderboardMember.fromJson(json as Map<String, dynamic>))
            .toList();
        
        print('✅ [LeaderboardRepository] Successfully parsed ${leaderboard.length} members');
        
        return leaderboard;
      } else {
        print('⚠️ [LeaderboardRepository] Unexpected status code: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      print('❌ [LeaderboardRepository] Error fetching leaderboards: $e');
      print('🧩 [LeaderboardRepository] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
