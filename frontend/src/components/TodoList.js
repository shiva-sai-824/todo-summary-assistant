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
