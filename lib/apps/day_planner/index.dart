import 'package:flutter/material.dart';
import '../../../styles/themes.dart';
import './task_list.dart';

class DayPlanner extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DayPlannerState();
  
}

class _DayPlannerState extends State<DayPlanner>
    with TickerProviderStateMixin  {
  TabController _taskTabController;
  @override
  void initState() {
    super.initState();
    _taskTabController = TabController(length: 7, vsync: this);
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
                Tab(text: "Assigned To Tasks"),
              ]
          )
      ),
      body: Center(
        child: TaskList()
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'New Task',
        child: Icon(Icons.add),
      ),
    );
  }
  
}