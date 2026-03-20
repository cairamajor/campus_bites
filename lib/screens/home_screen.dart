import 'package:flutter/material.dart';
import '../services/budget_service.dart';
import '../services/restaurant_service.dart';
import '../services/favorites_service.dart';
import '../screens/restaurant_detail_screen.dart';

//Theme Constants
const kBg = Color(0xFFFAFAF8);
const kCard = Color(0xFFFFFFFF);
const kAccent = Color(0xFFFF6B35);
const kAccentLight = Color(0xFFFFF1EC);
const kGreen = Color(0xFF2ECC71);
const kGreenLight = Color(0xFFE8FAF0);
const kPurple = Color(0xFF7C3AED);
const kPurpleLight = Color(0xFFF3EFFE);
const kPink = Color(0xFFF43F5E);
const kPinkLight = Color(0xFFFFF0F3);
const kBlue = Color(0xFF3B82F6);
const kBlueLight = Color(0xFFEFF6FF);
const kText = Color(0xFF1A1A1A);
const kMuted = Color(0xFF9CA3AF);
const kBorder = Color(0xFFF0F0EE);

//Emojis for cuisines
String cuisineEmoji(String cuisine) {
  const map = {
    'American': '🍔',
    'Caribbean': '🌴',
    'Mexican': '🌮',
    'Dessert': '🍰',
    'Halal': '🥙',
    'Healthy': '🥗',
    'Indian': '🍛',
    'Japanese': '🍱',
    'Soul Food': '🍗',
    'BBQ': '🍖',
    'Chinese': '🥡',
  };
  return map[cuisine] ?? '🍽️';
}

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

// ─── Restaurant Card ──────────────────────────────────────────────────────────
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

// ─── Quick Access Card ────────────────────────────────────────────────────────
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Campus Bites"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : restaurants.isEmpty
              ? const Center(child: Text("No food spots yet"))
              : ListView.builder(
                  itemCount: restaurants.length,
                  itemBuilder: (context, index) {
                    final r = restaurants[index];

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(r.name),
                        subtitle: Text("${r.cuisine} • ${r.priceRange}"),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          // TODO: navigate to detail screen
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: navigate to add restaurant screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}