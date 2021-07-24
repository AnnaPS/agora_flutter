import 'package:agora_flutter/agora_channels/view/channels.dart';
import 'package:agora_flutter/agora_video/view/agora_video_home.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AgoraMain extends StatefulWidget {
  AgoraMain({Key? key}) : super(key: key);

  @override
  _AgoraMainState createState() => _AgoraMainState();
}

class _AgoraMainState extends State<AgoraMain> {
  int currentPage = 0;
  final _pageOptions = [AgoraVideoHome(), ChannelPage()];

  GlobalKey bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora main'),
      ),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: Icons.home, title: 'Home', onclick: () {}),
          TabData(iconData: Icons.tv, title: 'Channels', onclick: () {}),
        ],
        initialSelection: 0,
        key: bottomNavigationKey,
        onTabChangedListener: (position) {
          setState(() {
            currentPage = position;
          });
        },
      ),
      body: _pageOptions[currentPage],
    );
  }
}
