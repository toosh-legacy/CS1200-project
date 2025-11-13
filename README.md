# SkillSeeker AI Chatbot

An AI-powered mobile chatbot application built with Flutter and Node.js, integrating OpenAI's API for intelligent conversations.

## Features

- 💬 Real-time chat interface with AI responses
- 📄 Document upload and analysis (PDF, DOC, DOCX, TXT)
- 🎯 Career development focused AI with resume analysis
- ❓ Frequently Asked Questions dropdown
- 👍👎 Support/Don't Support feedback system
- 🎨 Clean, modern UI matching the provided wireframe
- 📱 Cross-platform support (Web, iOS, Android, Windows)
- 🤖 200-word limit AI responses for concise feedback

## Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider** - State management
- **HTTP** - API communication
- **File Picker** - Document selection

### Backend
- **Node.js** - Runtime environment
- **Express** - Web framework
- **OpenAI API** - AI chat completions
- **Multer** - File upload handling
- **pdf-parse** - PDF text extraction
- **mammoth** - Word document parsing



## Setup Instructions

### Prerequisites
- Flutter SDK installed ([Installation Guide](https://docs.flutter.dev/get-started/install))
- Node.js and npm installed
- OpenAI API key ([Get one here](https://platform.openai.com/api-keys))

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file in the backend directory and add your OpenAI API key:
   ```
   OPENAI_API_KEY=your_openai_api_key_here
   PORT=3000
   ```

4. Start the server:
   ```bash
   node server.js
   ```
   
   The backend will run on `http://localhost:3000`

### Flutter App Setup

1. Make sure Flutter is properly installed:
   ```bash
   flutter doctor
   ```

2. From the project root directory, install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. **Important**: The backend URL is already configured in `lib/services/chat_service.dart`:
   - For **Web**: `http://localhost:3000` (default)
   - For **Android emulator**: Change to `http://10.0.2.2:3000`
   - For **iOS simulator**: `http://localhost:3000`
   - For **physical device**: Use your computer's IP address (e.g., `http://192.168.1.x:3000`)

## Running the App

### Run on Web (Recommended for Development)

1. Make sure the backend server is running in a separate terminal
2. Run the Flutter app:
   ```bash
   flutter run -d chrome
   ```
3. To view in mobile format, press F12 in Chrome, then Ctrl+Shift+M to toggle device toolbar

### Run on Android Emulator

1. Update backend URL in `lib/services/chat_service.dart` to `http://10.0.2.2:3000`
2. Start an Android emulator
3. Make sure the backend server is running
4. Run:
   ```bash
   flutter run
   ```

### Run on Physical Device

1. Find your computer's IP address:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`
2. Update backend URL in `lib/services/chat_service.dart` to `http://YOUR_IP:3000`
3. Connect your device and enable USB debugging
4. Make sure the backend server is running
5. Run:
   ```bash
   flutter run
   ```

## Quick Start (All Platforms)

1. **Terminal 1** - Start backend:
   ```bash
   cd backend
   node server.js
   ```

2. **Terminal 2** - Run Flutter app:
   ```bash
   flutter run -d chrome
   ```

That's it! The app should open in Chrome and be ready to use.

## API Endpoints

### POST /api/chat
Send a message and get AI response
```json
{
  "message": "How does this work?",
  "conversationHistory": []
}
```

### POST /api/upload
Upload and analyze a document
- Multipart form data with file field

### POST /api/feedback
Submit feedback for a message
```json
{
  "messageId": "123",
  "feedbackType": "support",
  "message": "AI response text",
  "timestamp": "2025-11-11T00:00:00.000Z"
}
```

### GET /api/feedback
Get all feedback (for admin)

### GET /api/feedback/:type
Get feedback by type (support/dont_support)

## Features in Detail

### Chat Interface
- User and AI messages with distinct styling
- Timestamps for all messages
- Auto-scroll to latest message
- Loading indicator during AI processing

### FAQ Dropdown
- Quick access to common questions
- Toggleable with arrow button
- Pre-populated questions that can be customized

### File Upload
- Support for PDF, DOC, DOCX, and TXT files
- AI analysis of document content
- 10MB file size limit
- Automatic text extraction and summarization

### Feedback System
- Support/Don't Support buttons on AI messages
- Visual feedback when selected
- Stored in backend for admin review
- Filters unsupported messages from conversation history

## Configuration

### Customizing FAQ Questions
Edit the `faqs` list in `lib/services/chat_service.dart`:
```dart
final List<String> faqs = [
  'Your question here',
  'Another question',
  // Add more...
];
```

### Changing AI Behavior
Modify the system message in `backend/server.js`:
```javascript
{
  role: 'system',
  content: 'Your custom instructions here'
}
```

### Adjusting Response Length
Change `max_tokens` in the OpenAI API calls in `server.js`

## Development Notes

- The backend uses in-memory storage for feedback. For production, integrate a database (MongoDB, PostgreSQL, etc.)
- Add authentication for the admin feedback endpoint
- Consider implementing rate limiting for API calls
- Add error boundaries and better error handling for production
- Implement message persistence using local storage or database

## Troubleshooting

### Backend not connecting from Flutter app
- Check firewall settings
- Verify the correct IP address/URL is used
- Ensure backend is running
- Check for CORS issues

### OpenAI API errors
- Verify API key is correct in `.env`
- Check OpenAI account has available credits
- Review rate limits and quotas

### File upload failing
- Check file size is under 10MB
- Verify file type is supported
- Ensure uploads directory has write permissions

## License

MIT

## Support

For issues and questions, please create an issue in the repository.
