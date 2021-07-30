import 'package:equatable/equatable.dart';

class AgoraVideoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class JoinToChannel extends AgoraVideoEvent {
  JoinToChannel({required this.uid});
  final int uid;

  @override
  List<Object?> get props => [uid];
}

class UserOfflineChannel extends AgoraVideoEvent {
  UserOfflineChannel({required this.uid});
  final String uid;

  @override
  List<Object?> get props => [uid];
}

class UserRemoveChannel extends AgoraVideoEvent {
  UserRemoveChannel({required this.uid});
  final int uid;

  @override
  List<Object?> get props => [uid];
}

class UpdateInfoStringsList extends AgoraVideoEvent {
  UpdateInfoStringsList({required this.newText});
  final String newText;

  @override
  List<Object?> get props => [newText];
}

class ClearInfoStringsList extends AgoraVideoEvent {
  ClearInfoStringsList();

  @override
  List<Object?> get props => [];
}

class ClearUserList extends AgoraVideoEvent {
  ClearUserList();

  @override
  List<Object?> get props => [];
}

class MuteUnmute extends AgoraVideoEvent {
  MuteUnmute({required this.isMuted});
  final bool isMuted;
  @override
  List<Object?> get props => [isMuted];
}
