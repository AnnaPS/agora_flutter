import 'package:agora_flutter/agora_video/bloc/agora_video_event.dart';
import 'package:agora_flutter/agora_video/bloc/agora_video_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgoraVideoBloc extends Bloc<AgoraVideoEvent, AgoraVideoState> {
  AgoraVideoBloc(AgoraVideoState initialState) : super(initialState);

  final List<String> infoString = [];

  @override
  Stream<AgoraVideoState> mapEventToState(AgoraVideoEvent event) async* {
    if (event is JoinToChannel) {
      yield* _mapJoinToChannelToState(event);
    } else if (event is UpdateInfoStringsList) {
      yield* _mapUpdateInfoStringsToState(event);
    } else if (event is ClearInfoStringsList) {
      yield* _mapClearInfoStringsToState(event);
    }
  }

  Stream<AgoraVideoState> _mapJoinToChannelToState(JoinToChannel event) async* {
    yield AgoraVideoJoinChannelSuccess(uid: event.uid, channel: event.channel);
  }

  Stream<AgoraVideoState> _mapClearInfoStringsToState(
      ClearInfoStringsList event) async* {
    infoString.clear();
    yield AgoraVideoCleanInfoStringsSuccess(infoString: infoString);
  }

  Stream<AgoraVideoState> _mapUpdateInfoStringsToState(
      UpdateInfoStringsList event) async* {
    infoString.add(event.newText);
    yield AgoraVideoStringInfoSuccess(infoString: infoString);
  }
}
