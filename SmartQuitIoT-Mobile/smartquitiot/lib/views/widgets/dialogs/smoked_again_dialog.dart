import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:another_flushbar/flushbar.dart';
import '../../../routes/app_router.dart';
import 'create_new_quit_plan_dialog.dart';

class SmokedAgainDialog extends ConsumerStatefulWidget {
  const SmokedAgainDialog({super.key});

  @override
  ConsumerState<SmokedAgainDialog> createState() => _SmokedAgainDialogState();
}

class _SmokedAgainDialogState extends ConsumerState<SmokedAgainDialog> {

  void _handleKeepPhase() {
    if (!mounted) return;
    
    // Close dialog first
    Navigator.of(context).pop();
    
    // Navigate to main using go_router
    context.go('/main');
    
    // Show success message after navigation with a small delay
    // Use rootNavigatorKey to get a valid context
    Future.delayed(const Duration(milliseconds: 300), () {
      final rootContext = rootNavigatorKey.currentContext;
      if (rootContext != null) {
        Flushbar(
          message: 'Phase kept successfully! 🎯',
          icon: const Icon(Icons.check_circle, color: Colors.white),
          backgroundColor: const Color(0xFF00D09E),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(rootContext);
      }
    });
  }

  void _handleCreateNewQuitPlan() {
    if (!mounted) return;
    
    // Close this dialog first
    Navigator.of(context).pop();
    
    // Show create new quit plan dialog after a small delay to ensure previous dialog is closed
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const CreateNewQuitPlanDialog(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 40,
                color: Colors.orange.shade400,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'You Smoked During Your Quit Plan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Message
            Text(
              'What would you like to do?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Keep Phase Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleKeepPhase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.shield, size: 20),
                label: const Text(
                  'Keep Current Phase',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Create New Quit Plan Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _handleCreateNewQuitPlan,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF00D09E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(
                    color: Color(0xFF00D09E),
                    width: 2,
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text(
                  'Create New Quit Plan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

