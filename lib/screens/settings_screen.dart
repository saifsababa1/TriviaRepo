// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/unified_audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  // Settings state
  bool _backgroundMusicEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _notificationsEnabled = true;
  double _musicVolume = 0.7;
  double _effectsVolume = 0.8;
  String _selectedLanguage = 'English';
  String _selectedDifficulty = 'Medium';

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
  ];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard', 'Expert'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _loadSettings() {
    // Load from Audio Service
    final audioService = UnifiedAudioService();
    setState(() {
      _backgroundMusicEnabled = audioService.backgroundMusicEnabled;
      _soundEffectsEnabled = audioService.soundEffectsEnabled;
      _musicVolume = audioService.musicVolume;
      _effectsVolume = audioService.effectsVolume;
      _notificationsEnabled = true;
      _selectedLanguage = 'English';
      _selectedDifficulty = 'Medium';
    });
  }

  void _saveSettings() async {
    // Save to Audio Service
    final audioService = UnifiedAudioService();
    await audioService.updateBackgroundMusicEnabled(_backgroundMusicEnabled);
    await audioService.updateSoundEffectsEnabled(_soundEffectsEnabled);
    await audioService.updateMusicVolume(_musicVolume);
    await audioService.updateEffectsVolume(_effectsVolume);

    // Add save animation
    _showSuccessSnackBar();
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Settings Saved!',
                      style: GoogleFonts.luckiestGuy(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Your preferences have been updated',
                      style: GoogleFonts.luckiestGuy(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetSettings() {
    showDialog(context: context, builder: (context) => _buildResetDialog());
  }

  Widget _buildResetDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 16,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF6B35), Color(0xFFFF8F00)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Reset All Settings?',
              style: GoogleFonts.luckiestGuy(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'This will restore all settings to their default values. This action cannot be undone.',
              style: GoogleFonts.luckiestGuy(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildDialogButton(
                    'Cancel',
                    Colors.white.withOpacity(0.2),
                    Colors.white,
                    () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDialogButton(
                    'Reset',
                    Colors.white,
                    const Color(0xFFFF6B35),
                    () {
                      setState(() {
                        _backgroundMusicEnabled = true;
                        _soundEffectsEnabled = true;
                        _notificationsEnabled = true;
                        _musicVolume = 0.7;
                        _effectsVolume = 0.8;
                        _selectedLanguage = 'English';
                        _selectedDifficulty = 'Medium';
                      });
                      Navigator.pop(context);
                      _saveSettings();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: GoogleFonts.luckiestGuy(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildAudioSection(),
                  const SizedBox(height: 20),
                  _buildGameplaySection(),
                  const SizedBox(height: 20),
                  _buildNotificationSection(),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 28,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Customize your gaming experience',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.luckiestGuy(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAudioSection() {
    return _buildSettingsCard(
      title: 'Audio & Sound',
      icon: Icons.volume_up_rounded,
      accentColor: const Color(0xFF4CAF50),
      children: [
        _buildEnhancedSwitchTile(
          title: 'Background Music',
          subtitle: 'Immersive ambient music during gameplay',
          value: _backgroundMusicEnabled,
          icon: Icons.music_note,
          onChanged: (value) async {
            setState(() => _backgroundMusicEnabled = value);
            await UnifiedAudioService().updateBackgroundMusicEnabled(value);
          },
        ),
        if (_backgroundMusicEnabled) ...[
          const SizedBox(height: 16),
          _buildEnhancedSliderTile(
            title: 'Music Volume',
            subtitle: 'Adjust background music level',
            value: _musicVolume,
            icon: Icons.music_note,
            color: const Color(0xFF4CAF50),
            onChanged: (value) async {
              setState(() => _musicVolume = value);
              await UnifiedAudioService().updateMusicVolume(value);
            },
          ),
        ],
        const SizedBox(height: 16),
        _buildEnhancedSwitchTile(
          title: 'Sound Effects',
          subtitle: 'Button clicks, correct/wrong sounds',
          value: _soundEffectsEnabled,
          icon: Icons.speaker,
          onChanged: (value) async {
            setState(() => _soundEffectsEnabled = value);
            await UnifiedAudioService().updateSoundEffectsEnabled(value);
          },
        ),
        if (_soundEffectsEnabled) ...[
          const SizedBox(height: 16),
          _buildEnhancedSliderTile(
            title: 'Effects Volume',
            subtitle: 'Adjust sound effects level',
            value: _effectsVolume,
            icon: Icons.speaker,
            color: const Color(0xFF2196F3),
            onChanged: (value) async {
              setState(() => _effectsVolume = value);
              await UnifiedAudioService().updateEffectsVolume(value);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildGameplaySection() {
    return _buildSettingsCard(
      title: 'Gameplay',
      icon: Icons.games_rounded,
      accentColor: const Color(0xFF9C27B0),
      children: [
        _buildEnhancedDropdownTile(
          title: 'Default Difficulty',
          subtitle: 'Starting difficulty for new games',
          value: _selectedDifficulty,
          items: _difficulties,
          icon: Icons.bar_chart,
          onChanged: (value) {
            setState(() => _selectedDifficulty = value!);
          },
        ),
        const SizedBox(height: 16),
        _buildEnhancedDropdownTile(
          title: 'Language',
          subtitle: 'Interface and question language',
          value: _selectedLanguage,
          items: _languages,
          icon: Icons.language,
          onChanged: (value) {
            setState(() => _selectedLanguage = value!);
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSettingsCard(
      title: 'Notifications',
      icon: Icons.notifications_rounded,
      accentColor: const Color(0xFFE91E63),
      children: [
        _buildEnhancedSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Daily challenges and achievements',
          value: _notificationsEnabled,
          icon: Icons.notification_important,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
          },
        ),
      ],
    );
  }

  Widget _buildEnhancedSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFFD700),
            activeTrackColor: const Color(0xFFFFD700).withOpacity(0.3),
            inactiveThumbColor: Colors.white.withOpacity(0.8),
            inactiveTrackColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required IconData icon,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(value * 100).round()}%',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: color,
              overlayColor: color.withOpacity(0.3),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0.0,
              max: 1.0,
              divisions: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.luckiestGuy(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                onChanged: onChanged,
                isExpanded: true,
                dropdownColor: const Color(0xFF764ba2),
                style: GoogleFonts.luckiestGuy(
                  fontSize: 14,
                  color: Colors.white,
                ),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items:
                    items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Reset All',
                Icons.restore_rounded,
                const Color(0xFFFF6B35),
                _resetSettings,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                'Save Settings',
                Icons.save_rounded,
                const Color(0xFF4CAF50),
                _saveSettings,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          text,
          style: GoogleFonts.luckiestGuy(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
