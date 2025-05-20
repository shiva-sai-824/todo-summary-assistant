// import axios from 'axios';

// const API_BASE_URL = process.env.REACT_APP_API_BASE_URL || 'http://localhost:3001/api';

// const apiClient = axios.create({
//     baseURL: API_BASE_URL,
//     headers: {
//         'Content-Type': 'application/json',
//     },
// });

// export const fetchTodos = () => apiClient.get('/todos');
// export const addTodo = (task) => apiClient.post('/todos', { task });
// export const updateTodo = (id, updates) => apiClient.put(`/todos/${id}`, updates); // Corrected backtick
// export const deleteTodo = (id) => apiClient.delete(`/todos/${id}`); // Corrected backtick
// export const summarizeAndSend = () => apiClient.post('/summarize');

// export default apiClient;

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
export const updateTodo = (id, updates) => apiClient.put(`/todos/${id}`, updates);
export const deleteTodo = (id) => apiClient.delete(`/todos/${id}`);
export const summarizeAndSend = () => apiClient.post('/summarize');

export default apiClient;