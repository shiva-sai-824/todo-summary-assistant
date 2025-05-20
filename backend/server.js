require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { createClient } = require('@supabase/supabase-js');
// const OpenAI = require('openai'); // We are removing OpenAI for now
const axios = require('axios'); // Already have this, good for Hugging Face
// const { v4: uuidv4 } = require('uuid'); // Not strictly used in the current logic, can keep or remove

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

// --- REMOVE OR COMMENT OUT OPENAI CLIENT SETUP ---
/*
const openaiApiKey = process.env.OPENAI_API_KEY;
if (!openaiApiKey) {
    // console.error("OpenAI API Key is missing. Check your .env file."); // We'll just warn if we intend to use it as a fallback
    // process.exit(1); // DON'T EXIT if we are not primarily using OpenAI
    console.warn("OpenAI API Key is missing. OpenAI features will be unavailable.");
}
let openai; // Declare openai variable
if (openaiApiKey) {
    openai = new OpenAI({ // Initialize if key exists
        apiKey: openaiApiKey,
    });
}
*/
// --- END OF OPENAI CLIENT SETUP MODIFICATION ---


// --- HUGGING FACE SETUP ---
const huggingFaceApiToken = process.env.HUGGINGFACE_API_TOKEN;
if (!huggingFaceApiToken) {
    console.warn("Hugging Face API Token is missing. Summarization via Hugging Face will fail.");
}
const HUGGINGFACE_INFERENCE_API_URL = "https://api-inference.huggingface.co/models/";
// Let's choose a default model. You can change this if you prefer another.
const DEFAULT_HF_SUMMARIZATION_MODEL = "facebook/bart-large-cnn";
// --- END OF HUGGING FACE SETUP ---


// Slack Webhook URL
const slackWebhookUrl = process.env.SLACK_WEBHOOK_URL;
if (!slackWebhookUrl) {
    console.warn("Slack Webhook URL is missing. Summaries won't be sent to Slack.");
}

// --- API Endpoints ---

// GET /api/todos – Fetch all todos (NO CHANGE)
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

// POST /api/todos – Add a new todo (NO CHANGE)
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

// PUT /api/todos/:id – Update a todo (NO CHANGE)
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


// DELETE /api/todos/:id – Delete a todo (NO CHANGE)
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

// POST /api/summarize – Summarize todos and send to Slack (MAJOR CHANGES HERE)
app.post('/api/summarize', async (req, res) => {
    if (!huggingFaceApiToken) {
        console.error("Hugging Face API Token not configured.");
        return res.status(500).json({ success: false, message: "Summarization service (Hugging Face) not configured." });
    }

    try {
        const { data: pendingTodos, error: fetchError } = await supabase
            .from('todos')
            .select('task')
            .eq('is_completed', false);

        if (fetchError) {
            console.error("Error fetching pending todos:", fetchError.message);
            throw fetchError; // Propagate the error
        }

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

        const tasksTextToSummarize = pendingTodos.map((todo) => todo.task).join('. '); // Join tasks into a single string
        
        let summary = "Could not generate summary.";
        const modelToUse = DEFAULT_HF_SUMMARIZATION_MODEL; // e.g., "facebook/bart-large-cnn"

        try {
            console.log(`Attempting to summarize with Hugging Face model: ${modelToUse}`);
            console.log(`Input text for summarization: "${tasksTextToSummarize}"`);

            const hfResponse = await axios.post(
                `${HUGGINGFACE_INFERENCE_API_URL}${modelToUse}`,
                {
                    inputs: tasksTextToSummarize,
                    parameters: { // Some models accept parameters like min/max length
                        min_length: 20, // Example: request a summary of at least 20 tokens
                        max_length: 100  // Example: cap summary at 100 tokens
                    }
                },
                {
                    headers: { "Authorization": `Bearer ${huggingFaceApiToken}` }
                }
            );

            // The response structure can vary slightly between Hugging Face models
            // Common for summarization is an array with one object containing 'summary_text'
            if (hfResponse.data && Array.isArray(hfResponse.data) && hfResponse.data.length > 0 && hfResponse.data[0].summary_text) {
                summary = hfResponse.data[0].summary_text.trim();
            } else if (hfResponse.data && hfResponse.data.summary_text) { // Some might return object directly
                 summary = hfResponse.data.summary_text.trim();
            } else {
                console.warn("Unexpected response structure from Hugging Face:", hfResponse.data);
                summary = "Summary generated, but format was unexpected.";
            }
            console.log("Summary from Hugging Face:", summary);

        } catch (hfError) {
            console.error('Hugging Face API Error:', hfError.response ? hfError.response.data : hfError.message);
            // Provide more specific error to frontend if possible
            let hfErrorMessage = hfError.message;
            if (hfError.response && hfError.response.data && hfError.response.data.error) {
                hfErrorMessage = `HF Model Error (${hfError.response.status}): ${hfError.response.data.error}`;
                if (hfError.response.data.estimated_time) {
                     hfErrorMessage += `. Model might be loading (est. time: ${hfError.response.data.estimated_time.toFixed(1)}s). Try again shortly.`;
                }
            }
            return res.status(500).json({ success: false, message: `Hugging Face API Error: ${hfErrorMessage}` });
        }

        // Send summary to Slack
        const llmProviderUsed = `Hugging Face (${modelToUse})`;
        if (slackWebhookUrl) {
            try {
                const slackMessage = {
                    text: `📝 *Your To-Do Summary* (via ${llmProviderUsed}):\n${summary}`,
                    blocks: [
                        {
                            type: "header",
                            text: {
                                type: "plain_text",
                                text: `📝 Your To-Do Summary (via ${llmProviderUsed})`,
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
                                    text: `Generated at: ${new Date().toLocaleString()}`
                                }
                            ]
                        }
                    ]
                };
                await axios.post(slackWebhookUrl, slackMessage);
                res.json({ success: true, message: `Summary generated via ${llmProviderUsed} and sent to Slack!`, summary });
            } catch (slackError) {
                console.error('Failed to send summary to Slack:', slackError.message);
                res.status(500).json({ success: false, message: `Summary generated via ${llmProviderUsed}, but failed to send to Slack.`, summary, slackError: slackError.message });
            }
        } else {
            console.warn("Slack Webhook URL not configured. Summary not sent to Slack.");
            res.json({ success: true, message: `Summary generated via ${llmProviderUsed} (Slack not configured).`, summary });
        }

    } catch (error) { // General catch for other errors like Supabase fetch
        console.error('Error in /summarize endpoint:', error.message);
        res.status(500).json({ success: false, message: `General summarization error: ${error.message}` });
    }
});

app.listen(port, () => {
    console.log(`Backend server running on http://localhost:${port}`);
});