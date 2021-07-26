import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:agora_flutter/agora_video/view/call_video_page.dart';
import 'package:agora_flutter/utils/permissions_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class ChannelPage extends StatefulWidget {
  const ChannelPage({Key? key}) : super(key: key);

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  List<String?> newChannelOptions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: 500,
        child: newChannelOptions.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(newChannelOptions[index] ?? ''),
                    onTap: () async {
                      await handleCameraAndMic(Permission.camera);
                      await handleCameraAndMic(Permission.microphone);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallVideoPage(
                            channelName: newChannelOptions[index],
                            role: ClientRole.Broadcaster,
                          ),
                        ),
                      );
                    },
                  );
                },
                itemCount: newChannelOptions.length,
              )
            : const SizedBox(
                child: Center(
                  child: Text('No channles yet'),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var text = await showTextInputDialog(
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
          setState(() {
            newChannelOptions = text ?? [];
          });
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
