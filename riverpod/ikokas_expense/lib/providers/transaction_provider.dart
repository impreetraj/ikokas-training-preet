import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/transaction_model.dart';
import '../models/transaction_log_model.dart';
import '../data/transaction_repository.dart';
import '../data/transaction_log_repository.dart';
import 'auth_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionLogRepositoryProvider = Provider<TransactionLogRepository>((ref) {
  return TransactionLogRepository();
});

final transactionLogsProvider = FutureProvider.autoDispose.family<List<TransactionLogModel>, int?>((ref, transactionId) async {
  final logRepo = ref.watch(transactionLogRepositoryProvider);
  if (transactionId != null) {
    return await logRepo.getLogsForTransaction(transactionId);
  }
  final allLogs = await logRepo.getAllLogs();
  return allLogs.where((log) => log.action == 'deleted').toList();
});

final transactionProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<TransactionModel>>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final logRepository = ref.watch(transactionLogRepositoryProvider);
  final user = ref.watch(authProvider);
  return TransactionNotifier(ref, repository, logRepository, user?.uid);
});

class TransactionNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  final Ref _ref;
  final TransactionRepository _repository;
  final TransactionLogRepository _logRepository;
  final String? _userId;

  TransactionNotifier(this._ref, this._repository, this._logRepository, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadTransactions();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadTransactions() async {
    if (_userId == null) return;
    try {
      state = const AsyncValue.loading();
      final transactions = await _repository.getAllTransactions(_userId!);
      state = AsyncValue.data(transactions);
      
      verifyAndGenerateMissingLogs();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    if (_userId == null) return;
    try {
      final transactionWithUser = transaction.copyWith(userId: _userId);
      final newTransaction = await _repository.insert(transactionWithUser);
      
      try {
        await _logRepository.insertLog(TransactionLogModel(
          transactionId: newTransaction.id!,
          action: 'created',
          newData: jsonEncode(newTransaction.toMap()),
          timestamp: DateTime.now(),
          logStatus: 'success',
        ));
        _ref.invalidate(transactionLogsProvider);
      } catch (e) {
        
      }

      if (state is AsyncData) {
        final currentList = state.value!;
        state = AsyncValue.data([newTransaction, ...currentList]);
      } else {
        await loadTransactions();
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> shareTransaction(TransactionModel transaction, String targetUserId, String currentUserName) async {
    try {
      final map = transaction.toMap();
      map.remove('id'); 
      map['userId'] = targetUserId;
      map['isShared'] = 1;
      map['sharedBy'] = currentUserName;
      
      final sharedTransaction = TransactionModel.fromMap(map);
      final newSharedTransaction = await _repository.insert(sharedTransaction);
      
      try {
        await _logRepository.insertLog(TransactionLogModel(
          transactionId: newSharedTransaction.id!,
          action: 'created',
          newData: jsonEncode(newSharedTransaction.toMap()),
          timestamp: DateTime.now(),
          logStatus: 'success',
        ));
        _ref.invalidate(transactionLogsProvider);
      } catch (e) {
        
      }
    
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      String? previousDataJson;
      if (state is AsyncData) {
        final currentList = state.value!;
        try {
          final oldTransaction = currentList.firstWhere((t) => t.id == transaction.id);
          previousDataJson = jsonEncode(oldTransaction.toMap());
        } catch (_) {}
      }

      await _repository.update(transaction);
      
      try {
        await _logRepository.insertLog(TransactionLogModel(
          transactionId: transaction.id!,
          action: 'updated',
          previousData: previousDataJson,
          newData: jsonEncode(transaction.toMap()),
          timestamp: DateTime.now(),
          logStatus: 'success',
        ));
        _ref.invalidate(transactionLogsProvider);
      } catch (e) {
        
      }

      if (state is AsyncData) {
        final currentList = state.value!;
        final index = currentList.indexWhere((t) => t.id == transaction.id);
        if (index != -1) {
          final newList = List<TransactionModel>.from(currentList);
          newList[index] = transaction;

          newList.sort((a, b) => b.date.compareTo(a.date));
          state = AsyncValue.data(newList);
        }
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      String? previousDataJson;
      if (state is AsyncData) {
        final currentList = state.value!;
        try {
          final oldTransaction = currentList.firstWhere((t) => t.id == id);
          previousDataJson = jsonEncode(oldTransaction.toMap());
        } catch (_) {}
      }

      await _repository.delete(id);

      try {
        await _logRepository.insertLog(TransactionLogModel(
          transactionId: id,
          action: 'deleted',
          previousData: previousDataJson,
          timestamp: DateTime.now(),
          logStatus: 'success',
        ));
        _ref.invalidate(transactionLogsProvider);
      } catch (e) {
        
      }

      if (state is AsyncData) {
        final currentList = state.value!;
        state = AsyncValue.data(currentList.where((t) => t.id != id).toList());
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> verifyAndGenerateMissingLogs() async {
    if (_userId == null) return;
    try {
      final transactions = await _repository.getAllTransactions(_userId!);
      final allLogs = await _logRepository.getAllLogs();
      
      final logsByTransactionId = <int, List<TransactionLogModel>>{};
      for (final log in allLogs) {
        if (!logsByTransactionId.containsKey(log.transactionId)) {
          logsByTransactionId[log.transactionId] = [];
        }
        logsByTransactionId[log.transactionId]!.add(log);
      }
      
      for (final t in transactions) {
        if (t.id == null) continue;
        final tLogs = logsByTransactionId[t.id!] ?? [];
        final hasCreatedLog = tLogs.any((l) => l.action == 'created');
        
        if (!hasCreatedLog) {
          await _logRepository.insertLog(TransactionLogModel(
            transactionId: t.id!,
            action: 'created',
            newData: jsonEncode(t.toMap()),
            timestamp: t.date, 
            logStatus: 'success',
          ));
        }
      }
    } catch (e) {
      
    }
  }
}
