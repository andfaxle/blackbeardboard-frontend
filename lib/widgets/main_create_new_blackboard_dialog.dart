import 'package:flutter/material.dart';


// A simple dialog to update a blackboard
class MainCreateNewBlackboardDialog extends StatelessWidget {
  final Function onCancelPressed;
  final Function onCreatePressed;

  final  GlobalKey<FormState> formKey;

  final TextEditingController blackboardNameController;
  final TextEditingController deprecationTimeController;

  const MainCreateNewBlackboardDialog(
      {Key key,
      this.onCancelPressed,
      this.onCreatePressed,
      this.blackboardNameController,
      this.deprecationTimeController,
      this.formKey
    })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create New Blackboard"),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: blackboardNameController,
              decoration: InputDecoration(hintText: "Blackboard name"),
              validator: (value){
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            TextFormField(
              keyboardType: TextInputType.number,
              controller: deprecationTimeController,
              decoration: InputDecoration(hintText: "Deprecation Time (sec.)"),
              validator: (value){
                final number = int.tryParse(value);
                if (value == null || value.isEmpty ||number == null) {
                  return 'Please enter a number';
                }
                return null;
              },
            ),
          ],
        ),
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
