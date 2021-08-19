import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../api.dart';
import '../../prefs/user.dart';
import './task_dialog.dart';

class TaskList extends StatefulWidget {
  TaskList({Key key, this.selectedTab}) : super(key: key);
  final int selectedTab;

  @override
  TaskListState createState() =>  TaskListState();
}

dynamic defaultTask = {
  "title": "",
  "description": "Create New Task",
  "id": 0
};

class TaskListState extends State<TaskList> {
  var _taskList = [];
  var _filteredTasks = [];
  var _activeTask = defaultTask;
  var _loadingTasks = false;

  var _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.selectedTab;
    getTasks();
  }

  updateCurrentTab(tab) {
    setState(() {
      _selectedTab = tab;
    });
    filterTasks();
  }

  getTasks() async {
    setState(() {
      _loadingTasks = true;
    });

    var userId = await User.get('id');

    var employee = await Api.get(path: '/sbm/employees/from_user', params: {"user_id": userId.toString()});

    var url = '/sbm/employees/' + employee["id"].toString() + '/employee_prepared_by_tasks.json';
    var taskList = await Api.get(path: url);

    findActiveTask(taskList);

    var filteredTasks = taskList.where((task) => filterByTab(task)).toList();

    setState(() {
      _taskList = taskList;
      _filteredTasks = filteredTasks;
      _loadingTasks = false;
    });
  }

  // The active task is any task with a start date but no end date.
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

  filterTasks() {
    setState(() {
      _loadingTasks = true;
    });

    var filteredTasks = _taskList.where((task) => filterByTab(task)).toList();

    setState(() {
      _filteredTasks = filteredTasks;
      _loadingTasks = false;
    });
  }

  // Filters the task based on what tab is currently selected
  bool filterByTab(task) {
    if (_selectedTab == 1) { // Custom
      return task["section_id"] == null;
    } else if (_selectedTab == 2) { // Top Ten
      if (task["types"].length == 0) {
        return false;
      }

      return task["types"].any((t) => t["title"] == "Top Ten");
    } else if (_selectedTab == 3) { // Projects
      return task["has_tasks_type"] == "Sbm::ProjectPhase";
    } else if (_selectedTab == 4) { // Coaching
      return task["content_entries"].length != 0;
    } else if (_selectedTab == 5) { // Open Point
      return task["open_point"] != null;
    } else if (_selectedTab == 6) { // Checklist
      if (task["types"].length == 0) {
        return false;
      }

      return task["types"].any((t) => t["title"] == "Checklist");
    } else {
      return true;
    }
  }

  // Send an API request to start the task. Then mark this task as active
  // The server will stop any currently active tasks
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

  // Send an API request to the server to stop a task. The task will be marked
  // inactive
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

  // Render a pause button for the active task
  pauseButton(task) {
    return IconButton(
        icon: Icon(Icons.pause),
        onPressed: () {
          stopTask(task["id"]);
        }
    );
  }

  // Render the play button for any inactive tasks
  playButton(task) {
    return IconButton(
        icon: Icon(Icons.play_arrow),
        onPressed: () {
          startTask(task["id"]);
        }
    );
  }

  // Render the new task button.
  plusButton() {
    return IconButton(
      icon: Icon(Icons.add),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) {
              return TaskDialog();
            }
        ).then((val) {
          getTasks();
        });
      }
    );
  }

  // Choose which button this task needs to use
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
            children: [
              ListTile(
                title: Text(_activeTask["description"] != null ? _activeTask["description"] : ""),
                subtitle: Text("Active Task"),
                trailing: chooseButton(_activeTask),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return TaskDialog.fromExistingTask(_activeTask);
                      }
                  );
                },
                selected: _activeTask["id"] != 0
              ),
              Divider(thickness: 2),
              ...(_filteredTasks.map((task) {
                if (_loadingTasks) return Container(
                  child: LinearProgressIndicator(),
                  height: 0.1
                );
                if (task == _activeTask) return Container(height: 0); // This just makes it disappear
                return ListTile(
                  title: Text(task["description"] != null ? task["description"] : ""),
                  subtitle: Text(task["title"] != null ? task["title"] : ""),
                  trailing: chooseButton(task),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return TaskDialog.fromExistingTask(task);
                      }
                    );
                  }
                );
              }).toList())
            ]
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