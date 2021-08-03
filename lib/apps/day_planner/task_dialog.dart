import 'package:flutter/material.dart';

class TaskDialog extends StatefulWidget {
  @override
  _TaskDialogState createState() =>  _TaskDialogState();

}

class _TaskDialogState extends State<TaskDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: _formKey,
        onChanged: () {
          Form.of(primaryFocus.context).save();
        },
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            Row(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Description'
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  }
                ),
              ]
            ),
            Row(

            )
          ]
        )
      )
    );
  }

}