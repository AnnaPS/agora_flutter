import 'package:agora_flutter/agora_audio/view/user_view.dart';
import 'package:agora_flutter/utils/settings.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  CallScreen(
      {required this.channelName, required this.userName, required this.role});
  final String channelName;
  final String userName;
  late ClientRole role;
  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  static final joinedUsers = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool _isLogin = false;
  bool _isInChannel = false;
  final _broadcaster = <String>[];
  final _audience = <String>[];
  final Map<int, String> _allUsers = {};

  late AgoraRtmClient? _client;
  late AgoraRtmChannel? _channel;
  late RtcEngine _engine;

  final buttonStyle = const TextStyle(color: Colors.white, fontSize: 15);

  int localUid = 0;

  @override
  void dispose() {
    if (mounted) {
      // destroy sdk
      _engine
        ..leaveChannel()
        ..destroy();
      _channel?.leave();
      _allUsers.clear();

      _broadcaster.clear();
      _audience.clear();
      // clear users
      joinedUsers.clear();
    }

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    initialize();
    _createClient();
  }

  Future<void> initialize() async {
    if (appID.isEmpty) {
      setState(() {
        _infoStrings
          ..add('APP_ID missing, please provide your APP_ID in settings.dart')
          ..add('Agora Engine is not starting');
      });
      return;
    }
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    // await _engine.enableWebSdkInteroperability(true);
    await _engine.joinChannel(null, widget.channelName, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(appID);
    await _engine.disableVideo();
    await _engine.disableAudio();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(error: (code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    }, joinChannelSuccess: (channel, uid, elapsed) async {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
        localUid = uid;
        _allUsers.putIfAbsent(uid, () => widget.userName);
      });
      if (widget.role == ClientRole.Broadcaster) {
        setState(() {
          joinedUsers.add(uid);
        });
      }
    }, leaveChannel: (stats) async {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        joinedUsers.clear();
        _allUsers.remove(localUid);
      });
      await _channel?.sendMessage(AgoraRtmMessage.fromText('$localUid:leave'));
    }, userJoined: (uid, elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        joinedUsers.add(uid);
      });
    }, userOffline: (uid, reason) {
      setState(() {
        final info = 'userOffline: $uid , reason: $reason';
        _infoStrings.add(info);
        joinedUsers.remove(uid);
      });
    }, firstRemoteVideoFrame: (uid, width, height, elapsed) {
      setState(() {
        final info = 'firstRemoteVideoFrame: $uid';
        _infoStrings.add(info);
      });
    }, clientRoleChanged: (oldRole, newRole) {
      setState(() {
        final info = 'clientRoleChanged: old: $oldRole - new $newRole';
        _infoStrings.add(info);
      });
    }));
  }

  void _createClient() async {
    _client = await AgoraRtmClient?.createInstance(appID);
    _client?.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        _client?.logout();
        print('Logout.');
        setState(() {
          _isLogin = false;
        });
      }
    };

    final userId = widget.userName;
    await _client?.login(null, userId);
    print('Login success: $userId');
    setState(() {
      _isLogin = true;
    });
    final channelName = widget.channelName;
    _channel = await _createChannel(channelName);
    await _channel?.join();
    print('RTM Join channel success.');
    setState(() {
      _isInChannel = true;
    });
    await _channel?.sendMessage(AgoraRtmMessage.fromText('$localUid:join'));
    _client?.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      print('Peer msg: $peerId , msg: ${message.text}');

      var userData = message.text?.split(':');

      if (userData?[1] == 'leave') {
        print('In here');
        setState(() {
          _allUsers.remove(int.parse(userData?[0] ?? ''));
        });
      } else {
        setState(() {
          _allUsers.putIfAbsent(int.parse(userData?[0] ?? ''), () => peerId);
        });
      }
    };
    _channel?.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) {
      print(
          'Outside channel message received : ${message.text} from ${member.userId}');

      var userData = message.text?.split(':');

      if (userData?[1] == 'leave') {
        setState(() {
          _allUsers.remove(int.parse(userData?[0] ?? '0'));
        });
      } else {
        print('Broadcasters list : $joinedUsers');
        print('All users lists: ${_allUsers.values}');
        setState(() {
          _allUsers.putIfAbsent(
              int.parse(userData?[0] ?? '0'), () => member.userId);
        });
      }
    };

    for (var i = 0; i < joinedUsers.length; i++) {
      if (_allUsers.containsKey(joinedUsers[i])) {
        setState(() {
          _broadcaster.add(_allUsers[joinedUsers[i]] ?? '');
        });
      } else {
        setState(() {
          _audience.add('${_allUsers.values}');
        });
      }
    }
  }

  Future<AgoraRtmChannel?> _createChannel(String name) async {
    var channel = await _client?.createChannel(name);
    channel?.onMemberJoined = (AgoraRtmMember member) async {
      print('Member joined : ${member.userId}');
      await _client?.sendMessageToPeer(
          member.userId, AgoraRtmMessage.fromText('$localUid:join'));
    };
    return channel!
      ..onMemberLeft = (AgoraRtmMember member) async {
        var reversedMap = _allUsers.map((k, v) => MapEntry(v, k));
        print('Member left : ${member.userId}:leave');
        print('Member left : ${reversedMap[member.userId]}:leave');

        setState(() {
          _allUsers.remove(reversedMap[member.userId]);
        });
        await channel.sendMessage(
            AgoraRtmMessage.fromText('${reversedMap[member.userId]}:leave'));
      }
      ..onMessageReceived = (AgoraRtmMessage message, AgoraRtmMember member) {
        print(
            'Channel message received : ${message.text} from ${member.userId}');

        var userData = message.text?.split(':');

        if (userData?[1] == 'leave') {
          _allUsers.remove(int.parse(userData![0]));
        } else {
          _allUsers.putIfAbsent(
              int.parse(userData?[0] ?? '0'), () => member.userId);
        }
      };
  }

  /// Toolbar layout
  Widget _toolbar() {
    return widget.role == ClientRole.Audience
        ? SizedBox(
            width: 200,
            child: MaterialButton(
              onPressed: () => _onChangeRole(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 2.0,
              color: Colors.green,
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.airplanemode_active,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Broadcaster',
                    style: buttonStyle,
                  )
                ],
              ),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              RawMaterialButton(
                onPressed: _onToggleMute,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 2.0,
                fillColor: muted ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Icon(
                      muted ? Icons.mic_off : Icons.mic,
                      color: muted ? Colors.white : Colors.blueAccent,
                      size: 20.0,
                    ),
                    const SizedBox(width: 5),
                    muted
                        ? Text('Unmute', style: buttonStyle)
                        : Text('Mute',
                            style: buttonStyle.copyWith(color: Colors.black))
                  ],
                ),
              ),
              RawMaterialButton(
                onPressed: () => _onCallEnd(context),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Disconnect',
                      style: buttonStyle,
                    )
                  ],
                ),
              ),
            ],
          );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onChangeRole(BuildContext context) {
    setState(() {
      widget.role = ClientRole.Broadcaster;
    });
    _engine.setClientRole(ClientRole.Broadcaster);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Broadcaster',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: joinedUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  return _allUsers.containsKey(joinedUsers[index])
                      ? UserView(
                          userName: _allUsers[joinedUsers[index]] ?? 'User',
                          role: ClientRole.Broadcaster,
                        )
                      : const SizedBox();
                },
              )),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Audience',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _allUsers.length,
                itemBuilder: (BuildContext context, int index) {
                  return joinedUsers.contains(_allUsers.keys.toList()[index])
                      ? const SizedBox()
                      : UserView(
                          role: ClientRole.Audience,
                          userName: _allUsers.values.toList()[index],
                        );
                },
              )),
          _toolbar()
        ],
      )),
    );
  }
}
