# SkillSeeker AI Chatbot

An AI-powered mobile chatbot application built with Flutter and Node.js, integrating OpenAI's API for intelligent conversations.

## Features

- 💬 Real-time chat interface with AI responses
- 📄 Document upload and analysis (PDF, DOC, DOCX, TXT)
- ❓ Frequently Asked Questions dropdown
- 👍👎 Support/Don't Support feedback system
- 🎨 Clean, modern UI matching the provided wireframe
- 📱 Cross-platform mobile app (iOS & Android)

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

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file and add your OpenAI API key:
   ```
   OPENAI_API_KEY=your_openai_api_key_here
   PORT=3000
   ```

4. Start the server:
   ```bash
   npm start
   ```
   
   For development with auto-reload:
   ```bash
   npm run dev
   ```

The backend will run on `http://localhost:3000`

### Flutter App Setup

1. Make sure you have Flutter installed. Check with:
   ```bash
   flutter doctor
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Update the backend URL in `lib/services/chat_service.dart`:
   - For Android emulator: `http://10.0.2.2:3000`
   - For iOS simulator: `http://localhost:3000`
   - For physical device: Use your computer's IP address

4. Run the app:
   ```bash
   flutter run
   ```


## Quick Start
Start backend
node server.js
Start flutter
flutter emulators --launch Medium_Phone_API_36.1
timeout /t 15 /nobreak
flutter run
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
