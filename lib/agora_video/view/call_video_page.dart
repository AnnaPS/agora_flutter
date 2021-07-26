import 'package:agora_flutter/agora_video/bloc/agora_video_bloc.dart';
import 'package:agora_flutter/agora_video/bloc/agora_video_event.dart';
import 'package:agora_flutter/agora_video/bloc/agora_video_state.dart';
import 'package:agora_flutter/utils/settings.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallVideoPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String? channelName;

  /// non-modifiable client role of the page
  final ClientRole? role;

  /// Creates a call page with given channel name.
  const CallVideoPage({Key? key, this.channelName, this.role})
      : super(key: key);

  @override
  _CallVideoPageState createState() => _CallVideoPageState();
}

class _CallVideoPageState extends State<CallVideoPage> {
  final _users = <int>[];

  // final _infoStrings = <String>[];
  bool muted = false;
  late RtcEngine _engine;

  @override
  void dispose() {
    // clear users
    _users.clear();

    // destroy sdk
    _engine
      ..leaveChannel()
      ..destroy();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    //clear info strings
    context.read<AgoraVideoBloc>().add(ClearInfoStringsList());
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    // initialize agora sdk
    WidgetsBinding.instance?.addPostFrameCallback((_) => initialize(context));
  }

  Future<void> initialize(BuildContext myContext) async {
    if (appID.isEmpty) {
      context.read<AgoraVideoBloc>().add(UpdateInfoStringsList(
          newText:
              'APP_ID missing, please provide your APP_ID in settings.dart'));
      context
          .read<AgoraVideoBloc>()
          .add(UpdateInfoStringsList(newText: 'Agora Engine is not starting'));
      return;
    }

    await _initAgoraRtcEngine();
    _addAgoraEventHandlers(myContext);
    await _engine.enableWebSdkInteroperability(true);
    var configuration = VideoEncoderConfiguration()
      ..dimensions = VideoDimensions(width: 1920, height: 1080);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(null, widget.channelName!, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    _engine = await RtcEngine.create(appID);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers(BuildContext context) {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        context
            .read<AgoraVideoBloc>()
            .add(UpdateInfoStringsList(newText: 'onError: $code'));
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        context.read<AgoraVideoBloc>().add(
              UpdateInfoStringsList(
                  newText: 'onJoinChannel: $channel, uid: $uid'),
            );
      },
      leaveChannel: (stats) {
        setState(_users.clear);
        context
            .read<AgoraVideoBloc>()
            .add(UpdateInfoStringsList(newText: 'onLeaveChannel'));
      },
      userJoined: (uid, elapsed) {
        setState(() {
          _users.add(uid);
        });
        context
            .read<AgoraVideoBloc>()
            .add(UpdateInfoStringsList(newText: 'userJoined: $uid'));
      },
      userOffline: (uid, elapsed) {
        setState(() {
          _users.remove(uid);
        });
        context
            .read<AgoraVideoBloc>()
            .add(UpdateInfoStringsList(newText: 'userOffline: $uid'));
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        context.read<AgoraVideoBloc>().add(UpdateInfoStringsList(
            newText: 'firstRemoteVideo: $uid ${width}x $height'));
      },
    ));
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final list = <StatefulWidget>[];
    if (widget.role == ClientRole.Broadcaster) {
      list.add(RtcLocalView.SurfaceView());
    }
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return SizedBox(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return SizedBox(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return SizedBox(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return SizedBox(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return const SizedBox();
  }

  /// Toolbar layout
  Widget _toolbar(String? channelName) {
    if (widget.role == ClientRole.Audience) {
      return Stack(
        children: [
          _channelNameHeader(channelName),
          Container(),
        ],
      );
    }
    return Stack(
      fit: StackFit.loose,
      children: [
        _channelNameHeader(channelName),
        Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RawMaterialButton(
                onPressed: _onToggleMute,
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: muted ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  muted ? Icons.mic_off : Icons.mic,
                  color: muted ? Colors.white : Colors.blueAccent,
                  size: 20.0,
                ),
              ),
              RawMaterialButton(
                onPressed: () => _onCallEnd(context),
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35.0,
                ),
              ),
              RawMaterialButton(
                onPressed: _onSwitchCamera,
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(12.0),
                child: const Icon(
                  Icons.switch_camera,
                  color: Colors.blueAccent,
                  size: 20.0,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  // Show tag with channel name
  Widget _channelNameHeader(String? channelName) {
    return Align(
      alignment: Alignment.topCenter,
      child: IntrinsicHeight(
        child: IntrinsicWidth(
          child: Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 8,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              channelName ?? 'Unknown',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return BlocBuilder<AgoraVideoBloc, AgoraVideoState>(
      builder: (context, state) {
        if (state is AgoraVideoStringInfoSuccess) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.5,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: ListView.builder(
                  reverse: true,
                  itemCount: state.infoString.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                                horizontal: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.yellowAccent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                state.infoString[index],
                                style: const TextStyle(color: Colors.blueGrey),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Flutter QuickStart'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _panel(),
            _toolbar(widget.channelName),
          ],
        ),
      ),
    );
  }
}
