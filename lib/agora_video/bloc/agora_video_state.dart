import 'package:equatable/equatable.dart';

class AgoraVideoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AgoraVideoIdle extends AgoraVideoState {}

class AgoraVideoStringInfoSuccess extends AgoraVideoState {
  AgoraVideoStringInfoSuccess({required this.infoString});
  final List<String> infoString;
  @override
  List<Object?> get props => [infoString];
}

class AgoraVideoStringLeaveChannelSuccess extends AgoraVideoState {}

class AgoraVideoCleanInfoStringsSuccess extends AgoraVideoState {
  AgoraVideoCleanInfoStringsSuccess({required this.infoString});
  final List<String> infoString;
  @override
  List<Object?> get props => [infoString];
}

class AgoraVideoJoinChannelSuccess extends AgoraVideoState {
  AgoraVideoJoinChannelSuccess({required this.uid, required this.channel});
  final String uid;
  final String channel;
  @override
  List<Object?> get props => [uid, channel];
}
