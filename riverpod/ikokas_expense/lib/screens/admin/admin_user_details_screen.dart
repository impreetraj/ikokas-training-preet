import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/transaction_model.dart';
import '../../providers/transaction_provider.dart';

final adminUserTransactionsProvider = FutureProvider.autoDispose.family<List<TransactionModel>, String>((ref, userId) async {
  final repo = ref.watch(transactionRepositoryProvider);
  return repo.getAllTransactions(userId);
});

class AdminUserDetailsScreen extends ConsumerWidget {
  final UserModel targetUser;
  
  const AdminUserDetailsScreen({Key? key, required this.targetUser}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(adminUserTransactionsProvider(targetUser.uid));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
       
        title: const Text('MoneyMate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: transactionsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (transactions) {
          
          double totalCredit = 0;
          double totalDebit = 0;
          
          for (var tx in transactions) {
            if (tx.type == 'Expense') {
              totalDebit += tx.amount;
            } else {
              totalCredit += tx.amount;
            }
          }
          
          double totalBalance = totalCredit - totalDebit;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOTAL BALANCE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D62),
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOTAL BALANCE',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0, end: totalBalance),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Text(
                            '₹${value.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_downward, color: Colors.lightGreenAccent, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Credit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: totalCredit),
                                    duration: const Duration(seconds: 2),
                                    builder: (context, value, child) {
                                      return Text('₹${value.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.arrow_upward, color: Colors.redAccent, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Debit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween<double>(begin: 0, end: totalDebit),
                                    duration: const Duration(seconds: 2),
                                    builder: (context, value, child) {
                                      return Text('₹${value.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
                                    },
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Text(
                  'Recent Transactions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                
                const SizedBox(height: 16),
                
                if (transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: Center(child: Text('No transactions found for this user.')),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      final isExpense = tx.type == 'Expense';
                      
                      return Dismissible(
                        key: Key(tx.id.toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(16)
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) async {
                          await ref.read(transactionRepositoryProvider).delete(tx.id!);
                          ref.invalidate(adminUserTransactionsProvider(targetUser.uid));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${tx.title} deleted')),
                            );
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))
                            ]
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isExpense ? Colors.red.shade50 : Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12)
                                ),
                                child: Icon(
                                  isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: isExpense ? Colors.red : Colors.green,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('${tx.category} • ${DateFormat('MMM d, yyyy').format(tx.date)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                  ],
                                ),
                              ),
                              Text(
                                '${isExpense ? '' : '+'}₹${tx.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isExpense ? Colors.black87 : Colors.green.shade700,
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )
              ],
            ),
          );
        },
      ),
    );
  }
}
