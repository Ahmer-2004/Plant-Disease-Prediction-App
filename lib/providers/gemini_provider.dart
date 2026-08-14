import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiProvider with ChangeNotifier {
  GenerativeModel? _model;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  List<ChatMessage> _messages = [];

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ChatMessage> get messages => _messages;

  Future<void> initializeGemini() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_gemini_api_key_here') {
        throw Exception('GEMINI_API_KEY not found in .env file. Please add your API key.');
      }

      // Initialize Gemini model
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );

      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize Gemini: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String message, {String? diseaseInfo}) async {
    if (!_isInitialized) {
      _error = 'Gemini not initialized';
      notifyListeners();
      return;
    }

    // Prevent sending empty messages
    if (message.trim().isEmpty) {
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Add user message
      _messages.add(ChatMessage(
        text: message.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));

      // Create context-aware prompt
      String prompt = _createPrompt(message.trim(), diseaseInfo);

      // Generate response
      var response = await _model!.generateContent([Content.text(prompt)]);
      var responseText = response.text ?? 'Sorry, I could not generate a response.';

      // Add bot response
      _messages.add(ChatMessage(
        text: responseText.trim(),
        isUser: false,
        timestamp: DateTime.now(),
      ));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message: $e';
      
      // Inject the error directly into the chat list so it doesn't fail silently
      _messages.add(ChatMessage(
        text: '❌ Connection Error:\n${e.toString().replaceAll('Exception:', '')}',
        isUser: false,
        timestamp: DateTime.now(),
      ));

      _isLoading = false;
      notifyListeners();
    }
  }

  String _createPrompt(String message, String? diseaseInfo) {
    String basePrompt = '''
You are a helpful plant health assistant. Keep responses SHORT, SPECIFIC, and USER-FRIENDLY.

Guidelines:
- Maximum 2-3 sentences per response
- Use simple, clear language
- Focus on the most important information
- Be practical and actionable
- Avoid lengthy explanations unless specifically asked

Context: ${diseaseInfo != null ? 'User detected: $diseaseInfo' : 'General plant health question'}

Answer the user's question directly and concisely.
''';

    // If specific disease is detected, provide more detailed initial response
    if (diseaseInfo != null && (message.toLowerCase().contains('help') || message.toLowerCase().contains('disease'))) {
      basePrompt = '''
You are a plant health expert. The user has detected: $diseaseInfo

Provide a helpful response about this specific disease including:
- Brief symptoms description
- Quick treatment options  
- Prevention tips

Keep it concise (2-3 sentences) and practical. Focus on immediate actions they can take.
''';
    }

    return '$basePrompt\n\nUser question: $message';
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  void addWelcomeMessage() {
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
        text: "Hi! I'm your plant health assistant. Ask me anything about plant diseases or care!",
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
