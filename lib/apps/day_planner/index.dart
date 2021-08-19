import 'package:flutter/material.dart';
import '../../../styles/themes.dart';
import './task_list.dart';
import './task_dialog.dart';

class DayPlanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DayPlannerState();
  
}

class _DayPlannerState extends State<DayPlanner>
    with TickerProviderStateMixin  {
  TabController _taskTabController;

  final GlobalKey<TaskListState> _listKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _taskTabController = TabController(length: 8, vsync: this);

    _taskTabController.addListener(() {
      if (_taskTabController.indexIsChanging) {
        _listKey.currentState.updateCurrentTab(_taskTabController.index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Current Tasks"),
          bottom: TabBar(
              controller: _taskTabController,
              isScrollable: true,
              physics: BouncingScrollPhysics(),
              tabs: const <Widget>[
                Tab(text: "All My Tasks"),
                Tab(text: "Custom"),
                Tab(text: "Top 10"),
                Tab(text: "Project"),
                Tab(text: "Coaching"),
                Tab(text: "Open Point"),
                Tab(text: "Checklist"),
                Tab(text: "Assigned To Tasks")
              ]
          )
      ),
      body: Center(
        child: TaskList(
          key: _listKey,
          selectedTab: _taskTabController.index
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return TaskDialog();
              }
          ).then((val) {
            setState(() {});
          });
        },
        tooltip: 'New Task',
        child: Icon(Icons.add),
      ),
    );
  }
  
}