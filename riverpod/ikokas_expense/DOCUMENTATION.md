# ikokas_expense

This is a comprehensive expense tracker application built with Flutter and Riverpod, featuring analytics charts, Google Maps integration, an admin dashboard, backup and restore functionality, and a multi-database architecture that supports offline use.

The app uses four Riverpod providers working together. The AuthProvider manages Firebase authentication (email/password login and signup). Once logged in, the TransactionProvider handles all expense and income CRUD operations. The AnalyticsProvider computes spending summaries, category breakdowns, and trends for the charts. The AdminProvider powers the admin dashboard for managing users and performing fund transfers.

Transactions are the core of the app. When a user adds a new expense or income on the add screen, it gets saved to three places simultaneously — SQLite locally through the DatabaseHelper, Realm locally using code-generated models (user_model.realm.dart built via build_runner), and Firebase Cloud Firestore in the cloud. The SyncService monitors network connectivity using connectivity_plus and synchronizes data between local and cloud databases. When the device is offline, transactions are stored locally and synced to Firestore when connectivity returns.

The analytics screen displays beautiful charts using Syncfusion Flutter Charts — pie charts for spending by category, bar charts for monthly comparisons, and line charts for spending trends over time. The AnalyticsModel structures the data for these visualizations.

One unique feature is location-based expense tracking. When adding a transaction, users can tag their current GPS location using geolocator. The geocoding package converts coordinates into human-readable addresses. These locations are then viewable on a Google Maps screen using google_maps_flutter, where users can see where they spent money geographically.

The admin module (behind an admin role check) provides a dashboard to view all users, see their transaction details on the admin user details screen, and perform fund transfers between accounts through a transfer dialog.

The backup and restore service lets users export their entire transaction data as a compressed archive file using the archive package. They can pick a backup file to restore using file_picker, and the service decompresses and re-imports all the data. Device information is captured via device_info_plus for backup metadata. Reports can be shared using share_plus. Receipt images are captured with image_picker.

The transaction log repository maintains an audit trail of all changes, viewable on the transaction logs screen. The app also features a custom bottom navigation bar, summary cards on the home screen, transaction cards for list items, a settings screen for preferences, and a profile screen.

Technologies used: Flutter, flutter_riverpod, Firebase Core, Firebase Auth, Cloud Firestore, sqflite, Realm (with build_runner), Syncfusion Flutter Charts, google_maps_flutter, geolocator, geocoding, image_picker, share_plus, file_picker, archive, connectivity_plus, device_info_plus, font_awesome_flutter, intl, path_provider.

## Working Flow
1. Open the app -> Sign up or log in using Firebase Auth.
2. View Home Dashboard -> Summary cards show your total balance, income, and expenses, along with a list of recent transactions.
3. Click the Add button (+) -> A form opens to add a new expense or income.
4. Fill the form -> You can capture a receipt photo (image_picker) and click the location icon to tag your current GPS location (geolocator/geocoding).
5. Click Save -> The transaction saves to the local SQLite and Realm databases, and syncs to Firebase Cloud Firestore.
6. Click the Analytics tab -> Syncfusion charts render your spending data as pie charts and trend lines.
7. Click the Map tab -> Google Maps opens, displaying pins where you made your purchases.
8. Click Settings -> Access the backup/restore feature, which zips your local database using the archive package and lets you save it or share it.
