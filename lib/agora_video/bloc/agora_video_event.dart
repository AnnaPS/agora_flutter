import 'package:equatable/equatable.dart';

class AgoraVideoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class JoinToChannel extends AgoraVideoEvent {
  JoinToChannel({required this.uid, required this.channel});
  final String uid;
  final String channel;

  @override
  List<Object?> get props => [uid, channel];
}

class LeaveChannel extends AgoraVideoEvent {}

class UserOfflineChannel extends AgoraVideoEvent {
  UserOfflineChannel({required this.uid});
  final String uid;

  @override
  List<Object?> get props => [uid];
}

class UserJoinedChannel extends AgoraVideoEvent {
  UserJoinedChannel({required this.uid});
  final String uid;

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
