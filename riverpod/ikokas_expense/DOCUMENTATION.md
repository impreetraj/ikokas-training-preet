# ikokas_expense

This is an expense tracking application built with Flutter and Riverpod for state management. It utilizes multiple databases and integrates with several external services like Firebase and Google Maps.

The application manages user authentication through Firebase Auth. Once authenticated, the app uses Riverpod providers to manage the state of transactions, analytics, and admin features. 

To ensure data availability both online and offline, the app implements a multi-database strategy. It saves transaction data locally using the sqflite package (SQLite) and the Realm database (which requires code generation via build_runner). Simultaneously, it synchronizes this data with Cloud Firestore. The connectivity_plus package is used to detect network state and handle synchronization between the local databases and Firestore.

The application provides data visualization by taking transaction data and rendering charts using the Syncfusion Flutter Charts package. 

For location-based expense tracking, the app uses the geolocator package to get the device's coordinates and the geocoding package to convert these coordinates into readable addresses. The google_maps_flutter package is used to display these locations on a map interface.

Additional features include capturing receipt images with image_picker, sharing reports via share_plus, and a backup/restore system. The backup system uses the archive package to compress local database files into a single exportable file, which can be selected for import using the file_picker package. Device information for backups is retrieved using device_info_plus.

Technologies used: Flutter, flutter_riverpod, Firebase Core, Firebase Auth, Cloud Firestore, sqflite, Realm (with build_runner), Syncfusion Flutter Charts, google_maps_flutter, geolocator, geocoding, image_picker, share_plus, file_picker, archive, connectivity_plus, device_info_plus, font_awesome_flutter, intl, path_provider.

## Working Flow
1. Open the app -> The app authenticates the user via Firebase Auth.
2. Add Transaction -> The user inputs expense/income details. They can attach an image via image_picker and a location via geolocator.
3. Save Transaction -> The Riverpod provider updates its state. The data is saved locally to SQLite and Realm, and an attempt is made to sync it to Cloud Firestore.
4. View Analytics -> The app processes the transaction state data and passes it to Syncfusion Flutter Charts to render visual graphs.
5. View Map -> The app passes the saved location coordinates to the google_maps_flutter widget to display transaction locations on a map.
6. Create Backup -> The app reads the local database files, compresses them using the archive package, and saves the file to the device.
