import 'package:firebase_ai/firebase_ai.dart';

class ChatRepository {
  GenerativeModel? _model;
  ChatSession? _chatSession;

  /// Initialise a new chat session with a system prompt that includes
  /// the user's portfolio context.
  void initializeChat(String systemPrompt) {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3-flash-preview',
      systemInstruction: Content.system(systemPrompt),
      tools: [Tool.googleSearch()],
    );
    _chatSession = _model!.startChat();
  }

  /// Send a message and yield streamed response chunks.
  Stream<String> sendMessageStream(String message) async* {
    if (_chatSession == null) {
      throw Exception('Chat not initialized');
    }
    final response =
        _chatSession!.sendMessageStream(Content.text(message));
    await for (final chunk in response) {
      if (chunk.text != null) yield chunk.text!;
    }
  }

  /// Discard the current session so a fresh one can be created.
  void resetChat() {
    _chatSession = null;
    _model = null;
  }

  bool get isInitialized => _chatSession != null;
}
