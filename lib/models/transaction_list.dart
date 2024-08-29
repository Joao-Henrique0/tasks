import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tarefas/utils/db_util.dart';
import 'transaction.dart';

class TransactionList with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions {
    return [..._transactions.reversed];
  }

  int get itensCount {
    return _transactions.length;
  }

  Future<void> loadTransactions() async {
    final dataList = await DbUtil.getData('transactions');
    _transactions = dataList
        .map(
          (item) => Transaction(
            id: item['id'],
            title: item['title'],
            value: item['value'],
            date: DateTime.parse(item['date']),
          ),
        )
        .toList();

    // Filtrar e remover transações com mais de 32 dias
    _transactions.removeWhere((transaction) {
      if (transaction.date
          .isBefore(DateTime.now().subtract(const Duration(days: 32)))) {
        removeTransaction(transaction); // Remove do banco de dados
        return true;
      }
      return false;
    });

    notifyListeners();
  }

  Transaction itemByIndex(int index) {
    return _transactions[index];
  }

  Future<void> saveTransaction(Map<String, Object> data) async {
    bool hasId = data['id'] != null;
    final transaction = Transaction(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      title: data['title'] as String,
      value: data['value'] as double,
      date: data['date'] as DateTime,
    );

    if (hasId) {
      await updateTransaction(transaction);
    } else {
      await addTransaction(transaction);
    }
  }

  Future<void> updateTransaction(Transaction transaction) async {
    int index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index >= 0) {
      _transactions[index] = transaction;
      notifyListeners();
      await DbUtil.updateData('transactions', {
        'id': transaction.id,
        'title': transaction.title,
        'value': transaction.value,
        'date': transaction.date.toIso8601String(),
      });
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DbUtil.insertData('transactions', {
      'id': transaction.id,
      'title': transaction.title,
      'value': transaction.value,
      'date': transaction.date.toIso8601String(),
    });
    _transactions.add(transaction);
    notifyListeners();
  }

  Future<void> removeTransaction(Transaction transaction) async {
    int index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index >= 0) {
      _transactions.removeAt(index);
      notifyListeners();
      await DbUtil.deleteData('transactions', transaction.id);
    }
  }

  List<Transaction> recentsTransactions(int days) {
    final transactions = _transactions;
    return transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(Duration(days: days)));
    }).toList();
  }

  double _weekTotalValue(int days) {
  // Filtrar as transações que ocorreram na última semana
  final recentTransactions = _transactions.where((tr) {
    return tr.date.isAfter(
      DateTime.now().subtract(Duration(days: days)),
    );
  }).toList();

  // Somar os valores das transações recentes
  return recentTransactions.fold(0.0, (sum, tr) {
    return sum + tr.value;
  });
}

double weekTotalValue(int days) {
  return _weekTotalValue(days);
}
}
