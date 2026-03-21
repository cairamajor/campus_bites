import 'package:flutter/material.dart';
import '../db/preferences_helper.dart';
import '../services/restaurant_service.dart';
import '../screens/theme.dart';

// Settings Row Widget
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final Widget trailing;

  const _SettingsRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        // Icon box
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        // Title + subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 12, color: kMuted),
                ),
            ],
          ),
        ),
        trailing,
      ]),
    );
  }
}

// Settings Section Card 
class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kMuted,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((e) => Column(children: [
                      e.value,
                      
                      if (e.key < children.length - 1)
                        const Divider(
                          height: 1,
                          indent: 68,
                          endIndent: 16,
                          color: kBorder,
                        ),
                    ]))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// SETTINGS SCREEN 
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  String _favoriteCuisine = 'All';
  String _priceFilter = 'All';
  List<String> _cuisines = ['All'];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Load all saved preferences from SharedPreferences
  Future<void> _load() async {
    setState(() => _loading = true);
    final notifications = await PreferencesHelper.getNotificationsEnabled();
    final darkMode = await PreferencesHelper.getDarkMode();
    final cuisine = await PreferencesHelper.getFavoriteCuisine();
    final price = await PreferencesHelper.getPriceFilter();
    final cuisines = await RestaurantService.getAvailableCuisines();

    if (mounted) {
      setState(() {
        _notificationsEnabled = notifications;
        _darkMode = darkMode;
        _favoriteCuisine = cuisine;
        _priceFilter = price;
        _cuisines = cuisines;
        _loading = false;
      });
    }
  }

  // Save notification preference
  Future<void> _toggleNotifications(bool val) async {
    await PreferencesHelper.setNotificationsEnabled(val);
    setState(() => _notificationsEnabled = val);
  }

  // Save dark mode preference
  Future<void> _toggleDarkMode(bool val) async {
    await PreferencesHelper.setDarkMode(val);
    setState(() => _darkMode = val);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dark mode preference saved!'),
          backgroundColor: kPurple,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Show cuisine picker bottom sheet
  void _showCuisinePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favorite Cuisine',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Used to personalize your home screen suggestions',
              style: TextStyle(fontSize: 13, color: kMuted),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _cuisines.map((c) {
                final selected = _favoriteCuisine == c;
                return GestureDetector(
                  onTap: () async {
                    await PreferencesHelper.setFavoriteCuisine(c);
                    setState(() => _favoriteCuisine = c);
                    if (mounted) Navigator.pop(context);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? kAccent : kBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: selected ? kAccent : kBorder),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : kText,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Show price filter picker bottom sheet
  void _showPricePicker() {
    final prices = ['All', '\$', '\$\$', '\$\$\$'];
    showModalBottomSheet(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Range Preference',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: kText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Filters suggestions on your home screen',
              style: TextStyle(fontSize: 13, color: kMuted),
            ),
            const SizedBox(height: 16),
            Row(
              children: prices.map((p) {
                final selected = _priceFilter == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      await PreferencesHelper.setPriceFilter(p);
                      setState(() => _priceFilter = p);
                      if (mounted) Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: selected ? kGreen : kBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: selected ? kGreen : kBorder),
                      ),
                      child: Center(
                        child: Text(
                          p,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: selected ? Colors.white : kText,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Confirm and clear all preferences
  void _confirmReset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset Settings?',
          style: TextStyle(fontWeight: FontWeight.w800, color: kText),
        ),
        content: const Text(
          'This will reset all preferences back to defaults.',
          style: TextStyle(color: kMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kMuted)),
          ),
          TextButton(
            onPressed: () async {
              await PreferencesHelper.clearAll();
              Navigator.pop(context);
              _load(); // Reload defaults
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                  backgroundColor: kPink,
                ),
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(
                  color: kPink, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '⚙️ Settings',
          style: TextStyle(
              color: kText, fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Preferences
                  _SettingsCard(
                    title: 'Food Preferences',
                    children: [
                      // Favorite cuisine 
                      GestureDetector(
                        onTap: _showCuisinePicker,
                        child: _SettingsRow(
                          icon: Icons.restaurant_rounded,
                          iconColor: kAccent,
                          iconBg: kAccentLight,
                          title: 'Favorite Cuisine',
                          subtitle: 'Personalizes your home suggestions',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _favoriteCuisine,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kAccent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded,
                                  color: kMuted, size: 20),
                            ],
                          ),
                        ),
                      ),
                      // Price filter — personalizes home screen
                      GestureDetector(
                        onTap: _showPricePicker,
                        child: _SettingsRow(
                          icon: Icons.attach_money_rounded,
                          iconColor: kGreen,
                          iconBg: kGreenLight,
                          title: 'Price Range',
                          subtitle: 'Filters your home suggestions',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _priceFilter,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kGreen,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.chevron_right_rounded,
                                  color: kMuted, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── App Preferences ──
                  _SettingsCard(
                    title: 'App Preferences',
                    children: [
                      // Notifications toggle
                      _SettingsRow(
                        icon: Icons.notifications_rounded,
                        iconColor: kPurple,
                        iconBg: kPurpleLight,
                        title: 'Notifications',
                        subtitle: 'Budget alerts and reminders',
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: _toggleNotifications,
                          activeColor: kPurple,
                        ),
                      ),
                      // Dark mode toggle
                      _SettingsRow(
                        icon: Icons.dark_mode_rounded,
                        iconColor: kText,
                        iconBg: kBorder,
                        title: 'Dark Mode',
                        subtitle: 'Saved for future update',
                        trailing: Switch(
                          value: _darkMode,
                          onChanged: _toggleDarkMode,
                          activeColor: kText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── About ──
                  _SettingsCard(
                    title: 'About',
                    children: [
                      _SettingsRow(
                        icon: Icons.info_outline_rounded,
                        iconColor: kBlue,
                        iconBg: kBlueLight,
                        title: 'Campus Bites',
                        subtitle: 'Version 1.0.0',
                        trailing: const SizedBox.shrink(),
                      ),
                      GestureDetector(
                        onTap: _confirmReset,
                        child: _SettingsRow(
                          icon: Icons.refresh_rounded,
                          iconColor: kPink,
                          iconBg: kPinkLight,
                          title: 'Reset All Settings',
                          subtitle: 'Restore defaults',
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: kMuted, size: 20),
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