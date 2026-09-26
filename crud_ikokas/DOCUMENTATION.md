# crud_ikokas

This is a full-stack CRUD application with a Flutter frontend and a Node.js backend. The frontend uses the BLoC pattern for state management, while the backend runs on Express.js with MongoDB as the database through Mongoose ODM.

When the app starts, the CrudBloc fires a load event that triggers an API call through the ApiRepo class. This repository uses Dio as the HTTP client to communicate with the Express.js backend. The backend receives the request through its routes, processes it in the controller, queries MongoDB via Mongoose, and returns JSON data back to the Flutter app. The BLoC then emits a new state with the loaded data, and the UI rebuilds to show the list on the home screen.

The user can create a new item by filling out a form, which dispatches an Add event to the CrudBloc. This triggers a POST request via Dio to the backend, which inserts the data into MongoDB. Similarly, updating an item sends a PUT request, and deleting sends a DELETE request. After each operation, the list is refreshed from the server.

The entire frontend lives inside a folder called "forntend F" (a typo for frontend), and the backend is in "backend N E". The backend is a straightforward Express.js setup with Mongoose models and routes, using nodemon for development auto-restart.

Technologies used: Flutter, flutter_bloc, Dio, Node.js, Express.js, MongoDB, Mongoose, nodemon.

## Working Flow
1. Open the app -> The CrudBloc triggers a fetch event to the Node.js backend, and the list of items is displayed on the screen.
2. Click the Floating Action Button (+) -> A form dialog/screen opens to create a new item.
3. Fill the form and click Submit -> A POST request is sent via Dio to the Express backend, the item is saved to MongoDB, and the list refreshes.
4. Click the Edit icon on an item -> A form opens with the item's current details.
5. Update details and click Save -> A PUT request is sent to the backend, MongoDB updates the document, and the UI refreshes.
6. Click the Delete icon on an item -> A DELETE request is sent, the item is removed from MongoDB, and it disappears from the list.
