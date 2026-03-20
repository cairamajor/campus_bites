import 'package:flutter/material.dart';
import '../services/budget_service.dart';
import '../screens/theme.dart';



// ─── Emoji Box Widget ─────────────────────────────────────────────────────────
class _EmojiBox extends StatelessWidget {
  final String emoji;
  final Color bg;

  const _EmojiBox(this.emoji, {this.bg = kGreenLight});

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

// ─── Empty State Widget ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 20),
        Center(child: Text('📋', style: TextStyle(fontSize: 52))),
        SizedBox(height: 12),
        Center(
          child: Text(
            'No expenses yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kText),
          ),
        ),
        SizedBox(height: 4),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Log meals from restaurant pages to track spending',
              style: TextStyle(fontSize: 13, color: kMuted),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Expense Card Widget ──────────────────────────────────────────────────────
class _ExpenseCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.entry,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
        const _EmojiBox('🍽️'),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              entry['meal_name'] ?? '',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kText),
            ),
            Text(
              entry['category'] ?? '',
              style: const TextStyle(fontSize: 12, color: kMuted),
            ),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(
            '-\$${(entry['amount'] as double? ?? 0).toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kPink),
          ),
          Text(
            entry['date'] ?? '',
            style: const TextStyle(fontSize: 11, color: kMuted),
          ),
        ]),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onDelete,
          child: const Icon(Icons.delete_outline_rounded, color: kMuted, size: 20),
        ),
      ]),
    );
  }
}

// ─── Budget Summary Card Widget ───────────────────────────────────────────────
class _BudgetSummaryCard extends StatelessWidget {
  final double budget;
  final double spent;
  final double left;
  final double pct;
  final bool isOver;

  const _BudgetSummaryCard({
    required this.budget,
    required this.spent,
    required this.left,
    required this.pct,
    required this.isOver,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOver
              ? [kPink, const Color(0xFFFF7089)]
              : [kAccent, const Color(0xFFFF9A5C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isOver ? kPink : kAccent).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isOver ? '⚠️ Over Budget' : '💵 This Week\'s Budget',
            style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            isOver
                ? '-\$${(spent - budget).toStringAsFixed(2)}'
                : '\$${left.toStringAsFixed(2)} left',
            style: const TextStyle(
              fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: \$${spent.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              Text(
                'Budget: \$${budget.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── BUDGET SCREEN ────────────────────────────────────────────────────────────
class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  double _budget = 50.0;
  double _spent = 0.0;
  List<Map<String, dynamic>> _entries = [];
  bool _loading = true;
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
    setState(() => _loading = true);
    final budget = await BudgetService.getWeeklyBudget();
    final spent = await BudgetService.getWeeklySpending();
    final entries = await BudgetService.getWeeklyExpenses();
    if (mounted) {
      setState(() {
        _budget = budget;
        _spent = spent;
        _entries = entries;
        _budgetCtrl.text = budget.toStringAsFixed(0);
        _loading = false;
      });
    }
  }

  Future<void> _updateBudget() async {
    final val = double.tryParse(_budgetCtrl.text);
    if (val != null && val > 0) {
      await BudgetService.updateWeeklyBudget(val);
      _load();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget updated! 💰'),
          backgroundColor: kGreen,
        ),
      );
    }
  }

  Future<void> _deleteExpense(int id) async {
    await BudgetService.deleteExpense(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final left = (_budget - _spent).clamp(0.0, _budget);
    final pct = (_budget > 0) ? (_spent / _budget).clamp(0.0, 1.0) : 0.0;
    final isOver = _spent > _budget;

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        color: kAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              const Text(
                '💰 Budget Tracker',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kText),
              ),
              const SizedBox(height: 16),

              // ── Budget Summary Card ──
              _BudgetSummaryCard(
                budget: _budget,
                spent: _spent,
                left: left,
                pct: pct,
                isOver: isOver,
              ),
              const SizedBox(height: 16),

              // ── Set Budget Input ──
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCard,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set Weekly Budget',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kText),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _budgetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        hintText: 'Enter amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: kBorder),
                        ),
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
                        onPressed: _updateBudget,
                        child: const Text(
                          'Update Budget',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Expense List ──
              Text(
                'This Week\'s Expenses (${_entries.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText),
              ),
              const SizedBox(height: 12),

              if (_loading)
                const Center(child: CircularProgressIndicator(color: kAccent))
              else if (_entries.isEmpty)
                const _EmptyState()
              else
                ..._entries.map(
                  (e) => _ExpenseCard(
                    entry: e,
                    onDelete: () => _deleteExpense(e['id'] as int),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
