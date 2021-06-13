import 'package:flutter/material.dart';

class MainUpdateBlackboardDialog extends StatelessWidget {

  final Function onDeletePressed;
  final Function onCancelPressed;
  final Function onUpdatePressed;

  final TextEditingController deprecationTimeController;
  final TextEditingController messageController;

  const MainUpdateBlackboardDialog({Key key, this.onDeletePressed, this.onCancelPressed, this.onUpdatePressed, this.messageController, this.deprecationTimeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
      Text("Update '" + "blackboardNames[currentSelectedBlackboard]" + "'"),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text("New Message:"),
            TextField(
              onChanged: (value) {
              },
              controller: messageController,
              decoration: InputDecoration(hintText: "Message"),
            ),
            SizedBox(height: 15),
            Text("New deprecation time:"),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
              },
              controller: deprecationTimeController,
              decoration:
              InputDecoration(hintText: "Deprecation Time (sec.)"),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
            child: Text("Delete '" +
                "blackboardNames[currentSelectedBlackboard]" +
                "'"),
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.red,
            ),
            onPressed: onDeletePressed,
        ),
        TextButton(
            child: Text('Cancel'),
            onPressed: onCancelPressed
        ),
        ElevatedButton(
            child: Text("Update '" +
                "blackboardNames[currentSelectedBlackboard]" +
                "'"),
            style: TextButton.styleFrom(),
            onPressed: onUpdatePressed
        ),
      ],
    );
  }

}