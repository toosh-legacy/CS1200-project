const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const OpenAI = require('openai');
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const pdfParse = require('pdf-parse');
const mammoth = require('mammoth');

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize OpenAI
const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

// Middleware
app.use(cors());
app.use(express.json());

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    const uploadDir = './uploads';
    try {
      await fs.mkdir(uploadDir, { recursive: true });
      cb(null, uploadDir);
    } catch (error) {
      cb(error, null);
    }
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    const allowedExtensions = /\.(pdf|doc|docx|txt)$/i;
    const allowedMimeTypes = [
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'text/plain',
      'application/octet-stream' // Android sometimes sends files with generic mimetype
    ];
    
    const extname = allowedExtensions.test(file.originalname.toLowerCase());
    const mimetype = allowedMimeTypes.includes(file.mimetype);
    
    console.log('File upload attempt:', {
      originalname: file.originalname,
      mimetype: file.mimetype,
      extname,
      mimetypeMatch: mimetype
    });
    
    if (extname || mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Only PDF, DOC, DOCX, and TXT files are allowed!'));
    }
  }
});

// In-memory storage for feedback (in production, use a database)
const feedbackStorage = [];

// Helper function to extract text from files
async function extractTextFromFile(filePath, mimetype) {
  try {
    console.log('Extracting text from:', filePath, 'mimetype:', mimetype);
    const fileBuffer = await fs.readFile(filePath);
    console.log('File buffer size:', fileBuffer.length);
    
    // Check file extension as fallback for mimetype
    const ext = path.extname(filePath).toLowerCase();
    console.log('File extension:', ext);
    
    if (mimetype === 'application/pdf' || ext === '.pdf') {
      const data = await pdfParse(fileBuffer);
      return data.text;
    } else if (mimetype === 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' || 
               mimetype === 'application/msword' ||
               ext === '.docx' || ext === '.doc') {
      const result = await mammoth.extractRawText({ buffer: fileBuffer });
      return result.value;
    } else if (mimetype === 'text/plain' || ext === '.txt' || mimetype === 'application/octet-stream') {
      // Handle text files including those with generic mimetype
      const text = fileBuffer.toString('utf-8');
      console.log('Extracted text length:', text.length);
      return text;
    }
    
    console.log('No handler for mimetype:', mimetype, 'extension:', ext);
    return null;
  } catch (error) {
    console.error('Error extracting text:', error);
    return null;
  }
}

// Routes

// Health check
app.get('/', (req, res) => {
  res.json({ status: 'SkillSeeker API is running' });
});

// Chat endpoint
app.post('/api/chat', async (req, res) => {
  try {
    const { message, conversationHistory } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    // Build messages array for OpenAI
    const messages = [
      {
        role: 'system',
        content: `You are SkillSeeker AI, a career development expert specializing in resume analysis and professional growth advice. 

Your expertise includes:
- Analyzing and critiquing resumes with specific, actionable feedback
- Providing career development guidance and job search strategies
- Offering interview preparation tips and salary negotiation advice
- Suggesting skills to develop for career advancement
- Reviewing job descriptions and matching them to candidate profiles

When analyzing resumes:
1. Evaluate formatting, structure, and readability
2. Assess content quality, achievements, and quantifiable results
3. Check for ATS (Applicant Tracking System) optimization
4. Identify missing keywords and skills
5. Suggest improvements for impact statements
6. Provide specific examples of how to rewrite weak sections

Keep responses under 200 words. Be direct, professional, and constructive. Focus on actionable advice.`
      },
      ...conversationHistory,
      {
        role: 'user',
        content: message
      }
    ];

    // Call OpenAI API
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: messages,
      max_tokens: 250, // Approximately 200 words
      temperature: 0.7,
    });

    const response = completion.choices[0].message.content;

    res.json({ response });
  } catch (error) {
    console.error('Error in chat endpoint:', error);
    res.status(500).json({ 
      error: 'Failed to get response from AI',
      details: error.message 
    });
  }
});

// File upload and analysis endpoint
app.post('/api/upload', upload.single('file'), async (req, res) => {
  try {
    console.log('Upload endpoint hit');
    if (!req.file) {
      console.log('No file in request');
      return res.status(400).json({ error: 'No file uploaded' });
    }

    console.log('File received:', {
      filename: req.file.filename,
      originalname: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size,
      path: req.file.path
    });

    const filePath = req.file.path;
    const mimetype = req.file.mimetype;

    // Extract text from file
    const extractedText = await extractTextFromFile(filePath, mimetype);

    console.log('Extracted text:', extractedText ? `${extractedText.substring(0, 100)}...` : 'null');

    if (!extractedText) {
      // Clean up file
      await fs.unlink(filePath);
      return res.status(400).json({ error: 'Could not extract text from file' });
    }

    // Analyze with OpenAI - specialized for resume critique
    const completion = await openai.chat.completions.create({
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'system',
          content: `You are a career development expert specializing in resume analysis. 

Analyze resumes by:
1. Evaluating overall structure and formatting
2. Assessing content quality and impact statements
3. Identifying missing keywords and skills
4. Checking ATS optimization
5. Providing specific, actionable improvements

Keep critiques under 200 words. Be constructive and specific.`
        },
        {
          role: 'user',
          content: `Analyze and critique this resume. Provide specific feedback and actionable improvements:\n\n${extractedText.substring(0, 3000)}`
        }
      ],
      max_tokens: 250, // Approximately 200 words
      temperature: 0.7,
    });

    const analysis = completion.choices[0].message.content;

    // Clean up uploaded file
    await fs.unlink(filePath);

    res.json({
      success: true,
      filename: req.file.originalname,
      analysis: analysis
    });
  } catch (error) {
    console.error('Error in upload endpoint:', error);
    
    // Clean up file if it exists
    if (req.file) {
      try {
        await fs.unlink(req.file.path);
      } catch (unlinkError) {
        console.error('Error deleting file:', unlinkError);
      }
    }
    
    res.status(500).json({ 
      error: 'Failed to process file',
      details: error.message 
    });
  }
});

// Feedback endpoint
app.post('/api/feedback', async (req, res) => {
  try {
    const { messageId, feedbackType, message, timestamp } = req.body;

    if (!messageId || !feedbackType) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const feedbackEntry = {
      id: Date.now().toString(),
      messageId,
      feedbackType,
      message,
      timestamp: timestamp || new Date().toISOString(),
    };

    feedbackStorage.push(feedbackEntry);

    res.json({ 
      success: true,
      message: 'Feedback recorded successfully' 
    });
  } catch (error) {
    console.error('Error in feedback endpoint:', error);
    res.status(500).json({ 
      error: 'Failed to record feedback',
      details: error.message 
    });
  }
});

// Get all feedback (for admin page)
app.get('/api/feedback', (req, res) => {
  try {
    res.json({ 
      feedback: feedbackStorage,
      total: feedbackStorage.length
    });
  } catch (error) {
    console.error('Error retrieving feedback:', error);
    res.status(500).json({ 
      error: 'Failed to retrieve feedback',
      details: error.message 
    });
  }
});

// Get feedback by type
app.get('/api/feedback/:type', (req, res) => {
  try {
    const { type } = req.params;
    const filtered = feedbackStorage.filter(f => f.feedbackType === type);
    
    res.json({ 
      feedback: filtered,
      total: filtered.length
    });
  } catch (error) {
    console.error('Error retrieving feedback:', error);
    res.status(500).json({ 
      error: 'Failed to retrieve feedback',
      details: error.message 
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
  console.log('Make sure to set your OPENAI_API_KEY in the .env file');
});
