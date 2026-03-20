import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/find_food_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/ai_matcher_screen.dart';

// ─── App Entry Point ──────────────────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const CampusBitesApp());
}

// ─── Root App Widget ──────────────────────────────────────────────────────────
class CampusBitesApp extends StatelessWidget {
  const CampusBitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Bites',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B35)),
        scaffoldBackgroundColor: const Color(0xFFFAFAF8),
        useMaterial3: true,
      ),
      home: const MainShell(),
    );
  }
}

// ─── Main Shell with Bottom Navigation ───────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int currentIndex = 0;

  // All main screens
  final List<Widget> _screens = const [
    HomeScreen(),
    FindFoodScreen(),
    FavoritesScreen(),
    BudgetScreen(),
    AiMatcherScreen(),
  ];

  void goToTab(int index) {
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: Border(
            top: BorderSide(color: Color(0xFFF0F0EE), width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  current: currentIndex,
                  onTap: goToTab,
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  index: 1,
                  current: currentIndex,
                  onTap: goToTab,
                ),
                _NavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Saved',
                  index: 2,
                  current: currentIndex,
                  onTap: goToTab,
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Budget',
                  index: 3,
                  current: currentIndex,
                  onTap: goToTab,
                ),
                _NavItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'AI Match',
                  index: 4,
                  current: currentIndex,
                  onTap: (_) => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiMatcherScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Nav Item Widget ──────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFFF1EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFFFF6B35) : const Color(0xFF9CA3AF),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? const Color(0xFFFF6B35)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
