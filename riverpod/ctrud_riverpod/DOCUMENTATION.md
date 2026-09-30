# ctrud_riverpod

This is a Flutter application for managing a Todo list. It utilizes the Riverpod package for state management and the sqflite package for persisting data locally in an SQLite database. 

The application architecture separates the UI, state management, and data access layers. A Riverpod provider manages the state of the Todo list. The application interacts with a repository class, which handles the actual database queries.

When the app needs to load, add, update, or delete a Todo item, the Riverpod controller calls the corresponding method on the repository. The repository then uses the sqflite package to execute SQL commands against the local database file. The path package is used to correctly locate the database file on the device's file system. 

Once a database operation is complete, the Riverpod state is updated, and the Flutter UI reacts to this state change by rebuilding to show the updated list of Todo items.

Technologies used: Flutter, flutter_riverpod, sqflite, path.

## Working Flow
1. Open the app -> The Riverpod controller initializes and calls the repository to fetch existing Todo items from the SQLite database using sqflite.
2. View List -> The UI reads the Riverpod state and displays the fetched list of items.
3. Add Todo -> The user submits new item data. The controller passes this data to the repository, which executes an SQL INSERT statement. The state is then refreshed.
4. Update Todo -> The user modifies an item (e.g., toggling its completion status). The repository executes an SQL UPDATE statement, and the state updates.
5. Delete Todo -> The user initiates a delete action. The repository executes an SQL DELETE statement, removing the item from SQLite, and the state updates to remove the item from the UI.
