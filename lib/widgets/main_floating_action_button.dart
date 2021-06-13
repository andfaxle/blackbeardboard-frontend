

import 'package:flutter/material.dart';

class MainFloatingActinButton extends StatelessWidget {

  final Function onAddBlackboardPressed;
  final Function onDeleteAllBlackboardsPressed;

  const MainFloatingActinButton({Key key, this.onAddBlackboardPressed, this.onDeleteAllBlackboardsPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            FloatingActionButton.extended(
              onPressed: onAddBlackboardPressed,
              label: const Text('New Blackboard'),
              icon: const Icon(Icons.add),
              backgroundColor: Colors.blue,
            ),
            SizedBox(width: 20),
            FloatingActionButton.extended(
              onPressed: onDeleteAllBlackboardsPressed,
              label: const Text('Delete all Blackboards'),
              icon: const Icon(Icons.delete_forever),
              backgroundColor: Colors.red,
            )
          ],
        ));
  }
}
