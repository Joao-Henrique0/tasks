import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tarefas/utils/num_transform.dart';
import '../models/transaction.dart';

class MonthlyChart extends StatelessWidget {
  final List<Transaction> monthlyTransactions;

  const MonthlyChart({super.key, required this.monthlyTransactions});

  List<Map<String, Object>> get groupedTransactions {
    return List.generate(32, (index) {
      final day = DateTime.now().subtract(Duration(days: index));

      double totalSum = 0.0;

      for (var i = 0; i < monthlyTransactions.length; i++) {
        if (monthlyTransactions[i].date.day == day.day &&
            monthlyTransactions[i].date.month == day.month &&
            monthlyTransactions[i].date.year == day.year) {
          totalSum += monthlyTransactions[i].value;
        }
      }

      return {
        'day': DateFormat.d().format(day), // Formata o dia como número
        'value': totalSum
      };
    }).reversed.toList(); // Reverte para começar do início do mês
  }

  double get monthMaxValue {
    return groupedTransactions.fold(0.0, (max, tr) {
      return max > (tr['value'] as double) ? max : (tr['value'] as double);
    });
  }

  Color getDayColor(double value, double maxValue, BuildContext context) {
    if (maxValue == 0) {
      return Colors.grey.shade300; // Cor padrão para evitar divisão por zero
    }

    final colorIntensity = value / maxValue;
    return Color.lerp(Colors.grey.shade300,
        Theme.of(context).colorScheme.secondary, colorIntensity)!;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.tertiary,
      elevation: 6,
      margin: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 5 * 40, // Altura máxima para 5 fileiras de 40px
          width: double.infinity,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, // 8 colunas
              childAspectRatio: 0.9, // Mantém os quadrados proporcionais
            ),
            itemCount: groupedTransactions.length,
            itemBuilder: (ctx, i) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: getDayColor(
                          groupedTransactions[i]['value'] as double,
                          monthMaxValue,
                          context),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          groupedTransactions[i]['day'].toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'R\$${NumTranform.formatValue((groupedTransactions[i]['value'] as double))}',
                      style: const TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
