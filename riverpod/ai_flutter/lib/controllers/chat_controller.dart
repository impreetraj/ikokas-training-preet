import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../models/chat_state.dart';
import '../services/gemini_service.dart';

class ChatController extends Notifier<ChatState> {
  @override
  ChatState build() {
    return ChatState(messages: [], isLoading: false);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = MessageModel(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    final geminiService = ref.read(geminiServiceProvider);
    final response = await geminiService.getChatResponse(text);

    final aiMessage = MessageModel(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, aiMessage],
      isLoading: false,
    );
  }
}

final chatProvider = NotifierProvider<ChatController, ChatState>(() {
  return ChatController();
});

