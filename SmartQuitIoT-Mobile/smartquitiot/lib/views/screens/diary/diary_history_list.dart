import 'package:flutter/material.dart';

class DiaryHistoryList extends StatelessWidget {
  final String filter;

  const DiaryHistoryList({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    // demo list items
    final items = List.generate(10, (index) => 'Day ${index + 1}');

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _DiaryHistoryCard(title: items[index]);
      },
    );
  }
}

class _DiaryHistoryCard extends StatelessWidget {
  final String title;

  const _DiaryHistoryCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(title),
        subtitle: const Text('Smoke-free day with some notes here'),
      ),
    );
  }
}
