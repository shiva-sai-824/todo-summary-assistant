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
            setSummaryMessage({ text: `Error: ${errorMsg}`, type: 'error' }); // Corrected backtick
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
                    <button 
                        onClick={handleSummarize} 
                        disabled={isLoading || todos.filter(t => !t.is_completed).length === 0} 
                        className="summarize-button"
                    >
                        {isLoading ? 'Processing...' : 'Generate & Send Summary to Slack'}
                    </button>
                    {summaryMessage.text && (
                        <p className={`summary-status-message ${summaryMessage.type}`}> {/* Corrected backtick */}
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