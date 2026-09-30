# project_list

This is a foundational Flutter application that demonstrates basic data rendering and navigation without relying on any external packages or complex state management libraries.

The application's data is statically defined within the Dart code itself, typically as a JSON-like list of objects or maps containing project details. 

The application uses standard Flutter state management (`setState`) and core layout widgets to display this static data as a list on the primary screen. 

When a user selects an item from the list, the application utilizes Flutter's built-in `Navigator` to transition to a details screen. The data object associated with the selected list item is passed as an argument to the details screen, which then reads the properties of that object to display the full information.

Technologies used: Pure Flutter framework (no external dependencies).

## Working Flow
1. Open the app -> The main widget initializes and reads the statically defined list of data objects.
2. Render List -> The UI iterates over the data objects and builds a list view.
3. Select Item -> The user taps a specific item in the list.
4. Navigate -> The app uses `Navigator.push` to transition to the details screen, passing the selected data object to the constructor of the new route.
5. View Details -> The details screen reads the properties of the passed object and displays them in the UI.
