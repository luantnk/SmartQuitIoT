import 'package:flutter/material.dart';

class FilterPostsPage extends StatefulWidget {
  const FilterPostsPage({super.key});

  @override
  _FilterPostsPageState createState() => _FilterPostsPageState();
}

class _FilterPostsPageState extends State<FilterPostsPage> {
  // State
  String selectedCategory = 'Diet';
  DateTime selectedDate = DateTime(2025, 4, 16);
  String selectedPostType = 'Video/Hats/Story';
  double videoLength = 3.0; // minutes

  final List<String> categories = ['Wellness', 'Diet', 'Fitness'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: Column(
          children: [
            // Expanded để scrollable mà không overflow
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    // Thay thế đoạn header
                    Center(
                      child: Text(
                        'Filter Posts',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Post Category
                    Text(
                      'Post Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      children: categories.map((c) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = c;
                            });
                          },
                          child: _buildCategoryChip(c, selectedCategory == c),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 32),

                    // Post Date
                    Text(
                      'Post Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        _showDateBottomSheet(context);
                      },
                      child: _buildSelectableBox(
                        icon: Icons.calendar_today,
                        text:
                            '${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                    SizedBox(height: 32),

                    // Post Type
                    Text(
                      'Post Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        _showTypeBottomSheet(context);
                      },
                      child: _buildSelectableBox(
                        icon: Icons.videocam,
                        text: selectedPostType,
                      ),
                    ),
                    SizedBox(height: 32),

                    // Video Length
                    Text(
                      'Video Length',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Color(0xFF00D09E),
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: Color(0xFF00D09E),
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                        overlayShape: RoundSliderOverlayShape(
                          overlayRadius: 20,
                        ),
                      ),
                      child: Slider(
                        value: videoLength,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        onChanged: (value) {
                          setState(() {
                            videoLength = value;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1m',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '5m',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Filter Button
            Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00D09E),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Filter Posts',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.tune, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String title, bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF00D09E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSelectableBox({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
        ],
      ),
    );
  }

  void _showDateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime.now();
                  });
                  Navigator.pop(context);
                },
                child: Text('Use Today (tượng trưng)'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTypeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Post Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text('Video'),
                onTap: () {
                  setState(() {
                    selectedPostType = 'Video';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Story'),
                onTap: () {
                  setState(() {
                    selectedPostType = 'Story';
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Hats'),
                onTap: () {
                  setState(() {
                    selectedPostType = 'Hats';
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
