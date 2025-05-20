import React, { useState, useEffect, useCallback } from 'react';
import './App.css';
import TodoList from './components/TodoList';
import AddTodoForm from './components/AddTodoForm';
import { fetchTodos, addTodo, updateTodo, deleteTodo, summarizeAndSend } from './services/api';

function App() {
    const [todos, setTodos] = useState([]);
    const [isLoading, setIsLoading] = useState(false);
    const [error, setError] = useState(null);
    const [summaryOpMessage, setSummaryOpMessage] = useState({ text: '', type: '' }); // For operation status
    const [generatedSummaryText, setGeneratedSummaryText] = useState(''); // For the actual summary text

    const loadTodos = useCallback(async () => {
        setIsLoading(true);
        setError(null);
        try {
            const response = await fetchTodos();
            setTodos(response.data);
        } catch (err){
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
        setGeneratedSummaryText(''); 
        setSummaryOpMessage({ text: '', type: '' }); // Clear operation message too
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
        setGeneratedSummaryText('');
        setSummaryOpMessage({ text: '', type: '' });
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
        setGeneratedSummaryText('');
        setSummaryOpMessage({ text: '', type: '' });
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
        setSummaryOpMessage({ text: '', type: '' }); 
        setGeneratedSummaryText(''); 
        setError(null);
        try {
            const response = await summarizeAndSend(); 
            if (response.data.success) {
                setSummaryOpMessage({ text: response.data.message, type: 'success' });
                if (response.data.summary) { 
                    setGeneratedSummaryText(response.data.summary);
                }
            } else {
                setSummaryOpMessage({ text: response.data.message || 'Failed to process summary.', type: 'error' });
                if (response.data.summary) { 
                    setGeneratedSummaryText(response.data.summary);
                }
            }
        } catch (err) {
            const errorMsg = err.response?.data?.message || err.message || 'An unexpected error occurred during summarization.';
            setSummaryOpMessage({ text: `Error: ${errorMsg}`, type: 'error' });
            console.error(err);
        } finally {
            setIsLoading(false);
        }
    };

    // Helper to extract a nicer title from the operation message
    const getSummaryTitle = () => {
        if (summaryOpMessage.type === 'success' && summaryOpMessage.text) {
            if (summaryOpMessage.text.startsWith("Summary via")) {
                 // Extracts "Summary via Hugging Face (bart-large-cnn)" from "Summary via Hugging Face (bart-large-cnn) sent to Slack!"
                const match = summaryOpMessage.text.match(/^(Summary via [^!]+)/);
                if (match) return match[1];
            }
            // For "No pending to-dos to summarize." we don't need a special title for the (empty) summary text part
            if (summaryOpMessage.text === "No pending to-dos to summarize.") return ""; 
        }
        return "Generated Summary Details:"; // Generic title if no specific success message or if it's an error
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
                    <button
                        onClick={handleSummarize}
                        disabled={isLoading || todos.filter(t => !t.is_completed).length === 0}
                        className="summarize-button"
                    >
                        {isLoading ? 'Processing...' : 'Generate & Send Summary to Slack'}
                    </button>
                    
                    {/* Display Operation Status Message (e.g., sent to Slack, error) */}
                    {summaryOpMessage.text && (
                        <p className={`summary-status-message ${summaryOpMessage.type}`}>
                            {summaryOpMessage.text}
                        </p>
                    )}

                    {/* Display Generated Summary Text with a dynamic title */}
                    {generatedSummaryText && generatedSummaryText !== "No pending to-dos." && (
                        <div className="generated-summary-container">
                            <h3>{getSummaryTitle()}</h3> {/* Using helper for title */}
                            <p className="generated-summary-text">{generatedSummaryText}</p>
                        </div>
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