import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:SmartQuitIoT/views/screens/appointments/coach_list_screen.dart';

class CoachAppointmentCard extends StatefulWidget {
  final String titleKey;
  final String subtitleKey;
  final IconData icon;

  const CoachAppointmentCard({
    super.key,
    this.titleKey = 'coach_card.title',
    this.subtitleKey = 'coach_card.subtitle',
    this.icon = Icons.video_call_rounded,
  });

  @override
  State<CoachAppointmentCard> createState() => _CoachAppointmentCardState();
}

class _CoachAppointmentCardState extends State<CoachAppointmentCard> {
  bool _isPressed = false;

  final List<Color> _defaultGradient = const [
    Color(0xFF00D09E),
    Color(0xFF00BFA5),
    Color(0xFF00E676),
  ];

  final List<Color> _pressedGradient = const [
    Color(0xFF009B75),
    Color(0xFF00897B),
    Color(0xFF00C853),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CoachListScreen()),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isPressed ? _pressedGradient : _defaultGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_isPressed ? _pressedGradient[0] : _defaultGradient[0])
                  .withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildIconContainer(),
              const SizedBox(width: 16),
              _buildTextContent(),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(widget.icon, color: Colors.white, size: 32),
    );
  }

  Widget _buildTextContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.titleKey.tr(), // lấy từ easy_localization
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.subtitleKey.tr(), // lấy từ easy_localization
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
