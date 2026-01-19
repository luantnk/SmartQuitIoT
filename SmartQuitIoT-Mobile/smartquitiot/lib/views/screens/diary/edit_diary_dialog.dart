import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/diary_record_provider.dart';
import 'package:SmartQuitIoT/models/diary_record.dart';
import 'package:SmartQuitIoT/models/diary_create_result.dart';
import 'package:SmartQuitIoT/providers/metrics_provider.dart';
import 'package:SmartQuitIoT/providers/diary_refresh_provider.dart';
import 'package:intl/intl.dart';

class EditDiaryDialog extends ConsumerStatefulWidget {
  final DiaryRecord diaryRecord;

  const EditDiaryDialog({super.key, required this.diaryRecord});

  @override
  ConsumerState<EditDiaryDialog> createState() => _EditDiaryDialogState();
}

class _EditDiaryDialogState extends ConsumerState<EditDiaryDialog> {
  // --- LOGIC GIỮ NGUYÊN KHÔNG ĐỔI (START) ---
  late int cigarettesSmoked;
  late double moneySpentOnNrt;
  late double cravingLevel;
  late double moodLevel;
  late double confidenceLevel;
  late double anxietyLevel;
  late final TextEditingController notesController;
  late final TextEditingController cigarettesController;
  final TextEditingController moneyController = TextEditingController();
  final NumberFormat moneyFormatter = NumberFormat('#,###', 'en_US');

  bool _isWaitingForResult = false;

  @override
  void initState() {
    super.initState();
    cigarettesSmoked = widget.diaryRecord.cigarettesSmoked;
    moneySpentOnNrt = widget.diaryRecord.moneySpentOnNrt;
    cravingLevel = widget.diaryRecord.cravingLevel.toDouble();
    moodLevel = widget.diaryRecord.moodLevel.toDouble();
    confidenceLevel = widget.diaryRecord.confidenceLevel.toDouble();
    anxietyLevel = widget.diaryRecord.anxietyLevel.toDouble();
    notesController = TextEditingController(text: widget.diaryRecord.note);
    cigarettesController = TextEditingController(text: cigarettesSmoked.toString());
    
    if (moneySpentOnNrt > 0) {
      moneyController.text = moneyFormatter.format(moneySpentOnNrt.toInt());
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    cigarettesController.dispose();
    moneyController.dispose();
    super.dispose();
  }
  // --- LOGIC GIỮ NGUYÊN (END) ---

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<DiaryCreateResult?>>(diaryRecordNotifierProvider, (previous, next) {
      if (!_isWaitingForResult) return;
      final previousResult = previous?.valueOrNull;
      final nextResult = next.valueOrNull;

      if (nextResult != null && nextResult != previousResult) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _isWaitingForResult = false);
            _handleDiaryResult(nextResult);
          }
        });
      } else if (next.hasError && (previous == null || !previous.hasError)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _isWaitingForResult = false);
            _handleDiaryError(next.error!);
          }
        });
      }
    });

    // --- UI ĐÃ UPDATE ---
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 750),
        decoration: BoxDecoration(
          color: Colors.white, // Nền body màu trắng
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        // Clip để header màu xanh không bị chờm ra ngoài góc bo tròn
        clipBehavior: Clip.hardEdge, 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER XANH LÁ (ĐÃ UPDATE) ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF00D09E), // Màu xanh yêu thích của bạn
              ),
              child: Row(
                children: [
                  // Spacer bên trái để cân bằng với nút close bên phải -> giúp text vào giữa chuẩn hơn
                  const SizedBox(width: 48), 
                  
                  // Text Title ở giữa
                  const Expanded(
                    child: Text(
                      'Edit Record',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Chữ trắng trên nền xanh
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  // Nút Close bên phải
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2), // Nền nút mờ nhẹ
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTENT BODY (GIỮ NGUYÊN STYLE ĐẸP) ---
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSmokingSection(),
                    if (widget.diaryRecord.haveSmoked) const SizedBox(height: 24),

                    _buildMoodSection(),
                    const SizedBox(height: 24),

                    _buildNrtSection(),
                    const SizedBox(height: 24),

                    _buildNotesSection(),
                    const SizedBox(height: 32),

                    _buildSaveButton(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON (STYLE MỚI) ---

  BoxDecoration _getCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFF1F5F9)),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF64748B).withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  TextStyle _getLabelStyle() {
    return const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Color(0xFF475569),
    );
  }

  Widget _buildSmokingSection() {
    // Only show this section if haveSmoked is true
    if (!widget.diaryRecord.haveSmoked) {
      return const SizedBox.shrink(); // Hide entire section if smoke-free
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E).withOpacity(0.1), // Tint xanh nhẹ
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.smoking_rooms, size: 20, color: Color(0xFF00D09E)),
              ),
              const SizedBox(width: 12),
              Text('Cigarettes Smoked', style: _getLabelStyle()),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: cigarettesController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only allow digits
            ],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: '0',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            onChanged: (value) {
              // Ensure non-negative integer
              final parsed = int.tryParse(value) ?? 0;
              final validatedValue = parsed < 0 ? 0 : parsed;
              setState(() {
                cigarettesSmoked = validatedValue;
                // Update controller if value was corrected
                if (value.isNotEmpty && validatedValue.toString() != value) {
                  cigarettesController.value = TextEditingValue(
                    text: validatedValue.toString(),
                    selection: TextSelection.collapsed(offset: validatedValue.toString().length),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: _getCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mood & Feelings', style: _getLabelStyle().copyWith(fontSize: 16)),
          const SizedBox(height: 20),
          _buildSlider('Cravings', cravingLevel, const Color(0xFFE91E63), (v) => setState(() => cravingLevel = v)),
          _buildSlider('Mood', moodLevel, const Color(0xFF2196F3), (v) => setState(() => moodLevel = v)),
          _buildSlider('Confidence', confidenceLevel, const Color(0xFF4CAF50), (v) => setState(() => confidenceLevel = v)),
          _buildSlider('Anxiety', anxietyLevel, const Color(0xFFFF9800), (v) => setState(() => anxietyLevel = v)),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${value.round()}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 36,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: color,
                inactiveColor: color.withOpacity(0.15),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNrtSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.attach_money, size: 20, color: Colors.amber),
              ),
              const SizedBox(width: 12),
              Text('Money spent on NRT', style: _getLabelStyle()),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: moneyController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: '0',
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixText: 'VND',
              suffixStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            onChanged: (value) {
              final numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
              if (numericString.isEmpty) {
                setState(() => moneySpentOnNrt = 0.0);
                return;
              }
              final parsed = int.tryParse(numericString) ?? 0;
              final formatted = moneyFormatter.format(parsed);

              if (formatted != value) {
                setState(() => moneySpentOnNrt = parsed.toDouble());
                final cursorPosition = formatted.length;
                moneyController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: cursorPosition),
                );
              } else {
                setState(() => moneySpentOnNrt = parsed.toDouble());
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _getCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit_note, size: 20, color: Colors.purple),
              ),
              const SizedBox(width: 12),
              Text('Notes', style: _getLabelStyle()),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: notesController,
            maxLines: 4,
            style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF1E293B)),
            decoration: InputDecoration(
              hintText: 'How are you feeling today?',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isWaitingForResult ? null : _updateDiary,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D09E),
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: const Color(0xFF00D09E).withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isWaitingForResult
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  // --- LOGIC API GIỮ NGUYÊN ---
  Future<void> _updateDiary() async {
    if (widget.diaryRecord.id == null) {
      _showErrorFlushbar('Invalid diary record ID');
      return;
    }

    final diaryNotifier = ref.read(diaryRecordNotifierProvider.notifier);
    // If smoke free (haveSmoked is false), ensure cigarettesSmoked is 0
    final finalCigarettesSmoked = widget.diaryRecord.haveSmoked ? cigarettesSmoked : 0;
    final request = DiaryRecordUpdateRequest(
      cigarettesSmoked: finalCigarettesSmoked,
      moneySpentOnNrt: moneySpentOnNrt,
      cravingLevel: cravingLevel.round(),
      moodLevel: moodLevel.round(),
      confidenceLevel: confidenceLevel.round(),
      anxietyLevel: anxietyLevel.round(),
      note: notesController.text,
    );

    setState(() => _isWaitingForResult = true);
    await diaryNotifier.updateDiaryRecord(widget.diaryRecord.id!, request);

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    final state = ref.read(diaryRecordNotifierProvider);
    final result = state.valueOrNull;

    if (_isWaitingForResult && result != null) {
      setState(() => _isWaitingForResult = false);
      _handleDiaryResult(result);
    } else if (_isWaitingForResult && state.hasError) {
      setState(() => _isWaitingForResult = false);
      _handleDiaryError(state.error!);
    }
  }

  void _handleDiaryResult(DiaryCreateResult result) {
    if (result.isSuccess) {
      ref.read(metricsRefreshProvider.notifier).refreshMetrics();
      ref.read(diaryChartsRefreshProvider.notifier).refreshCharts();
      ref.read(diaryRefreshProvider.notifier).refreshDiaryHistory();

      if (!mounted) return;
      Flushbar(
        message: 'Diary record updated successfully!',
        icon: const Icon(Icons.check_circle, size: 28, color: Colors.white),
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(16),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        onStatusChanged: (status) {
          if (status == FlushbarStatus.DISMISSED && mounted) {
            Navigator.of(context).pop(true);
          }
        },
      ).show(context);
    }
  }

  void _handleDiaryError(Object error) {
    if (!mounted) return;
    _showErrorFlushbar(error.toString());
  }

  void _showErrorFlushbar(String message) {
    Flushbar(
      message: message,
      icon: const Icon(Icons.error_outline, size: 28, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      backgroundColor: const Color(0xFFE53E3E),
      duration: const Duration(seconds: 4),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }
}