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

class AgoraVideoStringLeaveChannelSuccess extends AgoraVideoState {
  AgoraVideoStringLeaveChannelSuccess({required this.users});

  final List<int> users;
  @override
  List<Object?> get props => [users];
}

class AgoraVideoCleanInfoStringsSuccess extends AgoraVideoState {
  AgoraVideoCleanInfoStringsSuccess({required this.infoString});
  final List<String> infoString;
  @override
  List<Object?> get props => [infoString];
}

class AgoraVideoJoinChannelSuccess extends AgoraVideoState {
  AgoraVideoJoinChannelSuccess({required this.users});
  final List<int> users;
  @override
  List<Object?> get props => [users];
}

class AgoraVideoClearUserSuccess extends AgoraVideoState {
  AgoraVideoClearUserSuccess({required this.users});
  final List<int> users;
  @override
  List<Object?> get props => [users];
}

class AgoraVideoHandleMuteSuccess extends AgoraVideoState {
  AgoraVideoHandleMuteSuccess({required this.isMuted});
  final bool isMuted;
  @override
  List<Object?> get props => [isMuted];
}
