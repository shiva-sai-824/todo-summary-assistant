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
