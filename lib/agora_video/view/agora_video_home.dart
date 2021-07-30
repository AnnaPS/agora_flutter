import 'dart:async';

import 'package:agora_flutter/agora_video/bloc/agora_video_bloc.dart';
import 'package:agora_flutter/agora_video/bloc/agora_video_state.dart';
import 'package:agora_flutter/utils/permissions_handler.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import 'call_video_page.dart';

class AgoraVideoHome extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AgoraVideoHomeState();
}

class _AgoraVideoHomeState extends State<AgoraVideoHome> {
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();

  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole? _role = ClientRole.Broadcaster;

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //clear info strings
    context.watch<AgoraVideoBloc>().infoString.clear();
    // clear users
    context.watch<AgoraVideoBloc>().users.clear();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 400,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: TextField(
                  controller: _channelController,
                  decoration: InputDecoration(
                    errorText:
                        _validateError ? 'Channel name is mandatory' : null,
                    border: const UnderlineInputBorder(
                      borderSide: BorderSide(width: 1),
                    ),
                    hintText: 'Channel name',
                  ),
                ))
              ],
            ),
            Column(
              children: [
                ListTile(
                  title: Text(ClientRole.Broadcaster.toString()),
                  leading: Radio(
                    value: ClientRole.Broadcaster,
                    groupValue: _role,
                    onChanged: (ClientRole? value) {
                      setState(() {
                        _role = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text(ClientRole.Audience.toString()),
                  leading: Radio(
                    value: ClientRole.Audience,
                    groupValue: _role,
                    onChanged: (ClientRole? value) {
                      setState(() {
                        _role = value;
                      });
                    },
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onJoin,
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blueAccent),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      child: const Text('Join'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await handleCameraAndMic(Permission.camera);
      await handleCameraAndMic(Permission.microphone);
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallVideoPage(
            channelName: _channelController.text,
            role: _role,
          ),
        ),
      );
    }
  }
}
