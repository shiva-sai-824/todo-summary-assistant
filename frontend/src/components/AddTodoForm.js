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
