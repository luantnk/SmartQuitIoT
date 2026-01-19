// import 'package:flutter/material.dart';

// class NotificationDetailScreen extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final Color iconColor;

//   const NotificationDetailScreen({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.iconColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1FFF3),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF00D09E),
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Notification Details',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header Card
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.08),
//                     spreadRadius: 1,
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   // Fixed Image
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: iconColor.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Image.asset(
//                         'lib/assets/images/Achievement.png',
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Title
//                   Text(
//                     title,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                       height: 1.3,
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   // Subtitle
//                   Text(
//                     subtitle,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.grey[600],
//                       height: 1.4,
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Time stamp
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.access_time,
//                           size: 16,
//                           color: Colors.grey[600],
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           '2 hours ago',
//                           style: TextStyle(
//                             fontSize: 13,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Details Section
//             _buildDetailSection(),

//             const SizedBox(height: 24),

//             // Action Buttons
//             _buildActionButtons(context),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailSection() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.08),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Details',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),

//           const SizedBox(height: 16),

//           _buildDetailItem('Status', 'Unread', Colors.orange),
//           _buildDetailItem('Priority', 'High', Colors.red),
//           _buildDetailItem('Category', _getCategoryFromTitle(), iconColor),
//           _buildDetailItem('Source', 'Health App', Colors.blue),

//           const SizedBox(height: 20),

//           const Text(
//             'Description',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),

//           const SizedBox(height: 12),

//           Text(
//             _getDetailDescription(),
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[700],
//               height: 1.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailItem(String label, String value, Color valueColor) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 14,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//             decoration: BoxDecoration(
//               color: valueColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: 13,
//                 color: valueColor,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context) {
//     return Column(
//       children: [
//         // Primary Action Button
//         SizedBox(
//           width: double.infinity,
//           height: 50,
//           // child: ElevatedButton(
//           //   onPressed: () {
//           //     // Mark as read action
//           //     ScaffoldMessenger.of(context).showSnackBar(
//           //       const SnackBar(
//           //         content: Text('Notification marked as read'),
//           //         duration: Duration(seconds: 2),
//           //       ),
//           //     );
//           //   },
//           //   style: ElevatedButton.styleFrom(
//           //     backgroundColor: iconColor,
//           //     foregroundColor: Colors.white,
//           //     shape: RoundedRectangleBorder(
//           //       borderRadius: BorderRadius.circular(25),
//           //     ),
//           //     elevation: 0,
//           //   ),
//           //   child: const Text(
//           //     'Mark as Read',
//           //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           //   ),
//           // ),
//         ),

//         const SizedBox(height: 12),

//         // Secondary Actions Row
//         // Row(
//         //   children: [
//         //     Expanded(
//         //       child: OutlinedButton.icon(
//         //         onPressed: () {},
//         //         icon: Icon(Icons.archive, size: 18, color: Colors.grey[600]),
//         //         label: Text(
//         //           'Archive',
//         //           style: TextStyle(color: Colors.grey[700]),
//         //         ),
//         //         style: OutlinedButton.styleFrom(
//         //           padding: const EdgeInsets.symmetric(vertical: 12),
//         //           shape: RoundedRectangleBorder(
//         //             borderRadius: BorderRadius.circular(25),
//         //           ),
//         //           side: BorderSide(color: Colors.grey[300]!),
//         //         ),
//         //       ),
//         //     ),

//         //     const SizedBox(width: 12),

//         //     Expanded(
//         //       child: OutlinedButton.icon(
//         //         onPressed: () {},
//         //         icon: Icon(
//         //           Icons.delete_outline,
//         //           size: 18,
//         //           color: Colors.red[400],
//         //         ),
//         //         label: Text('Delete', style: TextStyle(color: Colors.red[400])),
//         //         style: OutlinedButton.styleFrom(
//         //           padding: const EdgeInsets.symmetric(vertical: 12),
//         //           shape: RoundedRectangleBorder(
//         //             borderRadius: BorderRadius.circular(25),
//         //           ),
//         //           side: BorderSide(color: Colors.red[200]!),
//         //         ),
//         //       ),
//         //     ),
//         //   ],
//         // ),
//       ],
//     );
//   }

//   String _getCategoryFromTitle() {
//     if (title.contains('Message') || title.contains('Chat')) return 'Messages';
//     if (title.contains('Activity') || title.contains('Step')) return 'Activity';
//     if (title.contains('Health') || title.contains('Vitamin')) return 'Health';
//     if (title.contains('Sleep')) return 'Sleep';
//     return 'General';
//   }

//   String _getDetailDescription() {
//     switch (title) {
//       case 'Unread AI Chatbot Message':
//         return 'You have received new messages from Doc A in your AI health assistant. The messages contain important health recommendations based on your recent activity data. Please review them to stay on track with your health goals.';
//       case 'Activity Completed':
//         return 'Congratulations! You have successfully completed your daily activity logging. Your consistency in tracking activities helps us provide better health insights and personalized recommendations.';
//       case 'Monthly Health Insight':
//         return 'Your comprehensive monthly health report is now available. This report includes detailed analysis of your health metrics, progress towards goals, and personalized recommendations for the upcoming month.';
//       case 'Take More Steps!':
//         return 'You\'re doing great, but you can do even better! You need 3,150 more steps to reach your daily goal. Consider taking a walk or using the stairs to boost your step count.';
//       case 'Sleep More!':
//         return 'Quality sleep is crucial for your health. You\'ve completed 14% of your 8-hour sleep goal. Try to establish a consistent bedtime routine for better sleep quality.';
//       case 'Daily Vitamin Completed':
//         return 'Excellent work on maintaining your daily vitamin regimen! You\'ve successfully taken your prescribed 500mg vitamin dose including Vitamin A and Ibuprofen. Consistency in medication adherence is key to optimal health outcomes.';
//       default:
//         return 'This notification contains important information about your health and wellness journey. Please review the details and take appropriate action if needed.';
//     }
//   }
// }
