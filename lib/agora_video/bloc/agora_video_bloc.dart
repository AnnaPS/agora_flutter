import 'package:agora_flutter/agora_video/bloc/agora_video_event.dart';
import 'package:agora_flutter/agora_video/bloc/agora_video_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AgoraVideoBloc extends Bloc<AgoraVideoEvent, AgoraVideoState> {
  AgoraVideoBloc(AgoraVideoState initialState) : super(initialState);

  final List<String> infoString = [];
  final users = <int>[];
  bool isMuted = false;

  @override
  Stream<AgoraVideoState> mapEventToState(AgoraVideoEvent event) async* {
    if (event is JoinToChannel) {
      yield* _mapJoinToChannelToState(event);
    } else if (event is UpdateInfoStringsList) {
      yield* _mapUpdateInfoStringsToState(event);
    } else if (event is ClearInfoStringsList) {
      yield* _mapClearInfoStringsToState(event);
    } else if (event is ClearUserList) {
      yield* _mapClearUsersToState(event);
    } else if (event is UserRemoveChannel) {
      yield* _mapRemoveUsersToState(event);
    } else if (event is MuteUnmute) {
      yield* _mapHandleMutedToState(event);
    }
  }

  Stream<AgoraVideoState> _mapJoinToChannelToState(JoinToChannel event) async* {
    users.add(event.uid);
    yield AgoraVideoJoinChannelSuccess(users: users);
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

  Stream<AgoraVideoState> _mapClearUsersToState(ClearUserList event) async* {
    users.clear();
    yield AgoraVideoClearUserSuccess(users: users);
  }

  Stream<AgoraVideoState> _mapRemoveUsersToState(
      UserRemoveChannel event) async* {
    users.remove(event.uid);
    yield AgoraVideoStringLeaveChannelSuccess(users: users);
  }

  Stream<AgoraVideoState> _mapHandleMutedToState(MuteUnmute event) async* {
    isMuted = event.isMuted;
    yield AgoraVideoHandleMuteSuccess(isMuted: isMuted);
  }
}
