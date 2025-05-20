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
            // Optionally, handle empty edit text (e.g., revert or show error)
            setEditText(todo.task); // Revert to original if empty
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
        // THIS IS THE CORRECTED LINE:
        <li className={`todo-item ${todo.is_completed ? 'completed' : ''}`}>
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