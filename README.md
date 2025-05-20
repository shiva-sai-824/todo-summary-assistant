# Todo Summary Assistant

![Project Banner](https://img.shields.io/badge/Todo-Summary_Assistant-blue)
![Status](https://img.shields.io/badge/Status-Active-brightgreen)
![License](https://img.shields.io/badge/License-MIT-green)

A full-stack application that helps you manage your to-do list, generate AI-powered summaries of pending tasks, and send these summaries to your team's Slack channel.

<p align="center">
  <img src="/api/placeholder/800/300" alt="Todo Summary Assistant Demo" />
</p>

## ✨ Features

- **Task Management**: Create, view, update, and delete to-do items
- **Status Tracking**: Mark tasks as completed or pending with visual indicators
- **AI-Powered Summaries**: Generate concise summaries of pending tasks using OpenAI's GPT
- **Slack Integration**: Send summaries directly to your configured Slack channel
- **Instant Feedback**: Visual confirmation for all user actions

## 🛠️ Tech Stack

| Component | Technology |
|-----------|------------|
| **Frontend** | React |
| **Backend** | Node.js + Express.js |
| **Database** | Supabase (PostgreSQL) |
| **AI Integration** | OpenAI API |
| **Messaging** | Slack Incoming Webhooks |

## 📂 Project Structure

```
todo-summary-assistant/
├── backend/           # Node.js/Express server
│   ├── controllers/   # Request handlers
│   ├── routes/        # API endpoints
│   ├── services/      # Business logic
│   ├── config/        # Configuration
│   ├── server.js      # Server entry point
│   └── .env           # Environment variables
│
├── frontend/          # React application
│   ├── public/        # Static files
│   ├── src/           # React components
│   │   ├── components/# UI components
│   │   ├── services/  # API calls
│   │   └── App.js     # Main component
│   └── .env           # Frontend environment variables
│
└── README.md          # Project documentation
```

## 🚀 Getting Started

### Prerequisites

- Node.js (v16+)
- npm or yarn
- Git
- Supabase account
- OpenAI API key
- Slack workspace with permissions to create webhooks

### Setup Instructions

#### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/todo-summary-assistant.git
cd todo-summary-assistant
```

#### 2. Supabase Setup

1. Create a new project on [Supabase](https://supabase.com/)
2. Navigate to the SQL Editor and create the todos table:

```sql
CREATE TABLE todos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    task TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT now()
);
```

3. From Project Settings > API, copy your Project URL and anon public key

#### 3. Slack Webhook Setup

1. Go to your Slack workspace's App Directory
2. Search for and add "Incoming WebHooks"
3. Click "Add Configuration"
4. Select a channel for the summaries
5. Copy the generated Webhook URL

#### 4. Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file with the following variables:
```
PORT=3001
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
OPENAI_API_KEY=your_openai_api_key
SLACK_WEBHOOK_URL=your_slack_webhook_url
```

4. Start the backend server:
```bash
npm start
```

#### 5. Frontend Setup

1. Navigate to the frontend directory:
```bash
cd ../frontend
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file:
```
REACT_APP_API_BASE_URL=http://localhost:3001/api
```

4. Start the frontend development server:
```bash
npm start
```

5. Access the application at `http://localhost:3000`

## 📱 Usage

### Managing To-Dos

1. **Create a task**: Enter task description in the input field and click "Add Task"
2. **View tasks**: All tasks are displayed in the main interface
3. **Update status**: Click the checkbox to mark a task as completed
4. **Delete task**: Click the trash icon to remove a task

### Generating Summaries

1. Click the "Generate Summary" button
2. The application will:
   - Fetch all pending tasks
   - Send them to OpenAI for summarization
   - Display the summary on screen
   - Send the summary to Slack

### Slack Integration

When you click "Send to Slack", the current summary will be:
- Formatted as a message with task categories
- Posted to your configured Slack channel
- Include a timestamp and total task count

## 🏗️ Architecture

This application follows a classic client-server architecture:

- **Frontend Layer**: React components for user interaction
- **API Layer**: Express endpoints for resource management
- **Service Layer**: Business logic for task operations and integration
- **Data Layer**: Supabase for data persistence

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/todos` | GET | Retrieve all to-do items |
| `/api/todos` | POST | Create a new to-do item |
| `/api/todos/:id` | PUT | Update an existing to-do |
| `/api/todos/:id` | DELETE | Remove a to-do |
| `/api/summary` | GET | Generate summary of pending to-dos |
| `/api/summary/slack` | POST | Send summary to Slack |

## 🔒 Security Considerations

- API keys and sensitive URLs are stored in environment variables
- Supabase secures database connections
- Consider implementing authentication for production use

## 🌐 Deployment

### Frontend Deployment

The React frontend can be deployed to platforms like:
- Vercel
- Netlify
- Firebase Hosting
- GitHub Pages

```bash
# Example for Netlify
npm run build
netlify deploy --prod
```

### Backend Deployment

The Node.js server can be deployed to:
- Heroku
- Render
- Fly.io
- AWS EC2/Lambda
- Google Cloud Run

```bash
# Example for Heroku
heroku create
git push heroku main
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Acknowledgments

- Built with [React](https://reactjs.org/)
- Database powered by [Supabase](https://supabase.com/)
- AI capabilities by [HuggingFace]([https://openai.com/](https://huggingface.co/))
- Notifications via [Slack API](https://api.slack.com/)
