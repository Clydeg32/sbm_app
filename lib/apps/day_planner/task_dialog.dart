import 'package:flutter/material.dart';
import '../../api.dart';
import '../../prefs/user.dart';

class TaskDialog extends StatefulWidget {
  TaskDialog({Key key, this.task}) : super(key: key);

  final task;

  factory TaskDialog.fromExistingTask(task) =>
      TaskDialog(task: task);

  @override
  _TaskDialogState createState() =>  _TaskDialogState();

}

class _TaskDialogState extends State<TaskDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final descriptionController = TextEditingController();

  var task;

  @override
  void initState() {
    super.initState();
    task = widget.task;

    if (taskExists()) {
      descriptionController.value = TextEditingValue(text: task["description"]);
    }
  }

  // Shows if task is an existing task
  taskExists() {
    return task != null && task["id"] != 0;
  }

  saveTask() async {
    if (taskExists()) {
      await Api.put(
        path: '/sbm/tasks/' + task["id"],
        params: {
          "description": descriptionController.value.text
        }
      );
    } else {
      var userId = (await User.get("id")).toString();

      var employee = await Api.get(
          path: '/sbm/employees/from_user',
          params: {"user_id": userId}
      );

      await Api.post(
        path: '/sbm/tasks/',
        params: {
          "description": descriptionController.value.text,
          "prepared_employee_id": employee["id"].toString()
        }
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      title: Text(taskExists() ? "View Task" : "New Task"),
      content: Container(
        width: 350,
        height: 600,
        child: Form(
          key: _formKey,
          onChanged: () {
            Form.of(primaryFocus.context).save();
          },
          child: Padding(
            padding: EdgeInsets.all(2.0),
            child: GridView.count(
              crossAxisCount: 1,
              padding: EdgeInsets.all(0),
              childAspectRatio: 4,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                            labelText: 'Description'
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        controller: descriptionController
                      ),
                    ),
                  ]
                ),
              ]
            )
          )
        )
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Save Task'),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              saveTask();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please fill out the required fields')),
              );
            }
          },
        )
      ]
    );
  }

}
