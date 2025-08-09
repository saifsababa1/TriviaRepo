import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Settings state
  bool _backgroundMusicEnabled = true;
  bool _soundEffectsEnabled = true;
  bool _vibrationsEnabled = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
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
  ];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard', 'Expert'];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  void _loadSettings() {
    // In a real app, load from SharedPreferences or similar
    setState(() {
      _backgroundMusicEnabled = true;
      _soundEffectsEnabled = true;
      _vibrationsEnabled = true;
      _notificationsEnabled = true;
      _darkModeEnabled = false;
      _musicVolume = 0.7;
      _effectsVolume = 0.8;
      _selectedLanguage = 'English';
      _selectedDifficulty = 'Medium';
    });
  }

  void _saveSettings() {
    // In a real app, save to SharedPreferences or similar
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved successfully! ✅',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Reset Settings',
                  style: GoogleFonts.luckiestGuy(fontSize: 18),
                ),
              ],
            ),
            content: Text(
              'Are you sure you want to reset all settings to default?',
              style: GoogleFonts.roboto(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.roboto(color: Colors.grey[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _backgroundMusicEnabled = true;
                    _soundEffectsEnabled = true;
                    _vibrationsEnabled = true;
                    _notificationsEnabled = true;
                    _darkModeEnabled = false;
                    _musicVolume = 0.7;
                    _effectsVolume = 0.8;
                    _selectedLanguage = 'English';
                    _selectedDifficulty = 'Medium';
                  });
                  Navigator.pop(context);
                  _saveSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 2.0,
          colors: [Color(0xFF9C27B0), Color(0xFF7B1FA2), Color(0xFF4A148C)],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildAudioSection(),
                      const SizedBox(height: 16),
                      _buildGameplaySection(),
                      const SizedBox(height: 16),
                      _buildDisplaySection(),
                      const SizedBox(height: 16),
                      _buildNotificationSection(),
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE1BEE7), Color(0xFFCE93D8), Color(0xFFBA68C8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game Settings',
                  style: GoogleFonts.luckiestGuy(
                    fontSize: 24,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Customize your gaming experience',
                  style: GoogleFonts.roboto(
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
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAudioSection() {
    return _buildSettingsCard(
      title: 'Audio Settings',
      icon: Icons.volume_up,
      children: [
        _buildSwitchTile(
          title: 'Background Music',
          subtitle: 'Play ambient music during gameplay',
          value: _backgroundMusicEnabled,
          onChanged: (value) {
            setState(() {
              _backgroundMusicEnabled = value;
            });
            HapticFeedback.lightImpact();
          },
        ),
        const SizedBox(height: 8),
        if (_backgroundMusicEnabled) ...[
          _buildSliderTile(
            title: 'Music Volume',
            value: _musicVolume,
            onChanged: (value) {
              setState(() {
                _musicVolume = value;
              });
            },
          ),
          const SizedBox(height: 8),
        ],
        _buildSwitchTile(
          title: 'Sound Effects',
          subtitle: 'Button clicks, correct/wrong sounds',
          value: _soundEffectsEnabled,
          onChanged: (value) {
            setState(() {
              _soundEffectsEnabled = value;
            });
            HapticFeedback.lightImpact();
          },
        ),
        const SizedBox(height: 8),
        if (_soundEffectsEnabled) ...[
          _buildSliderTile(
            title: 'Effects Volume',
            value: _effectsVolume,
            onChanged: (value) {
              setState(() {
                _effectsVolume = value;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildGameplaySection() {
    return _buildSettingsCard(
      title: 'Gameplay',
      icon: Icons.games,
      children: [
        _buildDropdownTile(
          title: 'Default Difficulty',
          value: _selectedDifficulty,
          items: _difficulties,
          onChanged: (value) {
            setState(() {
              _selectedDifficulty = value!;
            });
            HapticFeedback.lightImpact();
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownTile(
          title: 'Language',
          value: _selectedLanguage,
          items: _languages,
          onChanged: (value) {
            setState(() {
              _selectedLanguage = value!;
            });
            HapticFeedback.lightImpact();
          },
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          title: 'Vibrations',
          subtitle: 'Haptic feedback for interactions',
          value: _vibrationsEnabled,
          onChanged: (value) {
            setState(() {
              _vibrationsEnabled = value;
            });
            if (value) HapticFeedback.mediumImpact();
          },
        ),
      ],
    );
  }

  Widget _buildDisplaySection() {
    return _buildSettingsCard(
      title: 'Display',
      icon: Icons.display_settings,
      children: [
        _buildSwitchTile(
          title: 'Dark Mode',
          subtitle: 'Switch to dark theme (coming soon)',
          value: _darkModeEnabled,
          onChanged: (value) {
            setState(() {
              _darkModeEnabled = value;
            });
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _buildSettingsCard(
      title: 'Notifications',
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Get notified about daily challenges',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFFD700),
          activeTrackColor: const Color(0xFFFFD700).withOpacity(0.3),
          inactiveThumbColor: Colors.grey[300],
          inactiveTrackColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(value * 100).round()}%',
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFFFD700),
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: const Color(0xFFFFD700),
            overlayColor: const Color(0xFFFFD700).withOpacity(0.3),
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
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              isExpanded: true,
              dropdownColor: const Color(0xFF7B1FA2),
              style: GoogleFonts.roboto(fontSize: 14, color: Colors.white),
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _resetSettings,
            icon: const Icon(Icons.restore, color: Colors.white),
            label: Text(
              'Reset',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save, color: Colors.white),
            label: Text(
              'Save',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
