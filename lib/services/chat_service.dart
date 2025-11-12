import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class ChatService extends ChangeNotifier {
  final List<Message> _messages = [];
  bool _isLoading = false;
  
  // Update this to your backend URL
  // For Android Emulator, use 10.0.2.2 instead of localhost
  final String _baseUrl = 'http://10.0.2.2:3000';

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;

  // Frequently asked questions - Career Development focused
  final List<String> faqs = [
    'Can you analyze my resume?',
    'How do I improve my resume?',
    'What are key skills for my career?',
    'Help me prepare for an interview',
    'How do I negotiate salary?',
    'What career path should I take?',
    'Tips for LinkedIn profile optimization',
  ];

  Future<void> sendMessage(String text, {String? filePath}) async {
    // Add user message
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'conversationHistory': _messages
              .where((m) => m.feedback != 'dont_support')
              .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: data['response'],
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(aiMessage);
      } else {
        _addErrorMessage('Failed to get response. Please try again.');
      }
    } catch (e) {
      _addErrorMessage('Error: ${e.toString()}');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadAndAnalyzeFile(String filePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Uploading file from: $filePath');
      debugPrint('Backend URL: $_baseUrl/api/upload');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/upload'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Upload response status: ${response.statusCode}');
      debugPrint('Upload response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Add user message about upload
        final userMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '📄 Uploaded resume: ${filePath.split('/').last.split('\\').last}',
          isUser: true,
          timestamp: DateTime.now(),
        );
        _messages.add(userMessage);

        // Add AI response with file analysis
        final aiMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: '📊 Resume Analysis:\n\n${data['analysis'] ?? 'Resume uploaded successfully.'}',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(aiMessage);
      } else {
        _addErrorMessage('Failed to upload file. Server responded with status ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      _addErrorMessage('Error uploading file: ${e.toString()}');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitFeedback(String messageId, String feedbackType) async {
    // Update local message
    final messageIndex = _messages.indexWhere((m) => m.id == messageId);
    if (messageIndex != -1) {
      _messages[messageIndex].feedback = feedbackType;
      notifyListeners();
    }

    // Send to backend
    try {
      await http.post(
        Uri.parse('$_baseUrl/api/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messageId': messageId,
          'feedbackType': feedbackType,
          'message': _messages[messageIndex].text,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
    } catch (e) {
      debugPrint('Error submitting feedback: $e');
    }
  }

  void _addErrorMessage(String error) {
    final errorMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: error,
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(errorMessage);
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
