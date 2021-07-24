import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage({Key? key}) : super(key: key);

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('Channels'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final text = await showTextInputDialog(
            context: context,
            textFields: [
              DialogTextField(
                hintText: 'Channel name',
                validator: (value) =>
                    value!.isEmpty ? 'Input more than one character' : null,
              ),
              DialogTextField(
                hintText: 'Language to learn',
                validator: (value) =>
                    value!.length < 2 ? 'Input more than two characters' : null,
              ),
            ],
            title: 'Add new channel',
            message: 'Select the language channel',
            autoSubmit: true,
          );
          print(text?[0]);
        },
        backgroundColor: Colors.amber,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
