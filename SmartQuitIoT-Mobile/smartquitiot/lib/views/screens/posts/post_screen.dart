import 'package:flutter/material.dart';

class PostContentPage extends StatefulWidget {
  final String category;

  const PostContentPage({super.key, required this.category});

  @override
  _PostContentPageState createState() => _PostContentPageState();
}

class _PostContentPageState extends State<PostContentPage> {
  String selectedPostType = 'Video';
  bool hideFromCommunity = false;
  bool saveAsDraft = false;
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    contentController.text =
        'EVERYONE STAY CALM!!! You can\'t believe this. Doc A real other day';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Community Post',
                      style: TextStyle(
                        color: Color(0xFF4A90E2),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Post Content',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 32),

                    // User Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dokomon Senee',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.pink[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '25 Total Posts',
                                style: TextStyle(
                                  color: Colors.pink[400],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    // Content Input
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF4A90E2).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF4A90E2).withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: contentController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'What\'s on your mind?',
                              hintStyle: TextStyle(color: Colors.grey[500]),
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              _buildContentIcon(Icons.image, false),
                              SizedBox(width: 12),
                              _buildContentIcon(Icons.gif, false),
                              SizedBox(width: 12),
                              _buildContentIcon(Icons.mic, false),
                              Spacer(),
                              Text(
                                '225/500',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),

                    // Post Type
                    Row(
                      children: [
                        Text(
                          'Post Type',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: Color(0xFF4A90E2),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildPostTypeOption('Story', Icons.article, false),
                        SizedBox(width: 12),
                        _buildPostTypeOption('Video', Icons.videocam, true),
                        SizedBox(width: 12),
                        _buildPostTypeOption('Text', Icons.text_fields, false),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Add Metrics
                    Row(
                      children: [
                        Text(
                          'Add Metrics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Spacer(),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: Color(0xFF4A90E2),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildMetricIcon(Icons.image),
                        SizedBox(width: 16),
                        _buildMetricIcon(
                          Icons.local_fire_department,
                          isSelected: true,
                        ),
                        SizedBox(width: 16),
                        _buildMetricIcon(Icons.access_time),
                        SizedBox(width: 16),
                        _buildMetricIcon(Icons.straighten),
                        SizedBox(width: 16),
                        _buildMetricIcon(Icons.timeline),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Hide from Community
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hide from Community?',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  'Post will be 100% private',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: hideFromCommunity,
                            onChanged: (value) {
                              setState(() {
                                hideFromCommunity = value;
                              });
                            },
                            activeThumbColor: Color(0xFF4A90E2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // Save as Draft
                    Row(
                      children: [
                        Checkbox(
                          value: saveAsDraft,
                          onChanged: (value) {
                            setState(() {
                              saveAsDraft = value ?? false;
                            });
                          },
                          activeColor: Color(0xFF4A90E2),
                        ),
                        Text(
                          'Save as Draft',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.check, color: Color(0xFF00D09E), size: 16),
                      ],
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Continue Button
            Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Handle post creation
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4A90E2),
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
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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

  Widget _buildContentIcon(IconData icon, bool isSelected) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF4A90E2) : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey[600],
        size: 18,
      ),
    );
  }

  Widget _buildPostTypeOption(String title, IconData icon, bool isSelected) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4A90E2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricIcon(IconData icon, {bool isSelected = false}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF4A90E2) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey[600],
        size: 20,
      ),
    );
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }
}
