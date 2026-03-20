import 'package:flutter/material.dart';
import '../services/favorites_service.dart';
import '../services/review_service.dart';
import '../services/budget_service.dart';
import '../screens/theme.dart';

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

// ─── Info Row Widget ──────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: kAccent),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text, style: const TextStyle(fontSize: 14, color: kMuted)),
      ),
    ]);
  }
}

// ─── Review Card Widget ───────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final VoidCallback onDelete;

  const _ReviewCard({required this.review, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final rating = review['rating'] as int? ?? 0;
    final note = review['note'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // ── Star Rating ──
          ...List.generate(
            5,
            (i) => Icon(
              i < rating ? Icons.star_rounded : Icons.star_border_rounded,
              color: Colors.amber,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ReviewService.getRatinglabel(rating),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kMuted),
          ),
          const Spacer(),
          Text(
            review['review_date'] ?? '',
            style: const TextStyle(fontSize: 11, color: kMuted),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.delete_outline_rounded, color: kMuted, size: 18),
          ),
        ]),
        if (note.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(note, style: const TextStyle(fontSize: 13, color: kText)),
        ],
      ]),
    );
  }
}

// ─── Log Meal Bottom Sheet ────────────────────────────────────────────────────
class _LogMealSheet extends StatelessWidget {
  final String restaurantName;
  final String cuisine;
  final VoidCallback onLogged;

  const _LogMealSheet({
    required this.restaurantName,
    required this.cuisine,
    required this.onLogged,
  });

  @override
  Widget build(BuildContext context) {
    final mealCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Log a Meal',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText),
          ),
          const SizedBox(height: 4),
          Text(
            'at $restaurantName',
            style: const TextStyle(fontSize: 13, color: kMuted),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: mealCtrl,
            decoration: InputDecoration(
              hintText: 'Meal name e.g. Jerk Chicken',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kAccent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: 'Amount spent',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kAccent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text);
                if (mealCtrl.text.isEmpty || amount == null) return;
                await BudgetService.logMealExpense(
                  mealName: mealCtrl.text,
                  amount: amount,
                  category: cuisine,
                );
                Navigator.pop(context);
                onLogged();
              },
              child: const Text(
                'Log Expense',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Write Review Bottom Sheet ────────────────────────────────────────────────
class _WriteReviewSheet extends StatefulWidget {
  final int restaurantId;
  final String restaurantName;
  final VoidCallback onReviewed;

  const _WriteReviewSheet({
    required this.restaurantId,
    required this.restaurantName,
    required this.onReviewed,
  });

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _selectedRating = 5;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Leave a Review',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kText),
          ),
          const SizedBox(height: 16),

          // ── Star Rating ──
          const Text(
            'Rating',
            style: TextStyle(fontWeight: FontWeight.w600, color: kMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _selectedRating = i + 1),
                child: Icon(
                  i < _selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            ReviewService.getRatinglabel(_selectedRating),
            style: const TextStyle(fontSize: 13, color: kMuted, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // ── Note ──
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your thoughts...',
              hintStyle: const TextStyle(color: kMuted),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kPurple, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Submit Button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () async {
                await ReviewService.addReview(
                  restaurantId: widget.restaurantId,
                  restaurantName: widget.restaurantName,
                  rating: _selectedRating,
                  note: _noteCtrl.text,
                );
                Navigator.pop(context);
                widget.onReviewed();
              },
              child: const Text(
                'Submit Review',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── RESTAURANT DETAIL SCREEN ─────────────────────────────────────────────────
class RestaurantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  bool _isFav = false;
  List<Map<String, dynamic>> _reviews = [];
  double _avgRating = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.restaurant['id'] as int?;
    if (id == null) return;
    final fav = await FavoritesService.isFavorite(id);
    final reviews = await ReviewService.getReviewsForRestaurant(id);
    final avg = await ReviewService.getAverageRating(id);
    if (mounted) {
      setState(() {
        _isFav = fav;
        _reviews = reviews;
        _avgRating = avg;
      });
    }
  }

  Future<void> _toggleFav() async {
    final id = widget.restaurant['id'] as int?;
    if (id == null) return;
    final result = await FavoritesService.toggleFavorite(id);
    setState(() => _isFav = result);
  }

  void _showLogMealSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LogMealSheet(
        restaurantName: widget.restaurant['name'] ?? '',
        cuisine: widget.restaurant['cuisine'] ?? '',
        onLogged: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meal logged! 🍽️'),
            backgroundColor: kAccent,
          ),
        ),
      ),
    );
  }

  void _showReviewSheet() {
    final id = widget.restaurant['id'] as int?;
    if (id == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _WriteReviewSheet(
        restaurantId: id,
        restaurantName: widget.restaurant['name'] ?? '',
        onReviewed: _load,
      ),
    );
  }

  Future<void> _deleteReview(int id) async {
    await ReviewService.deleteReview(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final cuisine = r['cuisine'] as String? ?? '';
    final price = r['price_range'] as String? ?? '';
    final highlights = (r['menu_highlights'] as String? ?? '')
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isFav ? kPink : kMuted,
            ),
            onPressed: _toggleFav,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Emoji Header ──
            Center(
              child: Text(
                cuisineEmoji(cuisine),
                style: const TextStyle(fontSize: 72),
              ),
            ),
            const SizedBox(height: 12),

            // ── Name ──
            Text(
              r['name'] ?? '',
              style: const TextStyle(
                fontSize: 26, fontWeight: FontWeight.w900, color: kText,
              ),
            ),
            const SizedBox(height: 8),

            // ── Pills ──
            Row(children: [
              _PillBadge(cuisine, color: kBlue, bg: kBlueLight),
              const SizedBox(width: 8),
              _PillBadge(price, color: kGreen, bg: kGreenLight),
              if (_avgRating > 0) ...[
                const SizedBox(width: 8),
                _PillBadge(
                  '⭐ ${_avgRating.toStringAsFixed(1)}',
                  color: Colors.amber.shade800,
                  bg: Colors.amber.shade50,
                ),
              ],
            ]),
            const SizedBox(height: 16),

            // ── Info Rows ──
            _InfoRow(Icons.location_on_rounded, r['location'] ?? ''),
            const SizedBox(height: 8),
            _InfoRow(Icons.access_time_rounded, r['open_hours'] ?? ''),
            const SizedBox(height: 24),

            // ── Menu Highlights ──
            const Text(
              'Menu Highlights',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kText),
            ),
            const SizedBox(height: 10),
            ...highlights.map((h) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(children: [
                const Icon(Icons.restaurant_menu_rounded, size: 16, color: kAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(h, style: const TextStyle(fontSize: 14, color: kText)),
                ),
              ]),
            )),
            const SizedBox(height: 24),

            // ── Log Meal Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Log a Meal Here',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                onPressed: _showLogMealSheet,
              ),
            ),
            const SizedBox(height: 10),

            // ── Write Review Button ──
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPurple,
                  side: const BorderSide(color: kPurple),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.rate_review_rounded),
                label: const Text(
                  'Write a Review',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                onPressed: _showReviewSheet,
              ),
            ),
            const SizedBox(height: 24),

            // ── Reviews Section ──
            if (_reviews.isNotEmpty) ...[
              Text(
                'Reviews (${_reviews.length})',
                style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800, color: kText,
                ),
              ),
              const SizedBox(height: 10),
              ..._reviews.map((rev) => _ReviewCard(
                review: rev,
                onDelete: () => _deleteReview(rev['id'] as int),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
