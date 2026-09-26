# ctrud_riverpod

This is a Flutter todo application that uses Riverpod for state management and SQLite for local data persistence. It demonstrates a clean architecture approach with clear separation between views, controllers, providers, repositories, and the database layer.

When the app starts with a ProviderScope wrapper, the TodoProvider initializes and the TodoController loads all existing todos from the local SQLite database through the TodoRepository. The DbHelper class manages the SQLite database — creating the todos table on first run with columns for id, title, description, completion status, and creation timestamp.

The HomeView displays the list of todos. Each todo shows its title, description, and a completion toggle. Users can tap the floating action button to navigate to the AddEditTodoView, where they fill in a title and description. When saved, the TodoController calls the TodoRepository to insert a new TodoModel record into SQLite, then refreshes the provider state so the list updates reactively.

Editing works the same way — tapping an existing todo opens the AddEditTodoView pre-filled with the current data, and saving triggers an update operation through the repository to SQLite. Deleting a todo removes it from the database and updates the state.

The data flows in a clean chain: the View reads from the Riverpod Provider, which exposes state managed by the TodoController, which delegates data operations to the TodoRepository, which talks to the DbHelper for actual SQLite queries. This layered approach keeps each piece testable and replaceable.

Technologies used: Flutter, flutter_riverpod, sqflite, path.

## Working Flow
1. Open the app -> The TodoController fetches existing tasks from the local SQLite database and the Home View displays them in a list.
2. Click the Floating Action Button (+) -> The Add/Edit screen opens with empty text fields.
3. Enter title and description, then click Save -> The TodoRepository inserts the new data into SQLite, Riverpod updates the state, and the new task appears on the home list.
4. Click the checkbox on a task -> The completion status toggles, updating the database and the UI instantly.
5. Tap an existing task -> The Add/Edit screen opens, pre-filled with the task's data for you to modify.
6. Swipe a task (or click delete) -> The task is removed from SQLite and disappears from the screen.
