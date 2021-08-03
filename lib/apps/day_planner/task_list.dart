import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../api.dart';
import '../../prefs/user.dart';

class TaskList extends StatefulWidget {
  TaskList({Key key, this.selectedTab}) : super(key: key);
  final int selectedTab;

  @override
  _TaskListState createState() =>  _TaskListState();
}

dynamic defaultTask = {
  "title": "",
  "description": "Create New Task",
  "id": 0
};

class _TaskListState extends State<TaskList> {
  var _taskList = [];
  var _activeTask = defaultTask;

  @override
  void initState() {
    super.initState();
    getTasks();
  }

  getTasks() async {
    var userId = await User.get('id');

    var employee = await Api.get(path: '/sbm/employees/from_user', params: {"user_id": userId.toString()});

    var url = '/sbm/employees/' + employee["id"].toString() + '/employee_prepared_by_tasks.json';
    var taskList = await Api.get(path: url);

    findActiveTask(taskList);

    setState(() {
      _taskList = taskList;
    });
  }

  findActiveTask(taskList) {
    var taskToUse = defaultTask;
    for (var task in taskList) {
      if (isActive(task)) {
        taskToUse = task;
        break;
      }
    }

    setState(() {
      _activeTask = taskToUse;
    });
  }

  startTask(taskId) async {
    var activeTask = await Api.post(
        path: '/sbm/tasks/' + taskId.toString() + '/start.json',
        params: {"id": taskId.toString()}
      );

    if (activeTask == null) {
      return;
    }

    setState(() {
      _activeTask = activeTask;
    });

    getTasks();
  }

  stopTask(taskId) async {
    await Api.post(
        path: '/sbm/tasks/' + taskId.toString() + '/stop.json',
        params: {"id": taskId.toString()}
    );

    setState(() {
      _activeTask = defaultTask;
    });

    getTasks();
  }

  pauseButton(task) {
    return IconButton(
        icon: Icon(Icons.pause),
        onPressed: () {
          stopTask(task["id"]);
        }
    );
  }

  playButton(task) {
    return IconButton(
        icon: Icon(Icons.play_arrow),
        onPressed: () {
          startTask(task["id"]);
        }
    );
  }

  plusButton() {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        // TODO - Create a new Task Dialog
      }
    );
  }

  chooseButton(task) {
    if (task == null || task["id"] == null || task["id"] == 0) {
      return plusButton();
    }

    return isActive(task) ? pauseButton(task) : playButton(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: ListView(
            children: [_activeTask, ..._taskList].map((task) {
              return ListTile(
                title: Text(task["description"] != null ? task["description"] : ""),
                subtitle: Text(task["title"] != null ? task["title"] : ""),
                trailing: chooseButton(task)
              );
            }).toList()
          )
        )
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

bool isActive(task) {
  if (task["task_events"] == null || task["task_events"].length == 0) {
    return false;
  }

  if (task["task_events"][task["task_events"].length - 1]["event_type"] == "start") {
    return true;
  }

  return false;
}