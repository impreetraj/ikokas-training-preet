# project_list

This is a minimal Flutter application that displays a list of projects and lets users tap on any project to see its details. It uses no external dependencies beyond the Flutter framework itself — no state management library, no database, no API calls.

The app has a static data source defined in project_list.dart inside the json folder. This file contains a list of project data structured as Dart objects. The HomePage reads this data and renders it as a scrollable list. When the user taps on a project in the list, the app navigates to the DetailsPage, passing the selected project's data. The details page then displays the full information about that project.

The entire app runs on Flutter's default setState mechanism for any state changes, and the data is hardcoded rather than fetched from any backend.

Technologies used: Flutter (no external packages).

## Working Flow
1. Open the app -> The Home Page renders a scrollable list using data loaded directly from a static local Dart file.
2. Scroll through the list -> You see the titles of various projects.
3. Click a list item -> The app uses Navigator.push to open the Details Page, passing the specific project's data object along.
4. View details -> The Details Page reads the passed object and displays the full text and information for that single project.
