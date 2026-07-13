import 'chat_message_model.dart';
import '../../tasks/models/user_model.dart';

class ChatResponseModel {
  final List<ChatMessageModel> messages;
  final List<UserModel> participants;

  ChatResponseModel({
    required this.messages,
    required this.participants,
  });

  factory ChatResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List?;
    final meta = json['meta'] as Map<String, dynamic>?;
    final participantsData = meta?['participants'] as List?;

    final messagesList = (data ?? [])
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final participantsList = (participantsData ?? [])
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ChatResponseModel(
      messages: messagesList,
      participants: participantsList,
    );
  }
}
