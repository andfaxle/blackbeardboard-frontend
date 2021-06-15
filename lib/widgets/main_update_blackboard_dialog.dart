import 'package:flutter/material.dart';

// no functionality implemented here, on layouting
class MainUpdateBlackboardDialog extends StatelessWidget {

  final Function onDeletePressed;
  final Function onCancelPressed;
  final Function onUpdatePressed;

  final TextEditingController messageController;

  final String blackboardName;

  const MainUpdateBlackboardDialog({Key key, this.blackboardName,this.onDeletePressed, this.onCancelPressed, this.onUpdatePressed, this.messageController, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:
      Text("Update '" +blackboardName +  "'"),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text("New Message:"),
            TextField(
              controller: messageController,
              decoration: InputDecoration(hintText: "Message"),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
            child: Text("Delete '" +
                blackboardName +
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
                blackboardName +
                "'"),
            style: TextButton.styleFrom(),
            onPressed: onUpdatePressed
        ),
      ],
    );
  }

}