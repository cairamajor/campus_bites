import 'package:flutter/material.dart';
import '../services/restaurant_service.dart';
import '../services/favorites_service.dart';
import '../screens/theme.dart';
import '../screens/restaurant_detail_screen.dart';

// ─── Filter Chip Widget ───────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? kAccent : kCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? kAccent : kBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : kText,
          ),
        ),
      ),
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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

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
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 26))),
    );
  }
}

// ─── Restaurant Card Widget ───────────────────────────────────────────────────
class _RestaurantCard extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  final VoidCallback? onFavoriteToggle;

  const _RestaurantCard({
    required this.restaurant,
    this.onFavoriteToggle,
  });

  @override
  State<_RestaurantCard> createState() => _RestaurantCardState();
}

class _RestaurantCardState extends State<_RestaurantCard> {
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
          _EmojiBox(cuisineEmoji(cuisine)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r['name'] ?? '',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kText),
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
              onTap: _toggleFav,
              child: Icon(
                _isFav
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
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

// ─── FIND FOOD SCREEN ─────────────────────────────────────────────────────────
class FindFoodScreen extends StatefulWidget {
  const FindFoodScreen({super.key});

  @override
  State<FindFoodScreen> createState() => _FindFoodScreenState();
}

class _FindFoodScreenState extends State<FindFoodScreen> {
  List<Map<String, dynamic>> _restaurants = [];
  List<String> _cuisines = ['All'];
  String _selectedCuisine = 'All';
  String _selectedPrice = 'All';
  final _searchCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final restaurants = await RestaurantService.filterByCuisineAndPrice(
      cuisine: _selectedCuisine,
      priceRange: _selectedPrice,
    );
    final cuisines = await RestaurantService.getAvailableCuisines();
    if (mounted) {
      setState(() {
        _restaurants = restaurants;
        _cuisines = cuisines;
        _loading = false;
      });
    }
  }

  Future<void> _onSearch() async {
    final q = _searchCtrl.text;
    final results = q.isEmpty
        ? await RestaurantService.filterByCuisineAndPrice(
            cuisine: _selectedCuisine,
            priceRange: _selectedPrice,
          )
        : await RestaurantService.searchRestaurants(q);
    if (mounted) setState(() => _restaurants = results);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header & Filters ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🔍 Find Food',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: kText),
                ),
                const SizedBox(height: 14),

                // ── Search Bar ──
                Container(
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kBorder, width: 2),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Search restaurants, cuisine...',
                      hintStyle: TextStyle(color: kMuted, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: kMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ── Filters Row --
                Row(
                  children: [
                    // Price filter chips
                    _FilterChip(
                      label: 'All',
                      selected: _selectedPrice == 'All',
                      onTap: () {
                        setState(() => _selectedPrice = 'All');
                        _load();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '\$',
                      selected: _selectedPrice == '\$',
                      onTap: () {
                        setState(() => _selectedPrice = '\$');
                        _load();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '\$\$',
                      selected: _selectedPrice == '\$\$',
                      onTap: () {
                        setState(() => _selectedPrice = '\$\$');
                        _load();
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: '\$\$\$',
                      selected: _selectedPrice == '\$\$\$',
                      onTap: () {
                        setState(() => _selectedPrice = '\$\$\$');
                        _load();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── Cuisine Dropdown — replaces the scrollable chips ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedCuisine != 'All' ? kAccent : kCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _selectedCuisine != 'All' ? kAccent : kBorder,
                      width: 2,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCuisine,
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: _selectedCuisine != 'All'
                            ? Colors.white
                            : kMuted,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _selectedCuisine != 'All'
                            ? Colors.white
                            : kText,
                      ),
                      dropdownColor: kCard,
                      borderRadius: BorderRadius.circular(14),
                      
                      items: _cuisines.map((c) {
                        return DropdownMenuItem<String>(
                          value: c,
                          child: Row(children: [
                            Text(
                              c == 'All' ? '🍽️' : cuisineEmoji(c),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              c,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kText,
                              ),
                            ),
                          ]),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCuisine = val);
                          _load();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ── Result Count ──
                Text(
                  '${_restaurants.length} spots found',
                  style: const TextStyle(
                      fontSize: 13,
                      color: kMuted,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // ── Restaurant List ──
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: kAccent))
                : RefreshIndicator(
                    onRefresh: _load,
                    color: kAccent,
                    child: _restaurants.isEmpty
                        ? _EmptyState()
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            itemCount: _restaurants.length,
                            itemBuilder: (_, i) => _RestaurantCard(
                              restaurant: _restaurants[i],
                              onFavoriteToggle: _load,
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State Widget ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(children: const [
      SizedBox(height: 80),
      Center(child: Text('🍽️', style: TextStyle(fontSize: 52))),
      SizedBox(height: 12),
      Center(
        child: Text(
          'No restaurants found',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700, color: kText),
        ),
      ),
      SizedBox(height: 4),
      Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Try a different search or filter',
            style: TextStyle(fontSize: 13, color: kMuted),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ]);
  }
}
