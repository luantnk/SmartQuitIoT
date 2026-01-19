import 'package:flutter/material.dart';

class FilterPostsModal extends StatefulWidget {
  final ScrollController controller;
  final Map<String, dynamic>? currentFilter;

  const FilterPostsModal({
    super.key,
    required this.controller,
    this.currentFilter,
  });

  @override
  State<FilterPostsModal> createState() => _FilterPostsModalState();
}

class _FilterPostsModalState extends State<FilterPostsModal> {
  String selectedCategory = 'Diet';
  String selectedPostType = 'Video';
  double videoLength = 3.0;
  final List<String> categories = ['Wellness', 'Diet', 'Fitness'];
  final List<String> postTypes = ['Video', 'Story', 'Hats'];

  @override
  void initState() {
    super.initState();
    if (widget.currentFilter != null) {
      selectedCategory = widget.currentFilter!['category'] ?? selectedCategory;
      selectedPostType = widget.currentFilter!['postType'] ?? selectedPostType;
      videoLength = widget.currentFilter!['videoLength'] ?? videoLength;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(16),
      child: ListView(
        controller: widget.controller,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Filter Posts',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          // Post Category
          Text('Post Category', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: categories.map((c) {
              bool isSelected = c == selectedCategory;
              return ChoiceChip(
                label: Text(c),
                selected: isSelected,
                selectedColor: Color(0xFF00D09E),
                backgroundColor: Color(
                  0xFFF1FFF3,
                ), // đổi từ xám sang màu nền bạn muốn
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                shape: StadiumBorder(
                  side: BorderSide(color: Colors.transparent), // bỏ viền
                ),
                onSelected: (_) => setState(() => selectedCategory = c),
              );
            }).toList(),
          ),

          SizedBox(height: 24),

          // Post Type
          Text('Post Type', style: TextStyle(fontWeight: FontWeight.w600)),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: postTypes.map((t) {
              bool isSelected = t == selectedPostType;
              return ChoiceChip(
                label: Text(t),
                selected: isSelected,
                selectedColor: Color(0xFF00D09E),
                backgroundColor: Color(0xFFF1FFF3),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                shape: StadiumBorder(
                  side: BorderSide(color: Colors.transparent),
                ),
                onSelected: (_) => setState(() => selectedPostType = t),
              );
            }).toList(),
          ),

          SizedBox(height: 24),

          // Video Length
          Text('Video Length', style: TextStyle(fontWeight: FontWeight.w600)),
          Slider(
            value: videoLength,
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: Color(0xFF00D09E),
            onChanged: (v) => setState(() => videoLength = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text('1m'), Text('5m')],
          ),
          SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              final filterResult = {
                'category': selectedCategory,
                'postType': selectedPostType,
                'videoLength': videoLength,
              };
              Navigator.pop(context, filterResult);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00D09E),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Apply Filter',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
