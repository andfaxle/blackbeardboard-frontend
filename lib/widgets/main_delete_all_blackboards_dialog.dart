
import 'package:flutter/material.dart';

class MainDeleteAllBlackboardsDialog extends StatelessWidget {

  final Function onCancelPressed;
  final Function onDeleteAllPressed;

  const MainDeleteAllBlackboardsDialog({Key key, this.onCancelPressed, this.onDeleteAllPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  return AlertDialog(
        title: const Text("Delete all Blackboards permanently?"),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text("Are you sure you want to delete ALL Blackboards?"),
              Text(""),
              Text("This action can not be reverted!"),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
              child: Text('Cancel'),
              onPressed: onCancelPressed,
          ),
          ElevatedButton(
              child: Text('Delete all'),
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
              ),
              onPressed: onDeleteAllPressed,
          ),
        ],
      );
  }
}