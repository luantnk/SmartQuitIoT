import 'package:flutter/material.dart';

class DiaryAnalyticsBottomSheet extends StatelessWidget {
  const DiaryAnalyticsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: const [
              ListTile(
                title: Text('Analytics'),
                subtitle: Text('More detailed analytics here…'),
              ),
            ],
          ),
        );
      },
    );
  }
}
