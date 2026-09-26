import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import 'transaction_detail_screen.dart';
import '../models/transaction_model.dart';
import '../widgets/transaction_card.dart';
import 'add_screen.dart';

enum HistoryFilter { day, month, year }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  HistoryFilter _filter = HistoryFilter.month; 

  Map<String, List<TransactionModel>> _groupTransactions(
    List<TransactionModel> transactions,
    HistoryFilter filter,
  ) {
    Map<String, List<TransactionModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var t in transactions) {
      String key;
      final tDate = DateTime(t.date.year, t.date.month, t.date.day);

      if (filter == HistoryFilter.day) {
        if (tDate == today) {
          key = 'TODAY';
        } else if (tDate == yesterday) {
          key = 'YESTERDAY';
        } else {
          key = DateFormat.yMMMd().format(t.date).toUpperCase();
        }
      } else if (filter == HistoryFilter.month) {
        if (t.date.year == now.year && t.date.month == now.month) {
          key = 'THIS MONTH';
        } else {
          key = DateFormat.yMMMM().format(t.date).toUpperCase();
        }
      } else {
        if (t.date.year == now.year) {
          key = 'THIS YEAR';
        } else {
          key = DateFormat.y().format(t.date).toUpperCase();
        }
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(t);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionProvider);
    final user = ref.watch(authProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8F9FA),
          elevation: 0,

          title: const Text(
            "MoneyMate",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Column(
              children: [
                // Filter Pills
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      _buildFilterPill('Day', HistoryFilter.day),
                      const SizedBox(width: 8),
                      _buildFilterPill('Month', HistoryFilter.month),
                      const SizedBox(width: 8),
                      _buildFilterPill('Year', HistoryFilter.year),
                    ],
                  ),
                ),
                // Tabs
                const TabBar(
                  labelColor: Colors.teal,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.teal,
                  tabs: [
                    Tab(text: 'My Debit'),
                    Tab(text: 'Shared Debit'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: transactionsState.when(
          data: (transactions) {
            // Sort by date descending
            final sorted = List<TransactionModel>.from(transactions)
              ..sort((a, b) => b.date.compareTo(a.date));
            final myTransactions = sorted.where((t) => !t.isShared).toList();
            final sharedTransactions = sorted.where((t) => t.isShared).toList();

            final groupedMy = _groupTransactions(myTransactions, _filter);
            final groupedShared = _groupTransactions(
              sharedTransactions,
              _filter,
            );

            return TabBarView(
              children: [
                _buildTransactionList(groupedMy),
                _buildTransactionList(groupedShared),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildFilterPill(String label, HistoryFilter filterValue) {
    final isSelected = _filter == filterValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filter = filterValue;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.teal : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(
    Map<String, List<TransactionModel>> groupedData,
  ) {
    if (groupedData.isEmpty) {
      return const Center(child: Text('No transactions found.'));
    }

    final keys = groupedData.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final items = groupedData[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
              child: Text(
                key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            ...items.map(
              (t) => TransactionCard(
                transaction: t,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TransactionDetailScreen(transaction: t),
                    ),
                  );
                },
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpenseScreen(transaction: t),
                    ),
                  );
                },
                onDelete: () {
                  if (t.id != null) {
                    ref
                        .read(transactionProvider.notifier)
                        .deleteTransaction(t.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Transaction deleted!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
