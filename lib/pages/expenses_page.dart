import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarefas/components/monthly_chart.dart';
import 'package:tarefas/components/transaction_item.dart';
import 'package:tarefas/models/transaction_list.dart';
import 'package:tarefas/utils/num_transform.dart';

import '../components/chart.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: Provider.of<TransactionList>(context, listen: false)
                .loadTransactions(),
            builder: (ctx, snapshot) => snapshot.connectionState ==
                    ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Consumer<TransactionList>(
                    builder: (ctx, transactionList, _) {
                      return transactionList.itensCount == 0
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Nenhuma despesa cadastrada'),
                                SizedBox(height: 20),
                                SizedBox(
                                    width: double.infinity,
                                    child: Icon(
                                      Icons.money_off_outlined,
                                      size: 78,
                                    ))
                              ],
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: 240,
                                  child: PageView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        Chart(
                                            recentsTransactions: transactionList
                                                .recentsTransactions(7)),
                                        MonthlyChart(
                                            monthlyTransactions: transactionList
                                                .recentsTransactions(32))
                                      ]),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: transactionList.itensCount,
                                    itemBuilder: (ctx, i) => Column(
                                      children: [
                                        TransactionItem(
                                            transaction: transactionList
                                                .transactions[i]),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  child: Text(
                                      'Total gasto na semana R\$${NumTranform.formatValue(transactionList.weekTotalValue(7))} e no mês R\$${NumTranform.formatValue(transactionList.weekTotalValue(31))}'),
                                )
                              ],
                            );
                    },
                  )));
  }
}
