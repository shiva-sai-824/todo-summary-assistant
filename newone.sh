#!/bin/bash

echo "Creating project structure for Todo Summary Assistant..."

# Root project directory
PROJECT_ROOT="todo-summary-assistant"
mkdir -p "$PROJECT_ROOT"
cd "$PROJECT_ROOT" || exit

# --- README.md at root ---
echo "Creating README.md..."
cat << 'EOF' > README.md
# Todo Summary Assistant

A full-stack application that allows users to manage personal to-do items, summarize pending todos using an LLM (OpenAI), and send the summary to a Slack channel.

## Features

*   Create, Read, Update, Delete (CRUD) to-do items.
*   Mark to-dos as completed or pending.
*   Generate a summary of all *pending* to-do items using OpenAI's GPT model.
*   Send the generated summary to a configured Slack channel via Incoming Webhook.
*   Display success/failure messages for operations.

## Tech Stack

*   **Frontend:** React
*   **Backend:** Node.js with Express.js
*   **Database:** Supabase (PostgreSQL)
*   **LLM Integration:** OpenAI API
*   **Slack Integration:** Slack Incoming Webhooks

## Project Structure

\`\`\`
todo-summary-assistant/
├── backend/        # Node.js/Express backend
├── frontend/       # React frontend
└── README.md
\`\`\`

## Setup Instructions

### Prerequisites

*   Node.js (v16 or later recommended)
*   npm or yarn
*   Git
*   A Supabase account
*   An OpenAI API key
*   A Slack workspace and permission to add Incoming Webhooks

### 1. Clone the Repository (or use this generated structure)

If you used the \`create_project.sh\` script, you can skip cloning. Otherwise:
\`\`\`bash
git clone <your-repository-url>
cd todo-summary-assistant
\`\`\`

### 2. Supabase Setup

1.  Go to [Supabase](https://supabase.com/) and create a new project.
2.  Once your project is ready, go to the **SQL Editor** (or Table Editor).
3.  Create a new table named \`todos\` with the following schema:
    *   \`id\`: \`uuid\` (Primary Key, Default: \`uuid_generate_v4()\`)
    *   \`task\`: \`text\` (Not Null)
    *   \`is_completed\`: \`boolean\` (Default: \`false\`)
    *   \`created_at\`: \`timestamp with time zone\` (Default: \`now()\`)

    You can use the following SQL:
    \`\`\`sql
    CREATE TABLE todos (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        task TEXT NOT NULL,
        is_completed BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMPTZ DEFAULT now()
    );
    -- Enable RLS (Row Level Security) - Recommended for production
    -- For this project, ensure anon key has select, insert, update, delete permissions if RLS is not deeply configured.
    -- Go to Authentication -> Policies on the 'todos' table.
    -- If you keep RLS disabled for simplicity for this assignment, ensure your anon key has sufficient privileges in your Supabase settings.
    -- To allow anon key to do everything for quick setup (NOT recommended for production):
    -- You might need to create policies if RLS is enabled by default or you enable it.
    -- Example policies for anon role:
    -- CREATE POLICY "Enable all access for anon" ON todos FOR ALL TO anon USING (true) WITH CHECK (true);
    \`\`\`
4.  Find your Supabase Project URL and \`anon\` public key:
    *   Go to **Project Settings** (Gear icon).
    *   Click on **API**.
    *   You'll find the **Project URL** and the **Project API keys** (use the \`anon\` public key).

### 3. Backend Setup

1.  Navigate to the \`backend\` directory:
    \`\`\`bash
    cd backend
    \`\`\`
2.  Initialize npm and install dependencies:
    \`\`\`bash
    npm init -y
    npm install express cors dotenv @supabase/supabase-js openai axios uuid
    npm install --save-dev nodemon 
    # or using yarn
    # yarn init -y
    # yarn add express cors dotenv @supabase/supabase-js openai axios uuid
    # yarn add --dev nodemon
    \`\`\`
3.  Create a \`.env\` file by copying \`.env.example\` (this script already created .env.example):
    \`\`\`bash
    cp .env.example .env
    \`\`\`
4.  Edit \`backend/.env\` and fill in your credentials:
    *   \`PORT\`: The port for the backend server (e.g., \`3001\`).
    *   \`SUPABASE_URL\`: Your Supabase project URL.
    *   \`SUPABASE_ANON_KEY\`: Your Supabase \`anon\` public key.
    *   \`OPENAI_API_KEY\`: Your OpenAI API key. Get it from [OpenAI Platform](https://platform.openai.com/account/api-keys).
    *   \`SLACK_WEBHOOK_URL\`: Your Slack Incoming Webhook URL (see Slack Setup below).

### 4. Slack Incoming Webhook Setup

1.  Go to your Slack App Directory or \`https://<your-workspace>.slack.com/apps/manage\`.
2.  Search for "Incoming WebHooks" and add it to your Slack.
3.  Click "Add Configuration".
4.  Choose a channel where the summaries will be posted and click "Add Incoming WebHooks integration".
5.  Copy the **Webhook URL**. This is what you'll put in \`backend/.env\` for \`SLACK_WEBHOOK_URL\`.

### 5. Frontend Setup

1.  Navigate to the \`frontend\` directory:
    \`\`\`bash
    cd ../frontend
    # (If you are in the root project directory, just \`cd frontend\`)
    \`\`\`
2.  Initialize React app and install dependencies:
    \`\`\`bash
    npx create-react-app . 
    # or yarn create react-app .
    # This will create a new React app in the current directory.
    # The script has already placed component files. You might need to merge or adjust.
    # A simpler approach IF YOU RUN THIS SCRIPT is to just install axios after:
    # npm install axios 
    # or yarn add axios
    # (Then manually update App.js etc. if create-react-app overwrites them)
    \`\`\`
    **Note:** Using `create-react-app .` *after* this script has run might overwrite `App.js`, `index.js`, etc.
    A safer flow if using this script:
    a. Run this script.
    b. `cd frontend`
    c. `npm init -y` (or `yarn init -y`)
    d. `npm install react react-dom react-scripts axios @testing-library/jest-dom @testing-library/react @testing-library/user-event web-vitals`
    e. Manually create `public/index.html` and `public/manifest.json` or copy from a new CRA project.
    f. Update `package.json` scripts section to match a CRA project.

3.  Create a \`.env\` file by copying \`.env.example\` (this script already created .env.example):
    \`\`\`bash
    cp .env.example .env
    \`\`\`
4.  Edit \`frontend/.env\` (if necessary):
    *   \`REACT_APP_API_BASE_URL\`: Should point to your backend API (e.g., \`http://localhost:3001/api\`). This is pre-filled in \`.env.example\`.

### 6. Running the Application

1.  **Start the Backend Server:**
    Open a terminal, navigate to the \`backend\` directory, and run:
    \`\`\`bash
    npm start
    # or for development with nodemon:
    # npm run dev
    \`\`\`
    The backend should start on the port specified in \`backend/.env\` (e.g., \`http://localhost:3001\`).

2.  **Start the Frontend Development Server:**
    Open another terminal, navigate to the \`frontend\` directory, and run:
    \`\`\`bash
    npm start
    # or
    # yarn start
    \`\`\`
    The React app should open in your browser (usually \`http://localhost:3000\`).

## Design and Architecture Decisions

*   **Separation of Concerns:** The frontend (React) is responsible for the UI and user interaction, while the backend (Node.js/Express) handles business logic, database interaction, and third-party API integrations.
*   **RESTful API:** The backend exposes RESTful endpoints for CRUD operations on todos and for triggering the summarization process.
*   **Supabase as BaaS:** Supabase simplifies backend development by providing a PostgreSQL database, authentication (not used here explicitly beyond anon key), and an easy-to-use JavaScript client library.
*   **LLM for Summarization:** OpenAI's API is used for its powerful text summarization capabilities. The prompt is constructed to guide the LLM in generating a meaningful summary of pending tasks.
*   **Slack for Notifications:** Incoming Webhooks provide a simple way to push messages (the todo summary) into a Slack channel.
*   **Environment Variables:** Sensitive information (API keys, URLs) is managed using environment variables for security and configurability.
*   **Error Handling:** Basic error handling is implemented on both frontend and backend to inform the user and log issues.
*   **User Experience:** The frontend aims to provide immediate feedback for actions (loading states, success/failure messages).

## (Optional) Deployment

*   **Frontend:** Can be deployed to static hosting platforms like Vercel, Netlify, Firebase Hosting, or GitHub Pages. Remember to configure \`REACT_APP_API_BASE_URL\` to point to your deployed backend URL.
*   **Backend:** Can be deployed to platforms like Heroku, Render, Fly.io, or a cloud provider's service (e.g., AWS EC2/Lambda, Google Cloud Run). Ensure all environment variables are set in the deployment environment.
*   **Supabase:** Is already cloud-hosted.
EOF

# --- Backend Setup ---
echo "Setting up backend..."
mkdir -p backend
cd backend || exit

echo "Creating backend/package.json..."
cat << 'EOF' > package.json
{
  "name": "backend",
  "version": "1.0.0",
  "description": "Backend for Todo Summary Assistant",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    "@supabase/supabase-js": "^2.39.0",
    "axios": "^1.6.2",
    "cors": "^2.8.5",
    "dotenv": "^16.3.1",
    "express": "^4.18.2",
    "openai": "^4.20.1",
    "uuid": "^9.0.1"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  }
}
EOF

echo "Creating backend/.env.example..."
cat << 'EOF' > .env.example
PORT=3001
SUPABASE_URL="YOUR_SUPABASE_URL"
SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
OPENAI_API_KEY="YOUR_OPENAI_API_KEY"
SLACK_WEBHOOK_URL="YOUR_SLACK_WEBHOOK_URL"
EOF

echo "Creating backend/server.js..."
cat << 'EOF' > server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
const OpenAI = require('openai');
const axios = require('axios');
const { v4: uuidv4 } = require('uuid');

const app = express();
const port = process.env.PORT || 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Supabase Client
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
if (!supabaseUrl || !supabaseAnonKey) {
    console.error("Supabase URL or Anon Key is missing. Check your .env file.");
    process.exit(1);
}
const supabase = createClient(supabaseUrl, supabaseAnonKey);

// OpenAI Client
const openaiApiKey = process.env.OPENAI_API_KEY;
if (!openaiApiKey) {
    console.error("OpenAI API Key is missing. Check your .env file.");
    process.exit(1);
}
const openai = new OpenAI({
    apiKey: openaiApiKey,
});

// Slack Webhook URL
const slackWebhookUrl = process.env.SLACK_WEBHOOK_URL;
if (!slackWebhookUrl) {
    console.warn("Slack Webhook URL is missing. Summaries won't be sent to Slack.");
}

// --- API Endpoints ---

// GET /api/todos – Fetch all todos
app.get('/api/todos', async (req, res) => {
    try {
        const { data, error } = await supabase
            .from('todos')
            .select('*')
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.json(data);
    } catch (error) {
        console.error('Error fetching todos:', error.message);
        res.status(500).json({ error: 'Failed to fetch todos', details: error.message });
    }
});

// POST /api/todos – Add a new todo
app.post('/api/todos', async (req, res) => {
    const { task } = req.body;
    if (!task || typeof task !== 'string' || task.trim() === '') {
        return res.status(400).json({ error: 'Task content is required and must be a non-empty string.' });
    }

    try {
        const newTodo = {
            task: task.trim(),
            is_completed: false,
        };

        const { data, error } = await supabase
            .from('todos')
            .insert([newTodo])
            .select()
            .single(); 

        if (error) throw error;
        res.status(201).json(data);
    } catch (error) {
        console.error('Error adding todo:', error.message);
        res.status(500).json({ error: 'Failed to add todo', details: error.message });
    }
});

// PUT /api/todos/:id – Update a todo (for editing task or marking complete)
app.put('/api/todos/:id', async (req, res) => {
    const { id } = req.params;
    const { task, is_completed } = req.body;

    if (task === undefined && is_completed === undefined) {
        return res.status(400).json({ error: 'No update data provided (task or is_completed).' });
    }
    if (task !== undefined && (typeof task !== 'string' || task.trim() === '')) {
        return res.status(400).json({ error: 'Task content must be a non-empty string if provided.' });
    }
     if (is_completed !== undefined && typeof is_completed !== 'boolean') {
        return res.status(400).json({ error: 'is_completed must be a boolean if provided.' });
    }

    const updates = {};
    if (task !== undefined) updates.task = task.trim();
    if (is_completed !== undefined) updates.is_completed = is_completed;

    try {
        const { data, error } = await supabase
            .from('todos')
            .update(updates)
            .eq('id', id)
            .select()
            .single();

        if (error) throw error;
        if (!data) return res.status(404).json({ error: 'Todo not found' });
        res.json(data);
    } catch (error) {
        console.error('Error updating todo:', error.message);
        res.status(500).json({ error: 'Failed to update todo', details: error.message });
    }
});


// DELETE /api/todos/:id – Delete a todo
app.delete('/api/todos/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const { error, count } = await supabase
            .from('todos')
            .delete({ count: 'exact' }) 
            .eq('id', id);

        if (error) throw error;
        if (count === 0) {
            return res.status(404).json({ error: 'Todo not found or already deleted' });
        }
        res.status(200).json({ message: 'Todo deleted successfully' });
    } catch (error) {
        console.error('Error deleting todo:', error.message);
        res.status(500).json({ error: 'Failed to delete todo', details: error.message });
    }
});

// POST /api/summarize – Summarize todos and send to Slack
app.post('/api/summarize', async (req, res) => {
    try {
        const { data: pendingTodos, error: fetchError } = await supabase
            .from('todos')
            .select('task')
            .eq('is_completed', false);

        if (fetchError) throw fetchError;

        if (!pendingTodos || pendingTodos.length === 0) {
            if (slackWebhookUrl) {
                try {
                    await axios.post(slackWebhookUrl, { text: "Hooray! No pending to-dos to summarize. 🎉" });
                } catch (slackError) {
                    console.warn('Failed to send no pending todos message to Slack:', slackError.message);
                }
            }
            return res.json({ success: true, message: 'No pending to-dos to summarize.', summary: "No pending to-dos." });
        }

        const tasksToSummarize = pendingTodos.map((todo, index) => \`\${index + 1}. \${todo.task}\`).join('\n');
        const prompt = \`Please provide a concise summary of the following pending to-do items. Group similar items if possible:\n\n\${tasksToSummarize}\n\nSummary:\`;

        const completion = await openai.chat.completions.create({
            model: "gpt-3.5-turbo",
            messages: [{ role: "user", content: prompt }],
            max_tokens: 150,
            temperature: 0.5,
        });

        const summary = completion.choices[0]?.message?.content?.trim() || "Could not generate summary.";

        if (slackWebhookUrl) {
            try {
                const slackMessage = {
                    text: \`📝 *Your To-Do Summary*:\n\${summary}\`,
                    blocks: [
                        {
                            type: "header",
                            text: {
                                type: "plain_text",
                                text: "📝 Your To-Do Summary",
                                emoji: true
                            }
                        },
                        {
                            type: "section",
                            text: {
                                type: "mrkdwn",
                                text: summary
                            }
                        },
                        {
                            type: "context",
                            elements: [
                                {
                                    type: "mrkdwn",
                                    text: \`Generated at: \${new Date().toLocaleString()}\`
                                }
                            ]
                        }
                    ]
                };
                await axios.post(slackWebhookUrl, slackMessage);
                res.json({ success: true, message: 'Summary generated and sent to Slack!', summary });
            } catch (slackError) {
                console.error('Failed to send summary to Slack:', slackError.message);
                res.status(500).json({ success: false, message: 'Summary generated, but failed to send to Slack.', summary, slackError: slackError.message });
            }
        } else {
            console.warn("Slack Webhook URL not configured. Summary not sent to Slack.");
            res.json({ success: true, message: 'Summary generated (Slack not configured).', summary });
        }

    } catch (error) {
        console.error('Error in /summarize:', error.message);
        let errorMessage = 'Failed to summarize todos.';
        if (error.response && error.response.data && error.response.data.error) {
            errorMessage = \`OpenAI Error: \${error.response.data.error.message}\`;
        } else if (error.message) {
            errorMessage = error.message;
        }
        res.status(500).json({ success: false, message: errorMessage, details: error.toString() });
    }
});

app.listen(port, () => {
    console.log(\`Backend server running on http://localhost:\${port}\`);
});
EOF

cd .. # Back to project root

# --- Frontend Setup ---
echo "Setting up frontend..."
mkdir -p frontend
cd frontend || exit

# Create a basic package.json for frontend (user will run create-react-app later or install manually)
echo "Creating frontend/package.json..."
cat << 'EOF' > package.json
{
  "name": "frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "@testing-library/jest-dom": "^5.17.0",
    "@testing-library/react": "^13.4.0",
    "@testing-library/user-event": "^13.5.0",
    "axios": "^1.6.2",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "web-vitals": "^2.1.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

echo "Creating frontend/.env.example..."
cat << 'EOF' > .env.example
REACT_APP_API_BASE_URL=http://localhost:3001/api
EOF

mkdir -p src/components src/services public

echo "Creating frontend/src/services/api.js..."
cat << 'EOF' > src/services/api.js
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:3001/api';

const apiClient = axios.create({
    baseURL: API_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
    },
});

export const fetchTodos = () => apiClient.get('/todos');
export const addTodo = (task) => apiClient.post('/todos', { task });
export const updateTodo = (id, updates) => apiClient.put(\`/todos/\${id}\`, updates);
export const deleteTodo = (id) => apiClient.delete(\`/todos/\${id}\`);
export const summarizeAndSend = () => apiClient.post('/summarize');

export default apiClient;
EOF

echo "Creating frontend/src/components/AddTodoForm.js..."
cat << 'EOF' > src/components/AddTodoForm.js
import React, { useState } from 'react';

function AddTodoForm({ onAddTodo }) {
    const [task, setTask] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        if (!task.trim()) return;
        onAddTodo(task);
        setTask('');
    };

    return (
        <form onSubmit={handleSubmit} className="add-todo-form">
            <input
                type="text"
                value={task}
                onChange={(e) => setTask(e.target.value)}
                placeholder="Add a new to-do..."
            />
            <button type="submit">Add</button>
        </form>
    );
}

export default AddTodoForm;
EOF

echo "Creating frontend/src/components/TodoItem.js..."
cat << 'EOF' > src/components/TodoItem.js
import React, { useState } from 'react';

function TodoItem({ todo, onDeleteTodo, onUpdateTodo }) {
    const [isEditing, setIsEditing] = useState(false);
    const [editText, setEditText] = useState(todo.task);

    const handleToggleComplete = () => {
        onUpdateTodo(todo.id, { is_completed: !todo.is_completed });
    };

    const handleDelete = () => {
        onDeleteTodo(todo.id);
    };

    const handleEdit = () => {
        setIsEditing(true);
    };

    const handleSaveEdit = () => {
        if (editText.trim() === "") {
            setEditText(todo.task); 
            setIsEditing(false);
            return;
        }
        onUpdateTodo(todo.id, { task: editText.trim() });
        setIsEditing(false);
    };

    const handleCancelEdit = () => {
        setEditText(todo.task);
        setIsEditing(false);
    }

    return (
        <li className={\`todo-item \${todo.is_completed ? 'completed' : ''}\`}>
            {isEditing ? (
                <>
                    <input 
                        type="text" 
                        value={editText} 
                        onChange={(e) => setEditText(e.target.value)}
                        onKeyDown={(e) => e.key === 'Enter' && handleSaveEdit()}
                        autoFocus
                    />
                    <button onClick={handleSaveEdit} className="save-btn">Save</button>
                    <button onClick={handleCancelEdit} className="cancel-btn">Cancel</button>
                </>
            ) : (
                <>
                    <input
                        type="checkbox"
                        checked={todo.is_completed}
                        onChange={handleToggleComplete}
                        className="todo-checkbox"
                    />
                    <span onClick={!todo.is_completed ? handleToggleComplete : undefined} className="todo-text">
                        {todo.task}
                    </span>
                    <div className="todo-actions">
                        <button onClick={handleEdit} className="edit-btn">Edit</button>
                        <button onClick={handleDelete} className="delete-btn">Delete</button>
                    </div>
                </>
            )}
        </li>
    );
}

export default TodoItem;
EOF

echo "Creating frontend/src/components/TodoList.js..."
cat << 'EOF' > src/components/TodoList.js
import React from 'react';
import TodoItem from './TodoItem';

function TodoList({ todos, onDeleteTodo, onUpdateTodo }) {
    if (!todos || todos.length === 0) {
        return <p className="empty-todos-message">No to-dos yet. Add some!</p>;
    }

    return (
        <ul className="todo-list">
            {todos.map(todo => (
                <TodoItem 
                    key={todo.id} 
                    todo={todo} 
                    onDeleteTodo={onDeleteTodo}
                    onUpdateTodo={onUpdateTodo}
                />
            ))}
        </ul>
    );
}

export default TodoList;
EOF

echo "Creating frontend/src/App.js..."
cat << 'EOF' > src/App.js
import React, { useState, useEffect, useCallback } from 'react';
import './App.css';
import TodoList from './components/TodoList';
import AddTodoForm from './components/AddTodoForm';
import { fetchTodos, addTodo, updateTodo, deleteTodo, summarizeAndSend } from './services/api';

function App() {
    const [todos, setTodos] = useState([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState(null);
    const [summaryMessage, setSummaryMessage] = useState({ text: '', type: '' });

    const loadTodos = useCallback(async () => {
        setIsLoading(true);
        setError(null);
        try {
            const response = await fetchTodos();
            setTodos(response.data);
        } catch (err) {
            setError('Failed to load todos. Please try again later.');
            console.error(err);
        } finally {
            setIsLoading(false);
        }
    }, []);

    useEffect(() => {
        loadTodos();
    }, [loadTodos]);

    const handleAddTodo = async (task) => {
        setError(null);
        try {
            const response = await addTodo(task);
            setTodos(prevTodos => [response.data, ...prevTodos]);
        } catch (err) {
            setError('Failed to add todo.');
            console.error(err);
        }
    };

    const handleUpdateTodo = async (id, updates) => {
        setError(null);
        try {
            const response = await updateTodo(id, updates);
            setTodos(prevTodos => 
                prevTodos.map(todo => todo.id === id ? response.data : todo)
            );
        } catch (err) {
            setError('Failed to update todo.');
            console.error(err);
        }
    };

    const handleDeleteTodo = async (id) => {
        setError(null);
        try {
            await deleteTodo(id);
            setTodos(prevTodos => prevTodos.filter(todo => todo.id !== id));
        } catch (err) {
            setError('Failed to delete todo.');
            console.error(err);
        }
    };

    const handleSummarize = async () => {
        setIsLoading(true);
        setSummaryMessage({ text: '', type: '' });
        setError(null);
        try {
            const response = await summarizeAndSend();
            if (response.data.success) {
                setSummaryMessage({ text: response.data.message, type: 'success' });
            } else {
                setSummaryMessage({ text: response.data.message || 'Failed to process summary.', type: 'error' });
            }
        } catch (err) {
            const errorMsg = err.response?.data?.message || err.message || 'An unexpected error occurred during summarization.';
            setSummaryMessage({ text: \`Error: \${errorMsg}\`, type: 'error' });
            console.error(err);
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="App">
            <header className="App-header">
                <h1>Todo Summary Assistant</h1>
            </header>
            <main>
                <AddTodoForm onAddTodo={handleAddTodo} />
                
                {error && <p className="error-message">{error}</p>}
                
                {isLoading && !error && todos.length === 0 && <p className="loading-message">Loading...</p>}

                <TodoList 
                    todos={todos} 
                    onDeleteTodo={handleDeleteTodo}
                    onUpdateTodo={handleUpdateTodo}
                />

                <div className="summary-section">
                    <button onClick={handleSummarize} disabled={isLoading} className="summarize-button">
                        {isLoading ? 'Processing...' : 'Generate & Send Summary to Slack'}
                    </button>
                    {summaryMessage.text && (
                        <p className={\`summary-status-message \${summaryMessage.type}\`}>
                            {summaryMessage.text}
                        </p>
                    )}
                </div>
            </main>
            <footer>
                <p>Powered by React, Node.js, Supabase, and LLM.</p>
            </footer>
        </div>
    );
}

export default App;
EOF

echo "Creating frontend/src/App.css..."
cat << 'EOF' > src/App.css
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen,
    Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
  margin: 0;
  padding: 0;
  background-color: #f4f7f6;
  color: #333;
}

.App {
  max-width: 700px;
  margin: 0 auto;
  padding: 20px;
  background-color: #fff;
  box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  margin-top: 20px;
}

.App-header {
  text-align: center;
  margin-bottom: 30px;
  color: #2c3e50;
}

.App-header h1 {
  font-size: 2.5em;
  margin: 0;
}

.add-todo-form {
  display: flex;
  margin-bottom: 25px;
}

.add-todo-form input[type="text"] {
  flex-grow: 1;
  padding: 12px 15px;
  border: 1px solid #ddd;
  border-radius: 4px 0 0 4px;
  font-size: 1em;
}

.add-todo-form input[type="text"]:focus {
  outline: none;
  border-color: #76c7c0;
  box-shadow: 0 0 0 2px rgba(118, 199, 192, 0.2);
}

.add-todo-form button {
  padding: 12px 20px;
  background-color: #76c7c0;
  color: white;
  border: none;
  border-radius: 0 4px 4px 0;
  cursor: pointer;
  font-size: 1em;
  transition: background-color 0.2s ease;
}

.add-todo-form button:hover {
  background-color: #5DAAA2;
}

.todo-list {
  list-style: none;
  padding: 0;
}

.todo-item {
  display: flex;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #eee;
  transition: background-color 0.2s ease;
}

.todo-item:last-child {
  border-bottom: none;
}

.todo-item:hover {
  background-color: #f9f9f9;
}

.todo-item.completed .todo-text {
  text-decoration: line-through;
  color: #aaa;
}

.todo-checkbox {
  margin-right: 15px;
  transform: scale(1.2);
  cursor: pointer;
}

.todo-text {
  flex-grow: 1;
  cursor: pointer;
  font-size: 1.05em;
}

.todo-item input[type="text"] {
  flex-grow: 1;
  padding: 8px;
  border: 1px solid #ccc;
  border-radius: 3px;
  margin-right: 10px;
}

.todo-actions {
  margin-left: auto;
}

.todo-actions button, 
.todo-item .save-btn, 
.todo-item .cancel-btn {
  margin-left: 8px;
  padding: 6px 10px;
  border: none;
  border-radius: 3px;
  cursor: pointer;
  font-size: 0.9em;
  transition: background-color 0.2s ease;
}

.edit-btn { background-color: #3498db; color: white; }
.edit-btn:hover { background-color: #2980b9; }
.delete-btn { background-color: #e74c3c; color: white; }
.delete-btn:hover { background-color: #c0392b; }
.save-btn { background-color: #2ecc71; color: white; }
.save-btn:hover { background-color: #27ae60; }
.cancel-btn { background-color: #bdc3c7; color: #333; }
.cancel-btn:hover { background-color: #95a5a6; }

.error-message {
  color: #e74c3c;
  background-color: #fdd;
  padding: 10px;
  border-radius: 4px;
  margin-bottom: 15px;
  text-align: center;
}

.loading-message, .empty-todos-message {
  text-align: center;
  color: #777;
  margin: 20px 0;
  font-style: italic;
}

.summary-section {
  margin-top: 30px;
  padding-top: 20px;
  border-top: 1px solid #eee;
  text-align: center;
}

.summarize-button {
  background-color: #3498db;
  color: white;
  padding: 12px 25px;
  border: none;
  border-radius: 4px;
  font-size: 1.1em;
  cursor: pointer;
  transition: background-color 0.2s ease;
}
.summarize-button:hover { background-color: #2980b9; }
.summarize-button:disabled { background-color: #bdc3c7; cursor: not-allowed; }

.summary-status-message {
  margin-top: 15px;
  padding: 10px;
  border-radius: 4px;
  font-weight: bold;
}
.summary-status-message.success { color: #27ae60; background-color: #e6f7ee; border: 1px solid #b7e4c7; }
.summary-status-message.error { color: #c0392b; background-color: #fbe9e7; border: 1px solid #ffcdd2; }

footer {
  text-align: center;
  margin-top: 40px;
  padding-top: 20px;
  border-top: 1px solid #eee;
  font-size: 0.9em;
  color: #777;
}
EOF

echo "Creating frontend/src/index.css..."
cat << 'EOF' > src/index.css
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f4f7f6;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
EOF

echo "Creating frontend/src/index.js..."
cat << 'EOF' > src/index.js
import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import App from './App';
import reportWebVitals from './reportWebVitals';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
EOF

echo "Creating basic frontend/public/index.html..."
cat << 'EOF' > public/index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta
      name="description"
      content="Todo Summary Assistant Web Application"
    />
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    <title>Todo Summary Assistant</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF

echo "Creating basic frontend/public/manifest.json..."
cat << 'EOF' > public/manifest.json
{
  "short_name": "Todo App",
  "name": "Todo Summary Assistant",
  "icons": [
    {
      "src": "favicon.ico",
      "sizes": "64x64 32x32 24x24 16x16",
      "type": "image/x-icon"
    },
    {
      "src": "logo192.png",
      "type": "image/png",
      "sizes": "192x192"
    },
    {
      "src": "logo512.png",
      "type": "image/png",
      "sizes": "512x512"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#000000",
  "background_color": "#ffffff"
}
EOF

cd .. # Back to project root

echo ""
echo "Project structure created successfully under '$PROJECT_ROOT/' directory."
echo "Next steps:"
echo "1. cd $PROJECT_ROOT"
echo "2. cd backend && npm install && cp .env.example .env && nano .env (fill credentials)"
echo "3. cd ../frontend"
echo "   If you haven't run create-react-app yet for frontend:"
echo "   npm install (to install listed deps from package.json)"
echo "   OR (Recommended for full CRA setup after this script):"
echo "   Delete the current 'frontend' directory created by this script."
echo "   Run 'npx create-react-app frontend'"
echo "   Then, manually copy the content of src/components, src/services, App.js, App.css from this script's output into the new CRA 'frontend/src' directory."
echo "   Then: cp .env.example .env && nano .env (fill credentials)"
echo "4. Follow README.md for Supabase, OpenAI, and Slack setup."
echo "5. Start backend: cd backend && npm run dev"
echo "6. Start frontend: cd frontend && npm start"