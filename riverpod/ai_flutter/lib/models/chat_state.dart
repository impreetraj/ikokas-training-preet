import 'message_model.dart';

class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;

  ChatState({
    required this.messages,
    required this.isLoading,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
