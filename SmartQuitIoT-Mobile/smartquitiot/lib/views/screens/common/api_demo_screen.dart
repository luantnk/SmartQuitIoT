// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../viewmodels/demo_view_model.dart';
// import '../../../models/user_profile.dart';

// class ApiDemoScreen extends ConsumerStatefulWidget {
//   const ApiDemoScreen({super.key});

//   @override
//   ConsumerState<ApiDemoScreen> createState() => _ApiDemoScreenState();
// }

// class _ApiDemoScreenState extends ConsumerState<ApiDemoScreen> {
//   final TextEditingController _userIdController = TextEditingController(
//     text: 'user123',
//   );
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();

//   @override
//   void dispose() {
//     _userIdController.dispose();
//     _nameController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final demoState = ref.watch(demoViewModelProvider);
//     final demoViewModel = ref.read(demoViewModelProvider.notifier);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('API Demo - Repository Pattern'),
//         backgroundColor: Colors.blue.shade100,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Header
//             Card(
//               color: Colors.blue.shade50,
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Repository Pattern Demo',
//                       style: Theme.of(context).textTheme.headlineSmall
//                           ?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue.shade800,
//                           ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'This screen demonstrates the complete MVVM + Repository pattern flow:\n'
//                       'UI → ViewModel → Repository → API Service',
//                       style: TextStyle(fontSize: 14, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Status Section
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Status',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         Icon(
//                           demoState.isLoading
//                               ? Icons.hourglass_empty
//                               : Icons.check_circle,
//                           color: demoState.isLoading
//                               ? Colors.orange
//                               : Colors.green,
//                           size: 20,
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             demoState.lastAction,
//                             style: TextStyle(
//                               color: demoState.isLoading
//                                   ? Colors.orange
//                                   : Colors.green,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     if (demoState.errorMessage != null) ...[
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.red.shade50,
//                           borderRadius: BorderRadius.circular(4),
//                           border: Border.all(color: Colors.red.shade200),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.error,
//                               color: Colors.red.shade600,
//                               size: 16,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 demoState.errorMessage!,
//                                 style: TextStyle(
//                                   color: Colors.red.shade700,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () => demoViewModel.clearError(),
//                               icon: Icon(
//                                 Icons.close,
//                                 color: Colors.red.shade600,
//                                 size: 16,
//                               ),
//                               constraints: const BoxConstraints(),
//                               padding: EdgeInsets.zero,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // API Actions Section
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'API Actions',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     // User ID Input
//                     TextField(
//                       controller: _userIdController,
//                       decoration: const InputDecoration(
//                         labelText: 'User ID',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.person),
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     // Action Buttons
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         ElevatedButton.icon(
//                           onPressed: demoState.isLoading
//                               ? null
//                               : () {
//                                   demoViewModel.loadUserProfile(
//                                     _userIdController.text,
//                                   );
//                                 },
//                           icon: const Icon(Icons.person),
//                           label: const Text('Load Profile'),
//                         ),
//                         ElevatedButton.icon(
//                           onPressed: demoState.isLoading
//                               ? null
//                               : () {
//                                   demoViewModel.loadUserStatistics(
//                                     _userIdController.text,
//                                   );
//                                 },
//                           icon: const Icon(Icons.analytics),
//                           label: const Text('Load Statistics'),
//                         ),
//                         ElevatedButton.icon(
//                           onPressed: demoState.isLoading
//                               ? null
//                               : () {
//                                   demoViewModel.loadMultipleUsers([
//                                     'user1',
//                                     'user2',
//                                     'user3',
//                                   ]);
//                                 },
//                           icon: const Icon(Icons.group),
//                           label: const Text('Load Multiple'),
//                         ),
//                         ElevatedButton.icon(
//                           onPressed: demoState.isLoading
//                               ? null
//                               : () {
//                                   demoViewModel.reset();
//                                 },
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Reset'),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Update Profile Section
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Update Profile',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),

//                     TextField(
//                       controller: _nameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Name',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.edit),
//                       ),
//                     ),

//                     const SizedBox(height: 12),

//                     TextField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(
//                         labelText: 'Email',
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.email),
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     ElevatedButton.icon(
//                       onPressed: demoState.isLoading
//                           ? null
//                           : () {
//                               if (_nameController.text.isNotEmpty &&
//                                   _emailController.text.isNotEmpty) {
//                                 final updatedProfile = UserProfile(
//                                   id: _userIdController.text,
//                                   name: _nameController.text,
//                                   email: _emailController.text,
//                                   avatarUrl: 'https://via.placeholder.com/150',
//                                   smokeFreeDays: 30,
//                                   cigarettesAvoided: 100,
//                                   moneySaved: 50.0,
//                                 );
//                                 demoViewModel.updateUserProfile(updatedProfile);
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(
//                                   const SnackBar(
//                                     content: Text(
//                                       'Please fill in name and email',
//                                     ),
//                                   ),
//                                 );
//                               }
//                             },
//                       icon: const Icon(Icons.save),
//                       label: const Text('Update Profile'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Results Section
//             if (demoState.userProfile != null) ...[
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'User Profile Result',
//                         style: Theme.of(context).textTheme.titleMedium
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 12),
//                       _buildProfileInfo(demoState.userProfile!),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],

//             if (demoState.userStatistics != null) ...[
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'User Statistics Result',
//                         style: Theme.of(context).textTheme.titleMedium
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 12),
//                       _buildStatisticsInfo(demoState.userStatistics!),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],

//             if (demoState.multipleUsers != null) ...[
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Multiple Users Result',
//                         style: Theme.of(context).textTheme.titleMedium
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 12),
//                       ...demoState.multipleUsers!.map(
//                         (user) => Padding(
//                           padding: const EdgeInsets.only(bottom: 8.0),
//                           child: _buildProfileInfo(user, compact: true),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileInfo(UserProfile profile, {bool compact = false}) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: compact ? 16 : 24,
//                 backgroundImage: NetworkImage(profile.avatarUrl),
//                 onBackgroundImageError: (_, __) {},
//                 child: const Icon(Icons.person),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       profile.name,
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: compact ? 14 : 16,
//                       ),
//                     ),
//                     Text(
//                       profile.email,
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                         fontSize: compact ? 12 : 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           if (!compact) ...[
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildStatItem('Days', profile.smokeFreeDays.toString()),
//                 _buildStatItem(
//                   'Cigarettes',
//                   profile.cigarettesAvoided.toString(),
//                 ),
//                 _buildStatItem(
//                   'Money',
//                   '\$${profile.moneySaved.toStringAsFixed(2)}',
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsInfo(Map<String, dynamic> stats) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildStatItem('Total Days', stats['totalDays'].toString()),
//               _buildStatItem('Health Score', '${stats['healthScore']}/100'),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildStatItem('Money Saved', stats['formattedMoneySaved']),
//               _buildStatItem('Health Level', stats['healthLevel']),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Last Updated: ${stats['lastUpdatedFormatted']}',
//             style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         Text(
//           label,
//           style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//         ),
//       ],
//     );
//   }
// }
