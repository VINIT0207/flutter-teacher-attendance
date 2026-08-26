import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/settings/settings_cubit.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_text_field.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _selectedTitle = 'Professor';
  String _selectedGender = 'Unspecified';
  String _selectedInstitutionType = 'University';

  final TextEditingController _nameController =
      TextEditingController(text: '');
  final TextEditingController _instituteController =
      TextEditingController(text: '');

  bool _isChecking = true;

  final List<String> _titleOptions = [
    'Sir',
    'Miss',
    'Professor',
    'Dr.',
    'Mr.',
    'Ms.',
  ];

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Unspecified',
  ];

  final List<String> _institutionOptions = [
    'University',
    'College',
    'School',
    'Institute',
  ];

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  void _checkFirstLaunch() async {
    final settingsState = context.read<SettingsCubit>().state;
    if (settingsState.settings.hasCompletedOnboarding) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
      return;
    }

    setState(() => _isChecking = false);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _instituteController.dispose();
    super.dispose();
  }

  String _getGreetingPreview() {
    final rawName = _nameController.text.trim();
    final displayName = rawName.isNotEmpty ? rawName : 'Alex';
    final firstName = displayName.split(' ').first;

    if (_selectedTitle == 'Sir' || _selectedTitle == 'Miss') {
      return '$_selectedTitle $firstName';
    }
    if (displayName.startsWith(_selectedTitle)) {
      return displayName;
    }
    return '$_selectedTitle $displayName';
  }

  String _getSignaturePreview() {
    final rawName = _nameController.text.trim();
    final teacherName = rawName.isNotEmpty ? rawName : 'Alex Smith';
    final fullTitle = teacherName.startsWith(_selectedTitle)
        ? teacherName
        : '$_selectedTitle $teacherName';

    final rawInst = _instituteController.text.trim();
    final inst = rawInst.isNotEmpty
        ? rawInst
        : '$_selectedInstitutionType of Advanced Studies';

    return '$fullTitle ($inst)';
  }

  void _goToNextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _goToPrevPage() {
    HapticFeedback.lightImpact();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _finishOnboarding() async {
    HapticFeedback.mediumImpact();

    final name = _nameController.text.trim();
    final institute = _instituteController.text.trim();
    final trackingMode =
        _selectedInstitutionType == 'School' ? 'FULL_DAY' : 'PERIOD_WISE';

    final cubit = context.read<SettingsCubit>();
    await cubit.updateTeacherProfile(
      title: _selectedTitle,
      gender: _selectedGender,
      name: name.isNotEmpty ? name : _selectedTitle,
      institutionType: _selectedInstitutionType,
      institute: institute.isNotEmpty
          ? institute
          : '$_selectedInstitutionType of Science & Tech',
      email: '',
    );
    await cubit.updateAttendanceFrequency(trackingMode);
    await cubit.completeOnboarding();

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        backgroundColor: Color(0xFF090D14),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF90B4F8)),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
        backgroundColor: const Color(0xFF090D14),
        body: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (idx) {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() => _currentPage = idx);
          },
          children: [
            _buildHeroLandingPage(context),
            _buildPersonalizationPage(context),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // PAGE 1: EXACT REFERENCE DESIGN HERO SCREEN
  // ==========================================
  Widget _buildHeroLandingPage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E293B), // Soft ambient ice slate top
            Color(0xFF0F172A),
            Color(0xFF090D14), // Matte obsidian black
            Color(0xFF05070B),
          ],
          stops: [0.0, 0.25, 0.65, 1.0],
        ),
      ),
      child: SafeArea(
        top: true,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    16,
                    24,
                    MediaQuery.paddingOf(context).bottom + 20,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 8),

                        // App Name & Branding with Official App Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryColor
                                        .withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'lib/assets/logo/app_icon.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: AppColors.primaryColor,
                                    child: const Icon(
                                      Icons.school_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'ClassTrack',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Tracking Tagline
                        const Text(
                          'OFFLINE • ON-DEVICE • YOURS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 2.5,
                          ),
                        ),

                        const Spacer(),

                        // Big Bold Punchy Headline
                        const Text(
                          'Effortless attendance.\nZero wasted class time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: -0.8,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Subtitle paragraph
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Take attendance in seconds, manage lecture timetable reminders, and detect defaulters before exams — strictly on your device without an account or cloud lag.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF94A3B8),
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 3 Clean Pill Highlights (Reference Style)
                        _buildReferenceHighlightRow(
                          icon: Icons.alarm_rounded,
                          iconColor: const Color(0xFFFCA5A5),
                          title: 'Local alarms, no cloud required',
                        ),
                        const SizedBox(height: 10),
                        _buildReferenceHighlightRow(
                          icon: Icons.local_fire_department_rounded,
                          iconColor: const Color(0xFFFDBA74),
                          title: '1-Tap rapid attendance & gestures',
                        ),
                        const SizedBox(height: 10),
                        _buildReferenceHighlightRow(
                          icon: Icons.lock_rounded,
                          iconColor: const Color(0xFF86EFAC),
                          title: 'Encrypted on-device SQLite vault',
                        ),

                        const SizedBox(height: 20),

                        // Big Light Blue Pill Button (Get Started ->)
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4E3FC),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF90B4F8)
                                    .withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(28),
                              onTap: _goToNextPage,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get started',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    '→',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Bottom Privacy Assurance
                        const Text(
                          'By continuing you agree to keep your data strictly on this device',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReferenceHighlightRow({
    required IconData icon,
    required Color iconColor,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131B28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E293B),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF1F5F9),
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PAGE 2: EDUCATOR PERSONALIZATION SETUP
  // ==========================================
  Widget _buildPersonalizationPage(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF090D14),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Top Nav & Step Indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white70),
                    onPressed: _goToPrevPage,
                  ),
                  const Spacer(),
                  _buildStepDot(0, false),
                  const SizedBox(width: 6),
                  _buildStepDot(1, true),
                  const Spacer(),
                  const SizedBox(width: 48), // balance back button
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  MediaQuery.paddingOf(context).bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tell us about yourself',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Set up your preferred salutation for the dashboard welcome and official parent notices.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Salutation / Title Prefix
                    const Text(
                      'Salutation / Title Prefix',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _titleOptions.map((title) {
                        final isSelected = _selectedTitle == title;
                        return ChoiceChip(
                          label: Text(
                            title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryColor,
                          backgroundColor: const Color(0xFF131B28),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryLight
                                : const Color(0xFF1E293B),
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedTitle = title;
                                if (title == 'Sir' || title == 'Mr.') {
                                  _selectedGender = 'Male';
                                } else if (title == 'Miss' || title == 'Ms.') {
                                  _selectedGender = 'Female';
                                }
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Gender Selector
                    Row(
                      children: [
                        const Text(
                          'Gender (Optional)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF131B28),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E293B)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGender,
                              icon: const Icon(Icons.arrow_drop_down_rounded,
                                  color: Color(0xFF94A3B8)),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              dropdownColor: const Color(0xFF131B28),
                              items: _genderOptions.map((g) {
                                return DropdownMenuItem<String>(
                                  value: g,
                                  child: Text(g),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedGender = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Teacher Name
                    CustomTextField(
                      label: 'Teacher Name',
                      controller: _nameController,
                      hint: 'e.g. Alex Smith / Priya Patel',
                      prefixIcon: Icons.person_outline_rounded,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 16),

                    // Institution Type
                    const Text(
                      'Institution Type',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _institutionOptions.map((type) {
                        final isSelected = _selectedInstitutionType == type;
                        return ChoiceChip(
                          label: Text(
                            type,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primaryColor,
                          backgroundColor: const Color(0xFF131B28),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primaryLight
                                : const Color(0xFF1E293B),
                          ),
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedInstitutionType = type;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Structural Tracking System Mode
                    Row(
                      children: [
                        const Text(
                          'System Configuration',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: const Color(0xFF3B82F6)
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _selectedInstitutionType == 'School'
                                ? '⚡ Auto: FULL_DAY'
                                : '⚡ Auto: PERIOD_WISE',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF93C5FD),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B28),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _selectedInstitutionType == 'School'
                                    ? Icons.school_rounded
                                    : Icons.access_time_filled_rounded,
                                color: AppColors.primaryLight,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedInstitutionType == 'School'
                                    ? 'Tracking Mode: FULL_DAY'
                                    : 'Tracking Mode: PERIOD_WISE',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedInstitutionType == 'School'
                                ? 'Master roll call taken once per day. Period selectors and timeslot pickers are streamlined.'
                                : 'Attendance maps to unique timetable slots, subjects, and period sequences.',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Institution Name
                    CustomTextField(
                      label: '$_selectedInstitutionType / Department Name',
                      controller: _instituteController,
                      hint: _selectedInstitutionType == 'School'
                          ? 'e.g. Greenwood High School'
                          : _selectedInstitutionType == 'College'
                              ? 'e.g. St. Xavier\'s College'
                              : 'e.g. Stanford University / Tech Dept',
                      prefixIcon: Icons.account_balance_outlined,
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 18),

                    // Live Display Preview Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B28),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E293B)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.visibility_rounded,
                                size: 14,
                                color: Color(0xFF90B4F8),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'LIVE DISPLAY PREVIEW',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF90B4F8),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• Dashboard: "Welcome back, ${_getGreetingPreview()}!"',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '• Parent Report: "${_getSignaturePreview()}"',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Enter ClassTrack Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _finishOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4E3FC),
                          foregroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Save & Enter ClassTrack',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDot(int index, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isActive ? 22 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF90B4F8) : const Color(0xFF334155),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
