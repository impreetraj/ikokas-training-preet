import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transaction_model.dart';
import 'transaction_provider.dart';
import '../models/analytics_model.dart';
export '../models/analytics_model.dart';

enum AnalyticsFilter { day, month, year }

final analyticsFilterProvider = StateProvider<AnalyticsFilter>((ref) => AnalyticsFilter.month);
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class _DailyData {
  double income;
  double expense;
  _DailyData(this.income, this.expense);
}

final analyticsDataProvider = Provider<AsyncValue<AnalyticsData>>((ref) {
  final transactionsState = ref.watch(transactionProvider);
  final filter = ref.watch(analyticsFilterProvider);
  final selectedDate = ref.watch(selectedDateProvider);

  return transactionsState.whenData((transactions) {
    
    final filtered = transactions.where((t) {
      if (filter == AnalyticsFilter.day) {
        return t.date.year == selectedDate.year && t.date.month == selectedDate.month && t.date.day == selectedDate.day;
      } else if (filter == AnalyticsFilter.month) {
        return t.date.year == selectedDate.year && t.date.month == selectedDate.month;
      } else {
        return t.date.year == selectedDate.year;
      }
    }).toList();

    double income = 0;
    double expense = 0;
    Map<String, double> expensesByCategory = {};
    Map<String, double> incomesByCategory = {};
    Map<DateTime, _DailyData> aggregatedChartData = {};

    for (var t in filtered) {
      if (t.type.toLowerCase() == 'income') {
        income += t.amount;
        incomesByCategory[t.category] = (incomesByCategory[t.category] ?? 0) + t.amount;
      } else {
        expense += t.amount;
        expensesByCategory[t.category] = (expensesByCategory[t.category] ?? 0) + t.amount;
      }
      
      DateTime key;
      if (filter == AnalyticsFilter.day) {
        key = t.date;
      } else if (filter == AnalyticsFilter.month) {
        key = DateTime(t.date.year, t.date.month, t.date.day);
      } else {
        key = DateTime(t.date.year, t.date.month, 1);
      }

      if (!aggregatedChartData.containsKey(key)) {
        aggregatedChartData[key] = _DailyData(0, 0);
      }
      if (t.type.toLowerCase() == 'income') {
        aggregatedChartData[key]!.income += t.amount;
      } else {
        aggregatedChartData[key]!.expense += t.amount;
      }
    }
    
    List<ChartData> chartDataList = aggregatedChartData.entries
        .map((e) => ChartData(e.key, e.value.income, e.value.expense))
        .toList();
    chartDataList.sort((a, b) => a.time.compareTo(b.time));

    return AnalyticsData(
      totalIncome: income,
      totalExpense: expense,
      balance: income - expense,
      expensesByCategory: expensesByCategory,
      incomesByCategory: incomesByCategory,
      filteredTransactions: filtered,
      chartData: chartDataList,
    );
  });
});
