import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mission_complete_request.dart';
import '../../viewmodels/mission_complete_view_model.dart';
import '../../providers/mission_refresh_provider.dart';
import 'trigger_selection_widget.dart';
import 'mission_success_dialog.dart';

class MissionCompleteDialog extends ConsumerStatefulWidget {
  final int phaseId;
  final int phaseDetailMissionId;
  final String missionCode;
  final String missionName;
  final String missionDescription;
  final VoidCallback? onCompleted;

  const MissionCompleteDialog({
    super.key,
    required this.phaseId,
    required this.phaseDetailMissionId,
    required this.missionCode,
    required this.missionName,
    required this.missionDescription,
    this.onCompleted,
  });

  @override
  ConsumerState<MissionCompleteDialog> createState() =>
      _MissionCompleteDialogState();
}

class _MissionCompleteDialogState extends ConsumerState<MissionCompleteDialog> {
  bool _canComplete = true;

  @override
  void initState() {
    super.initState();
    // Reset state when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(missionCompleteViewModelProvider.notifier).reset();
    });

    // Check if mission requires triggers
    if (MissionTriggers.requiresTriggers(widget.missionCode)) {
      _canComplete = false;
    }
  }

  void _onSelectionChanged() {
    if (MissionTriggers.requiresTriggers(widget.missionCode)) {
      final state = ref.read(missionCompleteViewModelProvider);
      setState(() {
        _canComplete = state.selectedTriggers.isNotEmpty;
      });
    }
  }

  Future<T> _withBlockingLoader<T>(
    Future<T> Function() task, {
    String message = 'Processing...',
  }) async {
    if (!mounted) {
      return await task();
    }

    bool overlayOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: _MissionBlockingLoader(message: message),
      ),
    ).whenComplete(() {
      overlayOpen = false;
    });

    try {
      return await task();
    } finally {
      if (overlayOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  Future<void> _completeMission() async {
    final requiresTriggers = MissionTriggers.requiresTriggers(
      widget.missionCode,
    );

    final success = await _withBlockingLoader<bool>(() async {
      return await ref
          .read(missionCompleteViewModelProvider.notifier)
          .completeMission(
            phaseId: widget.phaseId,
            phaseDetailMissionId: widget.phaseDetailMissionId,
            requiresTriggers: requiresTriggers,
          );
    }, message: 'Submitting mission...');

    if (success && mounted) {
      // Trigger refresh for today missions
      ref.read(missionRefreshProvider.notifier).refreshTodayMissions();

      // Close current dialog
      Navigator.of(context).pop();

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => MissionSuccessDialog(
          missionName: widget.missionName,
          onContinue: () {
            widget.onCompleted?.call();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missionCompleteViewModelProvider);
    final requiresTriggers = MissionTriggers.requiresTriggers(
      widget.missionCode,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    color: Color(0xFF00D09E),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Complete Mission',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Mission Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.missionName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.missionDescription,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Trigger Selection (if required)
            if (requiresTriggers) ...[
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: TriggerSelectionWidget(
                    missionName: widget.missionName,
                    onSelectionChanged: _onSelectionChanged,
                  ),
                ),
              ),
            ],

            // Error Message
            if (state.hasError) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (state.isLoading || !_canComplete)
                        ? null
                        : _completeMission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D09E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Complete',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionBlockingLoader extends StatelessWidget {
  final String message;

  const _MissionBlockingLoader({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
