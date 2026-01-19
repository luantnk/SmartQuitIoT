import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import 'dart:async';
import '../../../models/request/create_quit_plan_request.dart';
import '../../../providers/quit_plan_provider.dart';
import '../../../providers/mission_refresh_provider.dart';
import '../../../providers/achievement_refresh_provider.dart';
import '../../../viewmodels/quit_plan_homepage_view_model.dart';
import '../../../utils/notification_helper.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/common/page_indicator.dart';
import '../questionaires/question_input_card.dart';
import '../questionaires/question_options_card.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Controllers
  final TextEditingController _smokeAvgController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();
  final TextEditingController _cigarettesPerPackController =
      TextEditingController();
  final TextEditingController _quitPlanNameController = TextEditingController();
  final TextEditingController _nicotineAmountController =
      TextEditingController();

  // Options
  int? _selectedFirstCigaretteOptionMinutes;
  bool? _difficultRefrain;
  bool? _hateToGiveUp;
  bool? _smokeMoreMorning;
  bool? _smokeEvenSick;
  bool _useNRT = false;
  final List<String> _selectedInterests = [];

  // Validation flag
  bool _submitted = false;
  bool _isCreatingPlan = false;
  String _loadingMessage = 'Creating your quit plan...';

  // Progress tracking
  double _creationProgress = 0.0;
  int _currentStep = 0;
  final List<String> _steps = [
    'Analyzing your smoking habits',
    'Creating personalized missions',
    'Building quit phases',
    'Finalizing your plan',
  ];

  // Tips rotation
  final List<String> _quitTips = [
    'Tip: Drinking water helps reduce cravings',
    'Did you know? Your sense of taste improves within 48 hours',
    'Tip: Deep breathing exercises can help manage stress',
    'After 2 weeks, your circulation begins to improve',
    'Tip: Keep your hands busy to avoid reaching for cigarettes',
    'Your risk of heart attack begins to drop after 24 hours',
    'Tip: Exercise releases endorphins that reduce cravings',
    'Within 3 months, your lung function improves by 30%',
  ];
  int _currentTipIndex = 0;
  Timer? _tipTimer;

  // Motivational messages
  final List<String> _motivationalMessages = [
    'Every journey begins with a single step',
    'You\'re stronger than your cravings',
    'Building your personalized roadmap to freedom',
    'Your healthier life starts here',
    'Creating a smoke-free future for you',
    'Igniting your path to wellness',
  ];
  int _currentMotivationalIndex = 0;
  Timer? _motivationalTimer;

  // First cigarette options
  final Map<String, int> firstCigaretteOptions = {
    "≤5 minutes": 5,
    "6–30 minutes": 30,
    "31–60 minutes": 60,
    ">60 minutes": 120,
  };

  // Interest options
  final List<String> interestOptions = [
    "All Interests",
    "Sports and Exercise",
    "Art and Creativity",
    "Cooking and Food",
    "Reading, Learning and Writing",
    "Music and Entertainment",
    "Nature and Outdoor Activities",
  ];

  @override
  void initState() {
    super.initState();

    // Format cost input with thousand separator
    _moneyController.addListener(() {
      final text = _moneyController.text.replaceAll(',', '');
      if (text.isEmpty) return;
      final number = int.tryParse(text);
      if (number != null) {
        final formatted = NumberFormat('#,###', 'en_US').format(number);
        if (formatted != _moneyController.text) {
          _moneyController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _motivationalTimer?.cancel();
    _pageController.dispose();
    _smokeAvgController.dispose();
    _yearsController.dispose();
    _moneyController.dispose();
    _cigarettesPerPackController.dispose();
    _quitPlanNameController.dispose();
    _nicotineAmountController.dispose();
    super.dispose();
  }

  void _startTipRotation() {
    _tipTimer?.cancel();
    _tipTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _isCreatingPlan) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _quitTips.length;
        });
      }
    });

    // Start motivational message rotation
    _motivationalTimer?.cancel();
    _motivationalTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isCreatingPlan) {
        setState(() {
          _currentMotivationalIndex =
              (_currentMotivationalIndex + 1) % _motivationalMessages.length;
        });
      }
    });
  }

  void _animateProgress(double from, double to, String message) {
    setState(() => _loadingMessage = message);

    // Smooth animation
    const steps = 20;
    const stepDuration = Duration(milliseconds: 50);
    final increment = (to - from) / steps;

    for (int i = 0; i <= steps; i++) {
      Future.delayed(stepDuration * i, () {
        if (mounted && _isCreatingPlan) {
          setState(() {
            _creationProgress = from + (increment * i);
          });
        }
      });
    }
  }

  /// Validate and return first error page index, -1 if no error
  int _validateAndGetFirstErrorPage() {
    setState(() => _submitted = true);

    // Validate Page 3
    bool isPage3Invalid =
        _quitPlanNameController.text.trim().isEmpty ||
        _smokeAvgController.text.trim().isEmpty ||
        _yearsController.text.trim().isEmpty ||
        _moneyController.text.trim().isEmpty ||
        _cigarettesPerPackController.text.trim().isEmpty ||
        _nicotineAmountController.text.trim().isEmpty ||
        _selectedFirstCigaretteOptionMinutes == null;

    if (isPage3Invalid) return 2;

    // Validate Page 4
    bool isPage4Invalid =
        _difficultRefrain == null ||
        _hateToGiveUp == null ||
        _smokeMoreMorning == null ||
        _smokeEvenSick == null ||
        _selectedInterests.isEmpty;

    if (isPage4Invalid) return 3;

    return -1; // No error
  }

  Widget _buildLoadingWidget() {
    return Column(
      children: [
        // Animated motivational message
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            _motivationalMessages[_currentMotivationalIndex],
            key: ValueKey<int>(_currentMotivationalIndex),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Circular progress
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D09E).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: _creationProgress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00D09E),
                  ),
                ),
              ),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00D09E).withOpacity(0.1),
                      const Color(0xFF00D09E).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(_creationProgress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D09E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Creating',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Step indicator
        Text(
          'Step ${_currentStep + 1} of ${_steps.length}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Loading message
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _loadingMessage,
            key: ValueKey<String>(_loadingMessage),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF00D09E),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Linear steps
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: List.generate(_steps.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? const Color(0xFF00D09E)
                            : isCurrent
                                ? const Color(0xFF00D09E).withOpacity(0.3)
                                : Colors.grey[300],
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : isCurrent
                              ? Center(
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF00D09E),
                                      ),
                                    ),
                                  ),
                                )
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _steps[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isCompleted || isCurrent
                              ? Colors.black87
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        // Tips box
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF00D09E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00D09E).withOpacity(0.3)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _quitTips[_currentTipIndex],
              key: ValueKey<int>(_currentTipIndex),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      // --- CHANGE: Use Stack for Overlay Loading ---
      body: Stack(
        children: [
          // 1. MAIN CONTENT (Wrapped in IgnorePointer)
          IgnorePointer(
            ignoring: _isCreatingPlan, // Block interaction when loading
            child: Column(
              children: [
                // Header
                Container(
                  height: 90,
                  width: double.infinity,
                  color: const Color(0xFF00D09E),
                  alignment: Alignment.center,
                  child: Text(
                    _currentIndex == 0
                        ? 'Welcome to SmartQuit'
                        : _currentIndex == 1
                            ? "Talk Smoking Status"
                            : "Questions",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    // Disable swipe when loading
                    physics: _isCreatingPlan
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    onPageChanged: (index) =>
                        setState(() => _currentIndex = index),
                    children: [
                      // Page 1
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: size.height * 0.3,
                              child: Image.asset('lib/assets/images/Group.png'),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Ready to save your health?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Page 2
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: size.height * 0.3,
                              child:
                                  Image.asset('lib/assets/images/health.png'),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Tell us about your smoking habits',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Page 3
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ListView(
                          children: [
                            QuestionInputCard(
                              question: 'Quit plan name',
                              controller: _quitPlanNameController,
                              hintText: 'Enter your plan name',
                              errorText: _submitted &&
                                      _quitPlanNameController.text
                                          .trim()
                                          .isEmpty
                                  ? 'Please enter a plan name'
                                  : null,
                            ),
                            QuestionInputCard(
                              question: 'Average cigarettes smoked per day',
                              controller: _smokeAvgController,
                              hintText: 'Enter number',
                              keyboardType: TextInputType.number,
                              errorText: _submitted &&
                                      _smokeAvgController.text.trim().isEmpty
                                  ? 'Please enter the number of cigarettes'
                                  : null,
                            ),
                            QuestionInputCard(
                              question: 'How many years have you smoked?',
                              controller: _yearsController,
                              hintText: 'Enter years',
                              keyboardType: TextInputType.number,
                              errorText: _submitted &&
                                      _yearsController.text.trim().isEmpty
                                  ? 'Please enter the number of years'
                                  : null,
                            ),
                            QuestionInputCard(
                              question: 'Cost per cigarette pack',
                              controller: _moneyController,
                              hintText: 'Enter cost',
                              keyboardType: TextInputType.number,
                              errorText: _submitted &&
                                      _moneyController.text.trim().isEmpty
                                  ? 'Please enter the cost'
                                  : null,
                            ),
                            QuestionInputCard(
                              question: 'Cigarettes per pack',
                              controller: _cigarettesPerPackController,
                              hintText: 'Enter number',
                              keyboardType: TextInputType.number,
                              errorText: _submitted &&
                                      _cigarettesPerPackController.text
                                          .trim()
                                          .isEmpty
                                  ? 'Please enter cigarettes per pack'
                                  : null,
                            ),
                            QuestionInputCard(
                              question: 'Amount of nicotine per cigarette (mg)',
                              controller: _nicotineAmountController,
                              hintText: 'Enter amount (e.g., 1.2)',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              errorText: _submitted &&
                                      _nicotineAmountController.text
                                          .trim()
                                          .isEmpty
                                  ? 'Please enter nicotine amount'
                                  : null,
                            ),
                            QuestionOptionsCard(
                              question:
                                  'How soon after waking do you smoke your first cigarette?',
                              options: firstCigaretteOptions.keys.toList(),
                              onSelected: (option) {
                                setState(() {
                                  _selectedFirstCigaretteOptionMinutes =
                                      firstCigaretteOptions[option]!;
                                });
                              },
                              errorText: _submitted &&
                                      _selectedFirstCigaretteOptionMinutes ==
                                          null
                                  ? 'Please select an option'
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      // Page 4
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ListView(
                          children: [
                            QuestionOptionsCard(
                              question:
                                  'Difficult to refrain in forbidden places?',
                              options: ['Yes', 'No'],
                              onSelected: (option) => setState(
                                  () => _difficultRefrain = option == 'Yes'),
                              errorText: _submitted && _difficultRefrain == null
                                  ? 'Please select an option'
                                  : null,
                            ),
                            QuestionOptionsCard(
                              question:
                                  'Which cigarette would you hate to give up?',
                              options: ['First in the morning', 'Any other'],
                              onSelected: (option) => setState(() =>
                                  _hateToGiveUp =
                                      option == 'First in the morning'),
                              errorText: _submitted && _hateToGiveUp == null
                                  ? 'Please select an option'
                                  : null,
                            ),
                            QuestionOptionsCard(
                              question:
                                  'Do you smoke more frequently in the morning?',
                              options: ['Yes', 'No'],
                              onSelected: (option) => setState(
                                  () => _smokeMoreMorning = option == 'Yes'),
                              errorText: _submitted && _smokeMoreMorning == null
                                  ? 'Please select an option'
                                  : null,
                            ),
                            QuestionOptionsCard(
                              question: 'Do you smoke even if sick?',
                              options: ['Yes', 'No'],
                              onSelected: (option) => setState(
                                  () => _smokeEvenSick = option == 'Yes'),
                              errorText: _submitted && _smokeEvenSick == null
                                  ? 'Please select an option'
                                  : null,
                            ),
                            const SizedBox(height: 20),

                            // Interests
                            const Text(
                              "Select your interests",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Builder(
                              builder: (context) {
                                final isAllInterestsSelected =
                                    _selectedInterests.contains("All Interests");
                                return Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  children: interestOptions.map((option) {
                                    final isAllInterests =
                                        option == "All Interests";
                                    final isSelected = isAllInterestsSelected
                                        ? true
                                        : _selectedInterests.contains(option);
                                    final isDisabled = isAllInterestsSelected &&
                                        !isAllInterests;

                                    return FilterChip(
                                      label: Text(
                                        option,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      selected: isSelected,
                                      backgroundColor: Colors.white,
                                      selectedColor: const Color(0xFF00D09E),
                                      disabledColor: Colors.grey[200],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                            color: Colors.grey.shade300),
                                      ),
                                      onSelected: isDisabled
                                          ? null
                                          : (val) {
                                              setState(() {
                                                if (isAllInterests) {
                                                  if (val) {
                                                    _selectedInterests.clear();
                                                    _selectedInterests
                                                        .add(option);
                                                  } else {
                                                    _selectedInterests
                                                        .remove(option);
                                                  }
                                                } else {
                                                  if (val) {
                                                    _selectedInterests
                                                        .add(option);
                                                  } else {
                                                    _selectedInterests
                                                        .remove(option);
                                                  }
                                                }
                                              });
                                            },
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            if (_submitted && _selectedInterests.isEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, left: 4.0),
                                child: Row(
                                  children: const [
                                    Icon(Icons.error_outline,
                                        color: Colors.red, size: 16),
                                    SizedBox(width: 5),
                                    Text(
                                      'Please select at least one interest',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Use NRT
                            Row(
                              children: [
                                Checkbox(
                                  value: _useNRT,
                                  onChanged: (val) =>
                                      setState(() => _useNRT = val ?? false),
                                ),
                                const Text("Use Nicotine Replacement Therapy"),
                                const SizedBox(width: 5),
                                const Tooltip(
                                  message:
                                      "NRT helps reduce withdrawal symptoms by replacing nicotine safely.",
                                  child: Icon(Icons.info_outline, size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),

                            // Submit Button
                            PrimaryButton(
                              text: 'Finish',
                              // Disable logic if needed, but the Overlay will cover it anyway
                              onPressed: _isCreatingPlan
                                  ? () {}
                                  : () async {
                                      final errorPage =
                                          _validateAndGetFirstErrorPage();
                                      if (errorPage != -1) {
                                        _pageController.animateToPage(
                                          errorPage,
                                          duration:
                                              const Duration(milliseconds: 400),
                                          curve: Curves.easeInOut,
                                        );
                                        NotificationHelper.showTopNotification(
                                          context,
                                          title: "Missing Information",
                                          message:
                                              "Please fill in all required fields highlighted in red.",
                                          isError: true,
                                        );
                                        return;
                                      }

                                      final request = CreateQuitPlanRequest(
                                        startDate:
                                            DateTime.now().toIso8601String(),
                                        useNRT: _useNRT,
                                        quitPlanName:
                                            _quitPlanNameController.text.trim(),
                                        smokeAvgPerDay: int.tryParse(
                                                _smokeAvgController.text) ??
                                            0,
                                        numberOfYearsOfSmoking: int.tryParse(
                                                _yearsController.text) ??
                                            0,
                                        moneyPerPackage: double.parse(
                                          _moneyController.text
                                              .replaceAll(',', ''),
                                        ),
                                        cigarettesPerPackage: int.tryParse(
                                              _cigarettesPerPackController.text,
                                            ) ??
                                            0,
                                        minutesAfterWakingToSmoke:
                                            _selectedFirstCigaretteOptionMinutes!,
                                        smokingInForbiddenPlaces:
                                            _difficultRefrain!,
                                        cigaretteHateToGiveUp: _hateToGiveUp!,
                                        morningSmokingFrequency:
                                            _smokeMoreMorning!,
                                        smokeWhenSick: _smokeEvenSick!,
                                        interests: _selectedInterests.contains(
                                          "All Interests",
                                        )
                                            ? null
                                            : _selectedInterests,
                                        amountOfNicotinePerCigarettes:
                                            double.parse(
                                          _nicotineAmountController.text
                                              .replaceAll(',', ''),
                                        ),
                                      );

                                      // START LOADING UI
                                      setState(() {
                                        _isCreatingPlan = true;
                                        _currentStep = 0;
                                        _creationProgress = 0.0;
                                        _currentTipIndex = 0;
                                        _loadingMessage = _steps[0];
                                      });

                                      // Start rotation
                                      _startTipRotation();

                                      try {
                                        print(
                                            '📞 Calling API to create quit plan...');
                                        final apiCallFuture = ref
                                            .read(quitPlanViewModelProvider
                                                .notifier)
                                            .createPlan(request);

                                        // Step 1: Analyzing (0-25%)
                                        _animateProgress(0, 0.25, _steps[0]);
                                        await Future.delayed(
                                            const Duration(seconds: 8));

                                        // Step 2: Creating missions (25-50%)
                                        if (_isCreatingPlan && mounted) {
                                          setState(() => _currentStep = 1);
                                          _animateProgress(
                                              0.25, 0.50, _steps[1]);
                                        }
                                        await Future.delayed(
                                            const Duration(seconds: 8));

                                        // Step 3: Building phases (50-75%)
                                        if (_isCreatingPlan && mounted) {
                                          setState(() => _currentStep = 2);
                                          _animateProgress(
                                              0.50, 0.75, _steps[2]);
                                        }
                                        await Future.delayed(
                                            const Duration(seconds: 8));

                                        // Step 4: Finalizing (75-100%)
                                        if (_isCreatingPlan && mounted) {
                                          setState(() => _currentStep = 3);
                                          _animateProgress(0.75, 1.0, _steps[3]);
                                        }
                                        await Future.delayed(
                                            const Duration(seconds: 8));

                                        // Wait for API
                                        await apiCallFuture;

                                        // Complete
                                        if (mounted) {
                                          setState(() {
                                            _creationProgress = 1.0;
                                            _loadingMessage =
                                                'Quit plan ready!\nLoading your dashboard...';
                                          });
                                        }
                                        await Future.delayed(
                                            const Duration(seconds: 3));

                                        // Stop timers
                                        _tipTimer?.cancel();
                                        _motivationalTimer?.cancel();

                                        if (mounted) {
                                          Flushbar(
                                            message:
                                                "Quit plan created successfully!",
                                            duration:
                                                const Duration(seconds: 3),
                                            backgroundColor:
                                                const Color(0xFF00D09E),
                                            margin: const EdgeInsets.all(8),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            icon: const Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.white,
                                            ),
                                            flushbarPosition:
                                                FlushbarPosition.TOP,
                                          ).show(context);
                                        }

                                        // Refresh Providers
                                        await ref
                                            .read(
                                                quitPlanHomepageViewModelProvider
                                                    .notifier)
                                            .refreshQuitPlan();
                                        ref
                                            .read(missionRefreshProvider
                                                .notifier)
                                            .refreshAll();
                                        ref
                                            .read(achievementRefreshProvider
                                                .notifier)
                                            .refreshAchievements();

                                        await Future.delayed(
                                            const Duration(seconds: 2));

                                        setState(() {
                                          _isCreatingPlan = false;
                                        });

                                        if (mounted) {
                                          context.go('/main');
                                        }
                                      } catch (e) {
                                        print('❌ Error: $e');
                                        _tipTimer?.cancel();
                                        _motivationalTimer?.cancel();

                                        setState(() {
                                          _isCreatingPlan = false;
                                        });

                                        if (mounted) {
                                          Flushbar(
                                            message: 'Error: ${e.toString()}',
                                            duration:
                                                const Duration(seconds: 3),
                                            backgroundColor: Colors.red[600]!,
                                            margin: const EdgeInsets.all(8),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            icon: const Icon(
                                              Icons.error_outline,
                                              color: Colors.white,
                                            ),
                                            flushbarPosition:
                                                FlushbarPosition.TOP,
                                          ).show(context);
                                        }
                                      }
                                    },
                              width: 200,
                              height: 50,
                              borderRadius: 30,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Page indicator
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child:
                      PageIndicator(currentIndex: _currentIndex, totalPages: 4),
                ),
              ],
            ),
          ),

          // 2. LOADING OVERLAY (Full Screen)
          if (_isCreatingPlan)
            Positioned.fill(
              child: Container(
                color: const Color(
                    0xFFF1FFF3), // Solid background matches app bg
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: _buildLoadingWidget(),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}