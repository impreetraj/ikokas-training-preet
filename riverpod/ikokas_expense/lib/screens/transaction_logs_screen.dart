import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/transaction_log_model.dart';
import '../providers/transaction_provider.dart';

final transactionLogsProvider = FutureProvider.family<List<TransactionLogModel>, int?>((ref, transactionId) async {
  final logRepo = ref.watch(transactionLogRepositoryProvider);
  if (transactionId != null) {
    return await logRepo.getLogsForTransaction(transactionId);
  }
  return await logRepo.getAllLogs();
});

class TransactionLogsScreen extends ConsumerWidget {
  final int? transactionId;
  const TransactionLogsScreen({Key? key, this.transactionId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(transactionLogsProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(transactionId != null ? 'Transaction Logs' : 'Deleted Transactions'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: logsAsync.when(
        data: (logs) {
          if (logs.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => ref.refresh(transactionLogsProvider(transactionId).future),
              child: Stack(
                children: [
                  ListView(),
                  Center(child: Text(transactionId != null ? 'No logs available.' : 'No deleted transactions.')),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(transactionLogsProvider(transactionId).future),
            child: ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildLogCard(context, log);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, TransactionLogModel log) {
    Color getActionColor(String action) {
      switch (action) {
        case 'created':
          return Colors.green;
        case 'updated':
          return Colors.orange;
        case 'deleted':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    String getTitle(String? jsonString) {
      if (jsonString == null || jsonString.isEmpty) return 'Unknown';
      try {
        final map = jsonDecode(jsonString);
        return map['title'] ?? 'Unknown';
      } catch (_) {
        return 'Unknown';
      }
    }
    
    final title = log.action == 'deleted' ? getTitle(log.previousData) : getTitle(log.newData);
    final dateStr = DateFormat('MMM dd, yyyy - HH:mm').format(log.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getActionColor(log.action).withOpacity(0.2),
          child: Icon(
            log.action == 'created' ? Icons.add : log.action == 'updated' ? Icons.edit : Icons.delete,
            color: getActionColor(log.action),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${log.action.toUpperCase()}\n$dateStr'),
        isThreeLine: true,
        trailing: const Icon(Icons.info_outline),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  left: 24,
                  right: 24,
                  top: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Icon(
                          log.action == 'created' ? Icons.add_circle : log.action == 'updated' ? Icons.edit : Icons.cancel,
                          color: getActionColor(log.action),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Text('Log Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: getActionColor(log.action).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('ACTION: ${log.action.toUpperCase()}', style: TextStyle(fontWeight: FontWeight.bold, color: getActionColor(log.action), fontSize: 12, letterSpacing: 1.2)),
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time, size: 14, color: Colors.black54),
                          const SizedBox(width: 4),
                          Text(dateStr, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const Divider(height: 32),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (log.action == 'updated') 
                              _buildComparisonData(log.previousData, log.newData)
                            else ...[
                              _buildFormattedData(log.action == 'deleted' ? 'Deleted Data' : 'Previous Data', log.previousData),
                              _buildFormattedData(log.action == 'created' ? 'Created Data' : 'New Data', log.newData),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  Widget _buildFormattedData(String title, String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return const SizedBox.shrink();
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      map.removeWhere((k, v) => ['id', 'userId', 'paymentSlipPath'].contains(k));
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: map.entries.map((e) {
                String val = e.value?.toString() ?? 'None';
                if (e.key == 'date' && e.value != null) {
                  try {
                    val = DateFormat('MMM dd, yyyy - HH:mm').format(DateTime.parse(e.value.toString()));
                  } catch (_) {}
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: Text(e.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black45, fontSize: 12))),
                      Expanded(flex: 3, child: Text(val, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    } catch (_) {
      return Text(jsonStr);
    }
  }

  Widget _buildComparisonData(String? prevStr, String? newStr) {
    if (prevStr == null || newStr == null) return const SizedBox.shrink();
    try {
      final prevMap = jsonDecode(prevStr) as Map<String, dynamic>;
      final newMap = jsonDecode(newStr) as Map<String, dynamic>;
      
      final keys = newMap.keys.toList();
      keys.removeWhere((k) => ['id', 'userId', 'paymentSlipPath'].contains(k));
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Column(
              children: keys.map((key) {
                var prevVal = prevMap[key];
                var newVal = newMap[key];
                
                if (key == 'date') {
                  try {
                    if (prevVal != null) prevVal = DateFormat('MMM dd, yyyy').format(DateTime.parse(prevVal.toString()));
                    if (newVal != null) newVal = DateFormat('MMM dd, yyyy').format(DateTime.parse(newVal.toString()));
                  } catch (_) {}
                }
                
                bool changed = prevVal.toString() != newVal.toString();
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(flex: 2, child: Text(key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.black45, fontSize: 12))),
                      Expanded(flex: 4, child: changed 
                        ? Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('${prevVal ?? 'None'}', style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red, fontSize: 13)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.arrow_forward, size: 14, color: Colors.black45),
                              ),
                              Text('${newVal ?? 'None'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
                            ]
                          )
                        : Text('${newVal ?? 'None'}', style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500))
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    } catch (_) {
      return const Text('Error parsing changes');
    }
  }
}
