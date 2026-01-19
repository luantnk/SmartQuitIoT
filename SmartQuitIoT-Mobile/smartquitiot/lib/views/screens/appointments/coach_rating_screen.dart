// lib/features/coaching/screens/coach_rating_screen.dart
import 'package:SmartQuitIoT/views/screens/appointments/coach_list_items.dart';
import 'package:SmartQuitIoT/views/screens/appointments/info_card.dart';
import 'package:SmartQuitIoT/views/screens/appointments/rating_star.dart';
import 'package:SmartQuitIoT/views/screens/appointments/tag_selector.dart';

import 'package:flutter/material.dart';

import 'custom_button.dart';

class CoachRatingScreen extends StatefulWidget {
  final Coach coach;

  const CoachRatingScreen({super.key, required this.coach});

  @override
  State<CoachRatingScreen> createState() => _CoachRatingScreenState();
}

class _CoachRatingScreenState extends State<CoachRatingScreen> {
  double rating = 0;
  final TextEditingController commentController = TextEditingController();
  List<String> selectedTags = [];
  bool isSubmitting = false;

  final List<String> tags = [
    'Professional',
    'Enthusiastic',
    'Effective',
    'Easy to understand',
    'Dedicated',
    'Patient',
  ];

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3), // body background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00D09E), // header background
        centerTitle: true, // center text
        title: const Text(
          'Coach Rating',
          style: TextStyle(
            color: Colors.white, // white text
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white), // white icon
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildCoachHeader(),
              const SizedBox(height: 32),
              _buildRatingSection(),
              const SizedBox(height: 32),
              _buildTagsSection(),
              const SizedBox(height: 20),
              _buildCommentSection(),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Submit Rating',
                onPressed: rating > 0 ? _submitRating : null,
                isLoading: isSubmitting,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoachHeader() {
    return Column(
      children: [
        _buildAvatarWithFallback(widget.coach.imageUrl, widget.coach.name),
        const SizedBox(height: 16),
        Text(
          widget.coach.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How did you feel about the session?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWithFallback(String imageUrl, String name) {
    final initials = name.isNotEmpty
        ? name.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : '?';
    final isValidUrl = imageUrl.isNotEmpty &&
        !imageUrl.contains('example.com') &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF00D09E).withOpacity(0.1),
      ),
      child: isValidUrl
          ? ClipOval(
              child: Image.network(
                imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00D09E).withOpacity(0.15),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D09E),
                        ),
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00D09E).withOpacity(0.15),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                      ),
                    ),
                  );
                },
              ),
            )
          : Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D09E).withOpacity(0.15),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00D09E),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        RatingStars(
          rating: rating,
          onRatingChanged: (newRating) {
            setState(() {
              rating = newRating;
            });
          },
        ),
        if (rating > 0) ...[
          const SizedBox(height: 12),
          Text(
            _getRatingText(rating),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6366F1),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTagsSection() {
    return InfoCard(
      title: 'Highlights',
      child: TagSelector(
        tags: tags,
        selectedTags: selectedTags,
        onTagToggle: (tag) {
          setState(() {
            if (selectedTags.contains(tag)) {
              selectedTags.remove(tag);
            } else {
              selectedTags.add(tag);
            }
          });
        },
      ),
    );
  }

  Widget _buildCommentSection() {
    return InfoCard(
      title: 'Your Feedback',
      child: TextField(
        controller: commentController,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: 'Share your experience...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF6366F1)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating <= 2) return 'Needs Improvement';
    if (rating <= 3) return 'Fair';
    if (rating <= 4) return 'Good';
    return 'Excellent!';
  }

  void _submitRating() {
    setState(() {
      isSubmitting = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Thank you!'),
            ],
          ),
          content: const Text(
            'Your feedback helps us improve our service quality.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Close', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      );
    });
  }
}
