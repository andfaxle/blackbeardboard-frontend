import 'package:flutter/material.dart';

class MainCreateNewBlackboardDialog extends StatelessWidget {
  final Function onCancelPressed;
  final Function onCreatePressed;

  final TextEditingController blackboardNameController;
  final TextEditingController deprecationTimeController;

  const MainCreateNewBlackboardDialog(
      {Key key,
      this.onCancelPressed,
      this.onCreatePressed,
      this.blackboardNameController,
      this.deprecationTimeController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Blackboard"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            onChanged: (value) {},
            controller: blackboardNameController,
            decoration: InputDecoration(hintText: "Blackboard name"),
          ),
          TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {},
            controller: deprecationTimeController,
            decoration: InputDecoration(hintText: "Deprecation Time (sec.)"),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(child: Text('Cancel'), onPressed: onCancelPressed),
        ElevatedButton(
          child: Text('Create'),
          onPressed: onCreatePressed,
        )
      ],
    );
  }
}
