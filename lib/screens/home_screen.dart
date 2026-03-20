import 'package:flutter/material.dart';
import '../main.dart';
import '../services/budget_service.dart';
import '../services/restaurant_service.dart';
import '../services/favorites_service.dart';
import '../screens/restaurant_detail_screen.dart';
import '../screens/theme.dart';
import '../screens/ai_matcher_screen.dart';



// Shared Widgets
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: kText,
        ),
      ),
    );
  }
}
class PillBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  const PillBadge(this.text, {super.key, this.color = kBlue, this.bg = kBlueLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class EmojiBox extends StatelessWidget {
  final String emoji;
  final Color bg;
  const EmojiBox(this.emoji, {super.key, this.bg = kAccentLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 26))),
    );
  }
}

//  Restaurant Card 
class RestaurantCard extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback? onFavoriteToggle;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    this.onFavoriteToggle,
  });

  @override
  State<RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<RestaurantCard> {
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  Future<void> _checkFav() async {
    final id = widget.restaurant['id'] as int?;
    if (id != null) {
      final fav = await FavoritesService.isFavorite(id);
      if (mounted) setState(() => _isFav = fav);
    }
  }

  Future<void> _toggleFav() async {
    final id = widget.restaurant['id'] as int?;
    if (id == null) return;
    final result = await FavoritesService.toggleFavorite(id);
    setState(() => _isFav = result);
    widget.onFavoriteToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final cuisine = r['cuisine'] as String? ?? '';
    final price = r['price_range'] as String? ?? '';
    final hours = r['open_hours'] as String? ?? '';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantDetailScreen(restaurant: r),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(children: [
          EmojiBox(cuisineEmoji(cuisine)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r['name'] ?? '',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText)),
              Text(r['location'] ?? '',
                  style: const TextStyle(fontSize: 12, color: kMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                PillBadge(cuisine, color: kBlue, bg: kBlueLight),
                const SizedBox(width: 6),
                PillBadge(price, color: kGreen, bg: kGreenLight),
              ]),
            ]),
          ),
          Column(children: [
            GestureDetector(
              onTap: _toggleFav,
              child: Icon(
                _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _isFav ? kPink : kMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              hours.split(' ').take(3).join(' '),
              style: const TextStyle(fontSize: 10, color: kMuted),
              textAlign: TextAlign.right,
            ),
          ]),
        ]),
      ),
    );
  }
}

//  Quick Access Card 
class QuickCard extends StatelessWidget {
  final String icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  const QuickCard({
    super.key,
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(20),
          border: Border(bottom: BorderSide(color: color, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const Spacer(),
          Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: kText)),
          Text(sub, style: const TextStyle(fontSize: 11, color: kMuted)),
        ]),
      ),
    );
  }
}

//HOME SCREEN 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _budget = 50.0;
  double _spent = 0.0;
  List<Map<String, dynamic>> _recent = [];
  bool _editingBudget = false;
  final _budgetCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final budget = await BudgetService.getWeeklyBudget();
    final spent = await BudgetService.getWeeklySpending();
    final recent = await RestaurantService.getAllRestaurants();
    if (mounted) {
      setState(() {
        _budget = budget;
        _spent = spent;
        _recent = recent.take(3).toList();
        _budgetCtrl.text = budget.toStringAsFixed(0);
      });
    }
  }

   Future<void> _saveBudget() async {
    final val = double.tryParse(_budgetCtrl.text);
    if (val != null && val > 0) {
      await BudgetService.updateWeeklyBudget(val);
      setState(() {
        _budget = val;
        _editingBudget = false;
      });
    }
  }

  void _goToTab(int index) {
  final shell = context.findAncestorStateOfType<MainShellState>();
  shell?.goToTab(index);
}

@override
  Widget build(BuildContext context) {
    final left = (_budget - _spent).clamp(0.0, _budget);
    final pct = (_budget > 0) ? (_spent / _budget).clamp(0.0, 1.0) : 0.0;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        color: kAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              const Text(
                'Your food & budget companion',
                style: TextStyle(fontSize: 13, color: kMuted, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              const Text(
                'Campus Bites 🍽️',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kText),
              ),
              const SizedBox(height: 20),

              // ── Budget Card ──
              _BudgetCard(
                budget: _budget,
                left: left,
                pct: pct,
                spent: _spent,
                editing: _editingBudget,
                controller: _budgetCtrl,
                onTapEdit: () => setState(() => _editingBudget = true),
                onSave: _saveBudget,
              ),
              const SizedBox(height: 20),

              // ── Quick Access Grid ──
              const SectionTitle('Quick Access'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  QuickCard(
                    icon: '🔍', label: 'Find Food', sub: 'Browse nearby options',
                    color: kBlue, onTap: () => _goToTab(1),
                  ),
                  QuickCard(
                    icon: '💰', label: 'Budget', sub: 'Track your spending',
                    color: kGreen, onTap: () => _goToTab(3),
                  ),
                  QuickCard(
                    icon: '❤️', label: 'Favorites', sub: 'Your saved spots',
                    color: kPink, onTap: () => _goToTab(2),
                  ),
                  QuickCard(
                    icon: '✨', label: 'AI Matcher', sub: 'Smart suggestions',
                    color: kPurple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiMatcherScreen()),),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Nearby Spots ──
              const SectionTitle('Nearby Spots'),
              ..._recent.map((r) => RestaurantCard(restaurant: r, onFavoriteToggle: _load)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final double budget;
  final double left;
  final double pct;
  final double spent;
  final bool editing;
  final TextEditingController controller;
  final VoidCallback onTapEdit;
  final VoidCallback onSave;

  const _BudgetCard({
    required this.budget,
    required this.left,
    required this.pct,
    required this.spent,
    required this.editing,
    required this.controller,
    required this.onTapEdit,
    required this.onSave,
  });

@override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF9A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kAccent.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💵 Weekly Budget',
            style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          if (editing)
            Row(children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    prefixText: '\$',
                    prefixStyle: const TextStyle(fontSize: 28, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white38),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white38),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onSave,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(color: kAccent, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ])
          else
            GestureDetector(
              onTap: onTapEdit,
              child: Row(children: [
                Text(
                  '\$${left.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'left ✏️',
                  style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
              ]),
            ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Spent \$${spent.toStringAsFixed(2)} of \$${budget.toStringAsFixed(0)} this week',
            style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}