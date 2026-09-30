# crud_ikokas

This is a CRUD (Create, Read, Update, Delete) application composed of a Flutter frontend and a Node.js backend. The frontend manages state using the BLoC pattern and communicates with the backend via REST APIs.

The frontend sends HTTP requests using the Dio package. The BLoC architecture separates the presentation layer from the business logic. When an action is performed, the UI dispatches an event to the BLoC, which then calls the repository. The repository makes the necessary network request to the backend.

The backend is built with Node.js and Express.js. It defines API routes for handling CRUD operations on items. The data is stored in a MongoDB database, and Mongoose is used as the Object Data Modeling (ODM) library to define schemas and interact with the database. The backend uses body-parser to parse incoming JSON request bodies and cors to handle Cross-Origin Resource Sharing.

Technologies used: Flutter, flutter_bloc, Dio, Node.js, Express.js, MongoDB, Mongoose, body-parser, cors, nodemon.

## Working Flow
1. Open the app -> The BLoC sends a GET request via Dio to the Node.js backend to fetch a list of items.
2. Backend responds -> The Express.js server queries MongoDB via Mongoose and returns the data as JSON.
3. Create Item -> You enter item details and submit. The BLoC sends a POST request with the data to the backend, which saves it in MongoDB.
4. Update Item -> You modify an item and submit. The BLoC sends a PUT request to the backend, which updates the specific MongoDB document.
5. Delete Item -> You choose to delete an item. The BLoC sends a DELETE request to the backend, which removes the document from MongoDB.
6. Refresh UI -> After any create, update, or delete action, the BLoC state updates and the Flutter UI refreshes to show the current data.
