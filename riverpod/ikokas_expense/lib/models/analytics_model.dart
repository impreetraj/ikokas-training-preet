import 'transaction_model.dart';

class ChartData {
  ChartData(this.time, this.income, this.expense);
  final DateTime time;
  final double income;
  final double expense;
}

class AnalyticsData {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final Map<String, double> expensesByCategory;
  final Map<String, double> incomesByCategory;
  final List<TransactionModel> filteredTransactions;
  final List<ChartData> chartData;

  AnalyticsData({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.expensesByCategory,
    required this.incomesByCategory,
    required this.filteredTransactions,
    required this.chartData,
  });
}
