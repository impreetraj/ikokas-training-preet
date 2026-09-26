import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../providers/analytics_provider.dart';
import '../providers/auth_provider.dart';

enum TransactionViewType { expense, income }

final transactionViewTypeProvider = StateProvider<TransactionViewType>((ref) => TransactionViewType.expense);
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsState = ref.watch(analyticsDataProvider);
    final filter = ref.watch(analyticsFilterProvider);
    final viewType = ref.watch(transactionViewTypeProvider);
    final user = ref.watch(authProvider);
    final formatter = NumberFormat.currency(symbol: '₹');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
       
        
        title: const Text(
          "MoneyMate",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Review your spending patterns',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
           
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildFilterTab(context, ref, 'Daily', AnalyticsFilter.day, filter),
                  _buildFilterTab(context, ref, 'Monthly', AnalyticsFilter.month, filter),
                  _buildFilterTab(context, ref, 'Yearly', AnalyticsFilter.year, filter),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildTypeTab(context, ref, 'Debit', TransactionViewType.expense, viewType),
                  _buildTypeTab(context, ref, 'Credit', TransactionViewType.income, viewType),
                ],
              ),
            ),
            const SizedBox(height: 24),

            analyticsState.when(
              data: (data) {
                return _buildDashboardContent(context, ref, data, filter, viewType, formatter);
              },
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator())),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(BuildContext context, WidgetRef ref, String label, AnalyticsFilter value, AnalyticsFilter current) {
    final isSelected = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(analyticsFilterProvider.notifier).state = value;
          ref.read(selectedCategoryProvider.notifier).state = null;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTab(BuildContext context, WidgetRef ref, String label, TransactionViewType value, TransactionViewType current) {
    final isSelected = current == value;
    final color = value == TransactionViewType.expense ? Colors.red : Colors.green;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(transactionViewTypeProvider.notifier).state = value;
          ref.read(selectedCategoryProvider.notifier).state = null;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, WidgetRef ref, AnalyticsData data, AnalyticsFilter filter, TransactionViewType viewType, NumberFormat formatter) {
    final isIncome = viewType == TransactionViewType.income;
    final categoriesMap = isIncome ? data.incomesByCategory : data.expensesByCategory;
    final totalAmount = isIncome ? data.totalIncome : data.totalExpense;
    final selectedCategory = ref.watch(selectedCategoryProvider);

    List<ChartData> chartData = data.chartData;
    if (selectedCategory != null) {
      Map<DateTime, List<double>> aggregated = {};
      for (var t in data.filteredTransactions) {
        if (t.category != selectedCategory) continue;
        
        DateTime key;
        if (filter == AnalyticsFilter.day) {
          key = t.date;
        } else if (filter == AnalyticsFilter.month) {
          key = DateTime(t.date.year, t.date.month, t.date.day);
        } else {
          key = DateTime(t.date.year, t.date.month, 1);
        }
        
        if (!aggregated.containsKey(key)) {
          aggregated[key] = [0.0, 0.0];
        }
        if (t.type.toLowerCase() == 'income') {
          aggregated[key]![0] += t.amount;
        } else {
          aggregated[key]![1] += t.amount;
        }
      }
      chartData = aggregated.entries
          .map((e) => ChartData(e.key, e.value[0], e.value[1]))
          .toList();
      chartData.sort((a, b) => a.time.compareTo(b.time));
    }

  
    String topCategory = 'None';
    double topCategoryAmount = 0;
    if (categoriesMap.isNotEmpty) {
      final sortedEntries = categoriesMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sortedEntries.first.key;
      topCategoryAmount = sortedEntries.first.value;
    }
    
    double topCategoryPercentage = 0;
    if (totalAmount > 0) {
      topCategoryPercentage = topCategoryAmount / totalAmount;
    }

    String dateLabel = DateFormat.yMMMM().format(DateTime.now());
    if (filter == AnalyticsFilter.day) {
      dateLabel = DateFormat.yMMMd().format(DateTime.now());
    } else if (filter == AnalyticsFilter.year) {
      dateLabel = DateFormat.y().format(DateTime.now());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isIncome ? 'TOTAL CREDIT' : 'TOTAL DEBIT', style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formatter.format(totalAmount),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(dateLabel, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Top Category Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isIncome 
                ? [const Color(0xFF059669), const Color(0xFF10B981)] 
                : [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isIncome ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3), 
                blurRadius: 15, offset: const Offset(0, 8)
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(isIncome ? Icons.account_balance_wallet : Icons.restaurant, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(isIncome ? 'TOP SOURCE' : 'TOP CATEGORY', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                ],
              ),
              const SizedBox(height: 16),
              Text(topCategory, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(formatter.format(topCategoryAmount), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
             
           
              LinearProgressIndicator(
                value: topCategoryPercentage,
                backgroundColor: Colors.white.withOpacity(0.2),
                color: Colors.white,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

       
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
           
                  Text(isIncome ? 'Credit Trends' : 'Debit Trends', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
               
               
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: _buildSplineChart(
                  chartData.where((d) => isIncome ? d.income > 0 : d.expense > 0).toList(), 
                  filter,
                  viewType
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        
        if (categoriesMap.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Category Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 20),
                ...categoriesMap.entries.map((e) {
                  double perc = totalAmount > 0 ? e.value / totalAmount : 0;
                  return _buildCategoryItem(ref, e.key, e.value, perc, formatter, selectedCategory);
                }).toList(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSplineChart(List<ChartData> chartData, AnalyticsFilter filter, TransactionViewType viewType) {
    if (chartData.isEmpty) {
      return const Center(child: Text('No trend data available.', style: TextStyle(color: Colors.grey)));
    }
    
    final isIncome = viewType == TransactionViewType.income;
    final color = isIncome ? Colors.green : Colors.blue;

    DateTime? minDate;
    DateTime? maxDate;
    if (filter == AnalyticsFilter.day && chartData.isNotEmpty) {
      minDate = chartData.first.time;
      maxDate = chartData.last.time;
      
      
      if (minDate.isAtSameMomentAs(maxDate)) {
        minDate = minDate.subtract(const Duration(hours: 1));
        maxDate = maxDate.add(const Duration(hours: 1));
      }
    }

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        minimum: minDate,
        maximum: maxDate,
        dateFormat: filter == AnalyticsFilter.day 
            ? DateFormat('ha') 
            : (filter == AnalyticsFilter.month ? DateFormat.Md() : DateFormat.yMMM()),
        intervalType: filter == AnalyticsFilter.day 
            ? DateTimeIntervalType.hours 
            : (filter == AnalyticsFilter.month ? DateTimeIntervalType.days : DateTimeIntervalType.months),
        interval: filter == AnalyticsFilter.day 
            ? (maxDate != null && minDate != null && maxDate.difference(minDate).inHours >= 4 ? 4 : null) 
            : null,
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, DateTime>>[
        LineSeries<ChartData, DateTime>(
          name: isIncome ? 'Credit' : 'Debit',
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => isIncome ? data.income : data.expense,
          color: color,
          width: 3,
          markerSettings: MarkerSettings(
            isVisible: true,
            color: Colors.white,
            borderColor: color,
            borderWidth: 2,
          ),
        )
      ],
    );
  }

  Widget _buildCategoryItem(WidgetRef ref, String name, double amount, double percentage, NumberFormat formatter, String? selectedCategory) {
    final isSelected = name == selectedCategory;
    IconData icon = Icons.category;
    Color iconColor = Colors.blue;
    if (name.toLowerCase().contains('food') || name.toLowerCase().contains('dining') || name.toLowerCase().contains('grocer')) {
      icon = Icons.restaurant;
      iconColor = Colors.blue;
    } else if (name.toLowerCase().contains('transport')) {
      icon = Icons.directions_car;
      iconColor = Colors.green;
    } else if (name.toLowerCase().contains('shopping')) {
      icon = Icons.shopping_bag;
      iconColor = Colors.purple;
    } else {
      iconColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () {
        ref.read(selectedCategoryProvider.notifier).update((state) => state == name ? null : name);
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: isSelected ? iconColor.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: iconColor.withOpacity(0.5)) : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                    Text(formatter.format(amount), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.shade200,
                  color: iconColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
