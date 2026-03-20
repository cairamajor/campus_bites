import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/budget_service.dart';

// ─── Theme Constants ──────────────────────────────────────────────────────────
const kBg = Color(0xFFFAFAF8);
const kCard = Color(0xFFFFFFFF);
const kAccent = Color(0xFFFF6B35);
const kAccentLight = Color(0xFFFFF1EC);
const kGreen = Color(0xFF2ECC71);
const kGreenLight = Color(0xFFE8FAF0);
const kPink = Color(0xFFF43F5E);
const kBlue = Color(0xFF3B82F6);
const kBlueLight = Color(0xFFEFF6FF);
const kPurple = Color(0xFF7C3AED);
const kPurpleLight = Color(0xFFF3EFFE);
const kText = Color(0xFF1A1A1A);
const kMuted = Color(0xFF9CA3AF);
const kBorder = Color(0xFFF0F0EE);

// ─── Cuisine Emoji Helper ─────────────────────────────────────────────────────
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

// ─── Suggestion Restaurant Card ───────────────────────────────────────────────
class _SuggestionCard extends StatelessWidget {
  final Map<String, dynamic> restaurant;

  const _SuggestionCard({required this.restaurant});

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
        border: Border.all(color: kPurple.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(children: [
        _EmojiBox(cuisineEmoji(cuisine), bg: kPurpleLight),
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
              _PillBadge(cuisine, color: kPurple, bg: kPurpleLight),
              const SizedBox(width: 6),
              _PillBadge(price, color: kGreen, bg: kGreenLight),
            ]),
          ]),
        ),
        Text(
          hours.split(' ').take(3).join(' '),
          style: const TextStyle(fontSize: 10, color: kMuted),
          textAlign: TextAlign.right,
        ),
      ]),
    );
  }
}

// ─── Mood Chip Widget ─────────────────────────────────────────────────────────
class _MoodChip extends StatelessWidget {
  final String mood;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.mood,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? kPurple : kCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? kPurple : kBorder),
        ),
        child: Text(
          '$icon $mood',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? Colors.white : kText,
          ),
        ),
      ),
    );
  }
}

// ─── Time Chip Widget ─────────────────────────────────────────────────────────
class _TimeChip extends StatelessWidget {
  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  const _TimeChip({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? kPurple : kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? kPurple : kBorder),
        ),
        child: Text(
          AIService.getTimeLabel(minutes),
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

// ─── Empty State Widget ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 20),
        Center(child: Text('😔', style: TextStyle(fontSize: 52))),
        SizedBox(height: 12),
        Center(
          child: Text(
            'No matches found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText),
          ),
        ),
        SizedBox(height: 4),
        Center(
          child: Text(
            'Try a different mood or time',
            style: TextStyle(fontSize: 13, color: kMuted),
          ),
        ),
      ],
    );
  }
}

// ─── AI MATCHER SCREEN ────────────────────────────────────────────────────────
class AiMatcherScreen extends StatefulWidget {
  const AiMatcherScreen({super.key});

  @override
  State<AiMatcherScreen> createState() => _AiMatcherScreenState();
}

class _AiMatcherScreenState extends State<AiMatcherScreen> {
  String _selectedMood = 'Hungry';
  int _selectedTime = 60;
  List<Map<String, dynamic>> _suggestions = [];
  String _reason = '';
  bool _loading = false;
  bool _searched = false;

  final Map<String, String> _moodIcons = {
    'Hungry': '😋',
    'Quick Bite': '⚡',
    'Treat': '🎉',
    'Healthy': '🥗',
    'Late Night': '🌙',
  };

  Future<void> _getSuggestions() async {
    setState(() {
      _loading = true;
      _searched = false;
    });

    final results = await AIService.getSuggestions(
      mood: _selectedMood,
      minutesBetweenClasses: _selectedTime,
    );

    final budget = await BudgetService.getWeeklyBudget();
    final spent = await BudgetService.getWeeklySpending();
    final remaining = budget - spent;

    final reason = AIService.getSuggestionReason(
      mood: _selectedMood,
      remainingBudget: remaining,
      minutesBetweenClasses: _selectedTime,
    );

    if (mounted) {
      setState(() {
        _suggestions = results;
        _reason = reason;
        _loading = false;
        _searched = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final moods = AIService.getAvailableMoods();
    final times = AIService.getAvailableTimeOptions();

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
          '✨ AI Matcher',
          style: TextStyle(color: kText, fontWeight: FontWeight.w800, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info Banner ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPurpleLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(children: [
                Text('🤖', style: TextStyle(fontSize: 28)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Tell me your mood and I'll find the best campus spots for you!",
                    style: TextStyle(
                      fontSize: 13,
                      color: kPurple,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Mood Selector ──
            const Text(
              "What's your mood?",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: moods.map((m) => _MoodChip(
                mood: m,
                icon: _moodIcons[m] ?? '🍽️',
                selected: _selectedMood == m,
                onTap: () => setState(() => _selectedMood = m),
              )).toList(),
            ),
            const SizedBox(height: 24),

            // ── Time Selector ──
            const Text(
              'Time between classes',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: times.map((t) => _TimeChip(
                minutes: t,
                selected: _selectedTime == t,
                onTap: () => setState(() => _selectedTime = t),
              )).toList(),
            ),
            const SizedBox(height: 24),

            // ── Find Match Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _loading ? null : _getSuggestions,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Find My Match ✨',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
              ),
            ),

            // ── Results ──
            if (_searched) ...[
              const SizedBox(height: 24),

              // Reason banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kPurpleLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _reason,
                  style: const TextStyle(
                    fontSize: 13,
                    color: kPurple,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                '${_suggestions.length} suggestions for you',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: kText,
                ),
              ),
              const SizedBox(height: 10),

              if (_suggestions.isEmpty)
                const _EmptyState()
              else
                ..._suggestions.map(
                  (r) => _SuggestionCard(restaurant: r),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
