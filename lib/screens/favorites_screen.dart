import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../screens/theme.dart';

// ─── Emoji Box Widget ─────────────────────────────────────────────────────────
class _EmojiBox extends StatelessWidget {
  final String emoji;
  final Color bg;

  const _EmojiBox(this.emoji, {this.bg = kAccentLight});

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

// ─── Pill Badge Widget ────────────────────────────────────────────────────────
class _PillBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;

  const _PillBadge(this.text, {this.color = kBlue, this.bg = kBlueLight});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

// ─── Empty State Widget ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String sub;

  const _EmptyState(this.emoji, this.title, this.sub);

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      const SizedBox(height: 80),
      Center(child: Text(emoji, style: const TextStyle(fontSize: 52))),
      const SizedBox(height: 12),
      Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText),
        ),
      ),
      const SizedBox(height: 4),
      Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            sub,
            style: const TextStyle(fontSize: 13, color: kMuted),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ]);
  }
}

// ─── Favorite Restaurant Card ─────────────────────────────────────────────────
class _FavoriteRestaurantCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback onRemove;

  const _FavoriteRestaurantCard({
    required this.restaurant,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    final cuisine = r['cuisine'] as String? ?? '';
    final price = r['price_range'] as String? ?? '';
    final hours = r['open_hours'] as String? ?? '';

    return Container(
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
        _EmojiBox(cuisineEmoji(cuisine), bg: kPinkLight),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              r['name'] ?? '',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText),
            ),
            Text(
              r['location'] ?? '',
              style: const TextStyle(fontSize: 12, color: kMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(children: [
              _PillBadge(cuisine, color: kBlue, bg: kBlueLight),
              const SizedBox(width: 6),
              _PillBadge(price, color: kGreen, bg: kGreenLight),
            ]),
          ]),
        ),
        Column(children: [
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.favorite_rounded, color: kPink, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            hours.split(' ').take(3).join(' '),
            style: const TextStyle(fontSize: 10, color: kMuted),
            textAlign: TextAlign.right,
          ),
        ]),
      ]),
    );
  }
}

// ─── Saved Meal Card ──────────────────────────────────────────────────────────
class _SavedMealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final VoidCallback onRemove;

  const _SavedMealCard({
    required this.meal,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final m = meal;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(children: [
        _EmojiBox('🍽️', bg: kPinkLight),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              m['meal_name'] ?? '',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText),
            ),
            Text(
              m['restaurant_name'] ?? '',
              style: const TextStyle(fontSize: 12, color: kMuted),
            ),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '\$${(m['price'] as double? ?? 0).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kAccent),
          ),
          Text(
            m['saved_date'] ?? '',
            style: const TextStyle(fontSize: 11, color: kMuted),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.delete_outline_rounded, color: kMuted, size: 18),
          ),
        ]),
      ]),
    );
  }
}

// ─── FAVORITES SCREEN ─────────────────────────────────────────────────────────
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<Map<String, dynamic>> _favRestaurants = [];
  List<Map<String, dynamic>> _savedMeals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final favs = await FavoritesService.getFavorites();
    final meals = await FavoritesService.getSavedMeals();
    if (mounted) {
      setState(() {
        _favRestaurants = favs;
        _savedMeals = meals;
        _loading = false;
      });
    }
  }

  Future<void> _removeFavorite(int id) async {
    await FavoritesService.removeFromFavorites(id);
    _load();
  }

  Future<void> _removeMeal(int id) async {
    await FavoritesService.removeSavedMeal(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Text(
              '❤️ Favorites',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kText),
            ),
          ),

          // ── Tab Bar ──
          TabBar(
            controller: _tabCtrl,
            labelColor: kAccent,
            unselectedLabelColor: kMuted,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            indicatorColor: kAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            tabs: const [
              Tab(text: 'Restaurants'),
              Tab(text: 'Saved Meals'),
            ],
          ),

          // ── Tab Content ──
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: kAccent))
                : TabBarView(
                    controller: _tabCtrl,
                    children: [
                      // ── Restaurants Tab ──
                      RefreshIndicator(
                        onRefresh: _load,
                        color: kAccent,
                        child: _favRestaurants.isEmpty
                            ? _EmptyState(
                                '🤍',
                                'No favorite restaurants yet',
                                'Tap ❤️ on any restaurant to save it here',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                                itemCount: _favRestaurants.length,
                                itemBuilder: (_, i) {
                                  final r = _favRestaurants[i];
                                  return _FavoriteRestaurantCard(
                                    restaurant: r,
                                    onRemove: () => _removeFavorite(r['id'] as int),
                                  );
                                },
                              ),
                      ),

                      // ── Saved Meals Tab ──
                      RefreshIndicator(
                        onRefresh: _load,
                        color: kAccent,
                        child: _savedMeals.isEmpty
                            ? _EmptyState(
                                '🍽️',
                                'No saved meals yet',
                                'Log meals from restaurant pages to see them here',
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                                itemCount: _savedMeals.length,
                                itemBuilder: (_, i) {
                                  final m = _savedMeals[i];
                                  return _SavedMealCard(
                                    meal: m,
                                    onRemove: () => _removeMeal(m['id'] as int),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
