import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tarefas/models/transaction.dart';
import 'package:tarefas/models/transaction_list.dart';

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _formData = <String, Object>{};
  DateTime _selectedDate = DateTime.now();

  void _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    _formData['date'] = _selectedDate;

    _formKey.currentState?.save();

    try {
      await Provider.of<TransactionList>(context, listen: false)
          .saveTransaction(_formData);
      Navigator.of(context).pop();
    } catch (err) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Ocorreu um erro!'),
          content: const Text('Ocorreu um erro ao salvar a despesa'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_formData.isEmpty) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg != null) {
        final transaction = arg as Transaction;
        _formData['id'] = transaction.id;
        _formData['title'] = transaction.title;
        _formData['value'] = transaction.value;
        _formData['date'] = transaction.date;
        _selectedDate = transaction.date;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Despesas'),
        actions: [
          IconButton(
            onPressed: _submitForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _formData['title']?.toString(),
                decoration: const InputDecoration(labelText: 'Título'),
                textInputAction: TextInputAction.next,
                onSaved: (newValue) => _formData['title'] = newValue ?? '',
                validator: (name) {
                  final value = name ?? '';
                  if (value.trim().isEmpty) {
                    return 'O Título é obrigatório';
                  }
                  if (value.trim().length < 3) {
                    return 'O Título precisa de no mínimo 3 letras';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _formData['value']?.toString(),
                decoration: const InputDecoration(labelText: 'Valor'),
                textInputAction: TextInputAction.done,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onSaved: (newValue) {
                  _formData['value'] = double.tryParse(newValue!) ?? 0;
                },
                validator: (valor) {
                  if (valor == null || valor.isEmpty) {
                    return 'Digite um valor válido';
                  }
                  final parsedValue = double.tryParse(valor);
                  if (parsedValue == null || parsedValue <= 0) {
                    return 'Digite um valor válido';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 70,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Data selecionada: ${DateFormat('dd/MM/y').format(
                          _formData['date'] as DateTime? ?? _selectedDate,
                        )}',
                      ),
                    ),
                    TextButton(
                      onPressed: _showDatePicker,
                      child: Text(
                        'Selecionar Data',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
