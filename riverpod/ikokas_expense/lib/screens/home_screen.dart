import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ikokas_expense/screens/history_screen.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/analytics_provider.dart';
import 'transaction_detail_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';
import 'add_screen.dart';

import 'analytics_screen.dart';
import 'profile_screen.dart';
import '../models/transaction_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  int _myDebitLimit = 10;
  int _sharedDebitLimit = 10;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showShareDialog(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
    String currentUserName,
  ) async {
    final authNotif = ref.read(authProvider.notifier);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    
    final otherUsers = await authNotif.getAllOtherUsers();
    
    if (context.mounted) Navigator.pop(context); // close loading

    if (otherUsers.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other users found on this device.')),
        );
      }
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Share Debit'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: otherUsers.length,
              itemBuilder: (context, index) {
                final targetUser = otherUsers[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(targetUser.name[0].toUpperCase()),
                  ),
                  title: Text(targetUser.name),
                  subtitle: Text(targetUser.email),
                  onTap: () {
                    ref
                        .read(transactionProvider.notifier)
                        .shareTransaction(
                          transaction,
                          targetUser.uid,
                          currentUserName,
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Debit shared with ${targetUser.name}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionProvider);
    final user = ref.watch(authProvider);
    final formatter = NumberFormat.currency(symbol: '₹');
    final isSharedTab = _tabController.index == 1;

    return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: transactionsState.when(
          data: (transactions) {
            final myTransactions = transactions
                .where((t) => !t.isShared)
                .toList();
            final sharedTransactions = transactions
                .where((t) => t.isShared)
                .toList();

            final paginatedMyTransactions = myTransactions.take(_myDebitLimit).toList();
            final paginatedSharedTransactions = sharedTransactions.take(_sharedDebitLimit).toList();

            double totalIncome = 0;
            double totalExpense = 0;
            double thisMonthExpense = 0;
            final now = DateTime.now();

            final currentTransactions = isSharedTab ? sharedTransactions : myTransactions;

            for (var t in currentTransactions) {
              if (t.type == 'Income') {
                totalIncome += t.amount;
              } else {
                totalExpense += t.amount;
                if (t.date.year == now.year && t.date.month == now.month) {
                  thisMonthExpense += t.amount;
                }
              }
            }
            final weeklyAvg = thisMonthExpense / 4;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: const Color(0xFFF8F9FA),
                    elevation: 0,
                    pinned: true,
                    leading: user != null
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileScreen(),
                                  ),
                                );
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.teal,
                                child: Text(
                                  user.name.isNotEmpty
                                      ? user.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : null,
                    title: const Text(
                      "MoneyMate",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SummaryCard(income: totalIncome, expense: totalExpense),
                        if (!isSharedTab) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            'Overview',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      const Text(
                                        'THIS MONTH',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatter.format(thisMonthExpense),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: 0.6,
                                        backgroundColor: Colors.grey.shade200,
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      const Text(
                                        'WEEKLY AVG',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatter.format(weeklyAvg),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: 0.4,
                                        backgroundColor: Colors.grey.shade200,
                                        color: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HistoryScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'SEE ALL',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ],
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.teal,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.teal,
                        tabs: const [
                          Tab(text: 'My Debit'),
                          Tab(text: 'Shared Debit'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  myTransactions.isEmpty
                      ? const Center(
                          child: Text('No transactions yet. Add some!'),
                        )
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo is ScrollUpdateNotification &&
                                scrollInfo.metrics.maxScrollExtent > 0 &&
                                scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
                              if (_myDebitLimit < myTransactions.length) {
                                setState(() {
                                  _myDebitLimit += 10;
                                });
                              }
                            }
                            return false;
                          },
                          child: Container(
                            color: const Color(0xFFF8F9FA),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 8, bottom: 24),
                              itemCount: paginatedMyTransactions.length + (myTransactions.length > _myDebitLimit ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == paginatedMyTransactions.length) {
                                  return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                                }
                                final transaction = paginatedMyTransactions[index];
                              return TransactionCard(
                                transaction: transaction,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailScreen(
                                            transaction: transaction,
                                          ),
                                    ),
                                  );
                                },
                                onShare: () => _showShareDialog(
                                  context,
                                  ref,
                                  transaction,
                                  user?.name ?? 'Unknown',
                                ),
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddExpenseScreen(
                                        transaction: transaction,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  if (transaction.id != null) {
                                    ref
                                        .read(transactionProvider.notifier)
                                        .deleteTransaction(transaction.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Transaction deleted!'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        ),
                  sharedTransactions.isEmpty
                      ? const Center(child: Text('No shared expenses.'))
                      : NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification scrollInfo) {
                            if (scrollInfo is ScrollUpdateNotification &&
                                scrollInfo.metrics.maxScrollExtent > 0 &&
                                scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 50) {
                              if (_sharedDebitLimit < sharedTransactions.length) {
                                setState(() {
                                  _sharedDebitLimit += 10;
                                });
                              }
                            }
                            return false;
                          },
                          child: Container(
                            color: const Color(0xFFF8F9FA),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 8, bottom: 24),
                              itemCount: paginatedSharedTransactions.length + (sharedTransactions.length > _sharedDebitLimit ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == paginatedSharedTransactions.length) {
                                  return const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()));
                                }
                                final transaction = paginatedSharedTransactions[index];
                              return TransactionCard(
                                transaction: transaction,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailScreen(
                                            transaction: transaction,
                                          ),
                                    ),
                                  );
                                },
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddExpenseScreen(
                                        transaction: transaction,
                                      ),
                                    ),
                                  );
                                },
                                onDelete: () {
                                  if (transaction.id != null) {
                                    ref
                                        .read(transactionProvider.notifier)
                                        .deleteTransaction(transaction.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Transaction deleted!'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFF8F9FA), child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
