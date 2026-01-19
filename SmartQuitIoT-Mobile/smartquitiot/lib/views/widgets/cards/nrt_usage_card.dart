import 'package:flutter/material.dart';

class NrtUsageCard extends StatefulWidget {
  final bool isUseNrt;
  final double moneySpentOnNrt;
  final Function(bool) onNrtChanged;
  final Function(double) onMoneyChanged;

  const NrtUsageCard({
    super.key,
    required this.isUseNrt,
    required this.moneySpentOnNrt,
    required this.onNrtChanged,
    required this.onMoneyChanged,
  });

  @override
  State<NrtUsageCard> createState() => _NrtUsageCardState();
}

class _NrtUsageCardState extends State<NrtUsageCard> {
  final TextEditingController _moneyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _moneyController.text = _formatMoney(widget.moneySpentOnNrt);
  }

  @override
  void dispose() {
    _moneyController.dispose();
    super.dispose();
  }

  String _formatMoney(double amount) {
    if (amount == 0) return '';
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  double _parseMoney(String text) {
    final cleanText = text.replaceAll(',', '');
    return double.tryParse(cleanText) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'NRT Usage',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Did you use any nicotine replacement therapy?',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onNrtChanged(false);
                    widget.onMoneyChanged(0.0);
                    _moneyController.clear();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: !widget.isUseNrt
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !widget.isUseNrt
                            ? const Color(0xFF4CAF50)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: !widget.isUseNrt
                                ? const Color(0xFF4CAF50)
                                : Colors.transparent,
                            border: Border.all(
                              color: !widget.isUseNrt
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: !widget.isUseNrt
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: !widget.isUseNrt
                                ? const Color(0xFF4CAF50)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onNrtChanged(true);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: widget.isUseNrt
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.isUseNrt
                            ? const Color(0xFF4CAF50)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.isUseNrt
                                ? const Color(0xFF4CAF50)
                                : Colors.transparent,
                            border: Border.all(
                              color: widget.isUseNrt
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: widget.isUseNrt
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Yes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: widget.isUseNrt
                                ? const Color(0xFF4CAF50)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.isUseNrt) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(
                  Icons.attach_money,
                  color: Color(0xFF4CAF50),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Amount spent on NRT (\$)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                ),
              ),
              child: TextField(
                controller: _moneyController,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                onChanged: (text) {
                  final amount = _parseMoney(text);
                  widget.onMoneyChanged(amount);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
