import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tarefas/components/multi_dismissible.dart';
import 'package:tarefas/models/task.dart';
import 'package:tarefas/models/task_list.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final Color cor = task.complete
        ? Colors.green[200]!
        : task.time.isBefore(DateTime.now())
            ? Colors.red[200]!
            : Colors.amber[100]!;

    return MultiDismissible(
      object: task,
      card: Card(
        elevation: 3,
        color: cor,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            title: Text(
              task.title,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
            leading: IconButton(
              onPressed: () {
                task.completeTask();
                Provider.of<TaskList>(context, listen: false)
                    .updateTaskComplete(task.id, task.complete);
              },
              icon: task.complete
                  ? const Icon(Icons.check_circle_outline_outlined)
                  : const Icon(Icons.circle_outlined),
            ),
            subtitle: Text(
              DateFormat('dd/MM HH:mm').format(task.time),
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
            tilePadding: const EdgeInsets.symmetric(horizontal: 15),
            collapsedIconColor: Colors.black,
            iconColor: Colors.black,
            backgroundColor: Colors.transparent,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Text(
                  task.description,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
