import 'package:flutter/material.dart';

class MainCreateNewBlackboardDialog extends StatelessWidget {
  final Function onCancelPressed;
  final Function onCreatePressed;

  final TextEditingController blackboardNameController;
  final TextEditingController deprecationTimeController;
  final TextEditingController messageController;

  const MainCreateNewBlackboardDialog(
      {Key key,
      this.onCancelPressed,
      this.onCreatePressed,
      this.blackboardNameController,
      this.messageController,
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
          TextField(
            onChanged: (value) {},
            controller: messageController,
            decoration: InputDecoration(hintText: "Message"),
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
