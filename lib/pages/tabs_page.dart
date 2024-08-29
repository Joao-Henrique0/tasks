import 'package:flutter/material.dart';
import 'package:tarefas/components/main_drawer.dart';
import 'package:tarefas/pages/expenses_page.dart';
import 'package:tarefas/pages/tasks_page.dart';
import '../utils/app_routes.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedScreenIndex = 0;
  late final List<Map<String, Object>> _screens;
  @override
  void initState() {
    super.initState();
    _screens = [
      {
        'title': 'Lista de Tarefas',
        'screen': const TasksPage(),
        'actions': [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.taskForm),
            icon: const Icon(Icons.add),
          ),
        ],
      },
      {
        'title': 'Despesas',
        'screen': const ExpensesPage(),
        'actions': [
          IconButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.transactionForm),
            icon: const Icon(Icons.add),
          ),
        ]
      }
    ];
  }

  _selectScreen(int index) {
    setState(() {
      _selectedScreenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
          title: Text(_screens[_selectedScreenIndex]['title'] as String),
          actions: _screens[_selectedScreenIndex]['actions'] as List<Widget>),
      drawer: const MainDrawer(),
      body: _screens[_selectedScreenIndex]['screen'] as Widget,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: color,
        onTap: _selectScreen,
        unselectedItemColor: Colors.white,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        currentIndex: _selectedScreenIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              backgroundColor: color,
              icon: const Icon(Icons.task),
              label: 'Tarefas'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.monetization_on),
              label: 'Despesas',
              backgroundColor: color)
        ],
      ),
    );
  }
}
