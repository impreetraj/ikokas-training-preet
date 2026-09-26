final Map<String, dynamic> projectList = {
  "projects": [
    {
      "id": 1,
      "date": "09 April 2026",
      "title": "Ikokas Notes: notes app with Facebook & Microsoft Authentication, offline-online sync, and dynamic theming",
      "description": "A feature-rich notes management app with multiple login methods, offline-online sync, scheduled reminders, and dynamic theming, built using Flutter and BLoC architecture.",
      "tech_stack": ["Flutter", "BLoC (AuthBloc, NotesBloc, ThemeBloc, NotificationBloc)", "Firebase Auth", "Firebase Firestore", "SQLite (sqflite)", "Firebase Cloud Messaging", "Flutter Local Notifications", "Firebase Analytics", "Firebase Crashlytics"],
      "features": {
        "authentication": "Email/Password, Google, Facebook, and Microsoft Sign-In via AuthBloc; persistent session bypasses login screen on relaunch.",
        "notes_management": "Full CRUD with Title, Description, Platform Tagging (Google/Microsoft), Time Slots (half-hour slots), and Schedule Day (Today/Tomorrow). Responsive grid view with color-coded chips (Blue-Microsoft, Orange-Google) and last updated timestamp.",
        "offline_cloud_sync": "Repository Pattern (NotesRepository) syncs Firebase Firestore (cloud) with SQLite/sqflite (offline local storage - LocalDbService) for full offline functionality.",
        "push_notifications": "Firebase Cloud Messaging + Flutter Local Notifications; NotificationBloc and FcmListenerWrapper handle real-time alerts and scheduled reminders based on time slot/day.",
        "dynamic_theming": "Dark/Light mode toggle via ThemeBloc, persisted locally using ThemeLocalDbService.",
        "analytics_crash_reporting": "Firebase Analytics tracks login method, note additions/deletions; Firebase Crashlytics captures crashes (with a manual test crash trigger).",
        "architecture": "Separate BLoCs for Auth, Notes, Theme, and Notifications; Splash Screen routes based on auth state."
      }
    },
    {
      "id": 2,
      "date": "01 June 2026",
      "title": "Social Chat & Calling App featuring ,live face verification, real-time messaging, and social feed (like comment) , follow unfollow",
      "description": "An enterprise-grade social chat application with real-time messaging, social feed, high-quality audio/video calling, and a standout AI-powered live face verification security feature.",
      "tech_stack": ["Flutter", "BLoC", "Firebase (Auth, Firestore, FCM)", "SQLite (sqflite)", "local_auth", "Zego Cloud UI Kit", "flutter_callkit_incoming", "Google ML Kit", "TensorFlow Lite"],
      "features": {
        "authentication_security": "Email/Password + Google Sign-In; biometric app lock (Fingerprint/Face ID via local_auth); persistent secure sessions using SQLite + Shared Preferences.",
        "chat_social": {
          "realtime_chat": "Real-time 1-on-1 messaging using Firestore for instant delivery.",
          "social_feed": "Home feed with image post uploads; Like and Comment functionality updating in real-time.",
          "profile_discovery": "Comprehensive profile view/edit and global search screen to discover/connect with users.",
          "notifications": "Notification center tracking messages, likes, and comments."
        },
        "architecture": "BLoC pattern (flutter_bloc) for scalable, testable, crash-resistant code; offline-first caching via sqflite; Repository Pattern (auth_repository.dart) abstracting data sources.",
        "integrations": "Firebase suite (Auth, Firestore, FCM for push notifications); Zego Cloud UI Kit (zego_uikit_prebuilt_call) for audio/video calling.",
        "unique_features": {
          "ai_face_verification": "Uses Google ML Kit and TensorFlow Lite (mobilefacenet.tflite) to capture face and generate embedding at signup; mandates live face match via Cosine Similarity algorithm on subsequent logins.",
          "native_calling_ui": "flutter_callkit_incoming intercepts calls at OS level, showing native full-screen incoming call UI even when app is killed/backgrounded (WhatsApp-style)."
        }
      }
    },
    {
      "id": 3,
      "date": "16 June 2026",
      "title": "IkoKas Full-Stack CRUD App built with Flutter, Node.js, Express, and MongoDB with Backend deploy in render",
      "description": "A full-stack CRUD (Create, Read, Update, Delete) mobile application built with Flutter (frontend) and Node.js + Express + MongoDB (backend). The frontend uses the BLoC pattern for clean state management.",
      "tech_stack": ["Flutter", "BLoC", "Node.js", "Express", "MongoDB", "Mongoose"],
      "backend_features": {
        "database_schema": "Mongoose model storing name (required), title (required), description (optional), with auto-generated createdAt and updatedAt timestamps.",
        "api_endpoints": [
          "POST /ikokas - Create a new item",
          "GET /ikokas - Fetch all items",
          "PUT /ikokas/:id - Update item by id",
          "DELETE /ikokas/:id - Delete item by id"
        ],
        "controllers": "itemController.js handles MongoDB logic (Crud.create, Crud.find, Crud.findByIdAndUpdate, Crud.findByIdAndDelete) with error handling returning proper HTTP status codes (404, 500)."
      },
      "frontend_features": {
        "state_management": "flutter_bloc manages Loading, Loaded, and Error states for API calls and UI updates.",
        "view_items": "Fetches and displays items in a scrollable ListView as Cards (Title bold, Name, Description). Shows 'No items found' if empty.",
        "add_item": "Floating Action Button opens 'Add Item' dialog to input Name, Title, Description and save to backend.",
        "edit_item": "Edit (pencil) icon opens pre-filled 'Edit Item' dialog to update data.",
        "delete_item": "Delete (trash) icon removes item from database and updates UI instantly."
      }
    },
    {
      "id": 4,
      "date": "23 June 2026",
      "title": "Video Upload with in-app video editing, FFmpeg compression, and Cloudinary integration (for upload video)",
      "description": "A robust video sharing platform allowing users to pick, edit, compress, and upload videos to Cloudinary, with metadata managed via a backend API.",
      "tech_stack": ["Flutter", "BLoC", "FFmpeg", "Cloudinary", "REST API"],
      "features": {
        "video_selection": "Pick videos from device gallery; format correction and optimization using FFmpeg.",
        "video_editing": "Trim (start/end time), Crop (frame dimensions), Rotate (90 degrees left/right).",
        "video_compression": "Automatic compression before upload using FFmpeg (H.264 codec, veryfast preset) to save bandwidth and upload time.",
        "thumbnail_selection": "Users can pick a custom thumbnail image from gallery.",
        "cloud_integration": "Secure direct-to-cloud upload for compressed video and thumbnail via Cloudinary.",
        "backend_metadata": "Saves video details (Title, Video URL, Thumbnail URL, Video ID) to REST API; fetches global video feed.",
        "interactive_feed": "Scrolling home feed with inline playback via custom video player, smart auto-pause on navigation, and progress scrubbing.",
        "state_management": "BLoC pattern for clean separation of business logic and UI."
      }
    },
    {
      "id": 5,
      "date": "26 June 2026",
      "title": "Multi-Account Authentication App allowing seamless switching between multiple profiles on a single device without re-entering credentials",
      "description": "An authentication-focused app supporting multiple login methods and allowing users to manage and switch between multiple accounts on the same device without re-entering credentials.",
      "tech_stack": ["Flutter", "BLoC (session_sync_bloc)", "Firebase Auth", "Secure Local Storage", "Cloud Database"],
      "features": {
        "authentication": "Email/Password signup & login (login_page.dart, signup_page.dart) plus Google Sign-In (OAuth) for one-tap login.",
        "multi_account_management": "Add multiple accounts on one device and switch between them via account_switcher_bottom_sheet.dart (inspired by Gmail/Instagram) without re-entering credentials.",
        "session_synchronization": "session_sync_bloc ensures app data/session accurately reflects the currently active profile after switching.",
        "secure_storage": "Account credentials, auth tokens, and session details encrypted and securely stored on device.",
        "cloud_integration": "Connected to a live cloud database to store user profile data and account metadata securely."
      }
    },
    {
      "id": 6,
      "date": "01 July 2026",
      "title": "Real-Time Collaborative Workspace (Google Docs/Sheets clone) with live co-editing, live presence, and synchronized data grids",
      "description": "A real-time collaborative workspace app (similar to Google Docs/Sheets) built with Flutter and Firebase, enabling multiple users to co-edit rich text documents and spreadsheet-like data grids simultaneously.",
      "tech_stack": ["Flutter", "Firebase (firebase_core, cloud_firestore)", "flutter_quill", "syncfusion_flutter_datagrid"],
      "features": {
        "home_screen": "Entry point where users input a Document ID and User Name. Same Document ID joins users into the same collaborative session.",
        "document_editor": {
          "rich_text_editing": "Uses flutter_quill (QuillEditor.basic, QuillSimpleToolbar) for formatting; content managed as JSON Deltas.",
          "real_time_sync": "Changes converted to JSON and pushed to Firestore 'documents' collection with 500ms debounce; other users receive updates instantly via snapshots().listen.",
          "live_presence": "Writes boolean to 'presence' collection to show online user count (e.g., '🟢 3 Online').",
          "live_mouse_pointers": "Tracks pointer movement via Flutter's Listener, updates X/Y coordinates to 'mice' sub-collection; other users see floating initial-letter icons at those coordinates."
        },
        "excel_data_grid": {
          "spreadsheet_ui": "Powered by SfDataGrid (syncfusion_flutter_datagrid) with columns A-I, cell selection, and double-click editing.",
          "manual_save_sync": "Edited grid data mapped to JSON and uploaded to 'excel_sheets' collection on Save; other users' Firestore listeners auto-refresh their grid.",
          "live_mouse_pointers": "Similar pointer tracking under the current excel sheet's 'mice' collection, shown as floating pointers to other users."
        }
      }
    },
    {
      "id": 7,
      "date": "06 July 2026",
      "title": "Combined Notes & Real-Time 1-on-1 Chat App using GetX state management and Firestore",
      "description": "A combined notes-taking and real-time chat application built with Flutter and GetX, featuring Firebase Authentication and Firestore-powered live data.",
      "tech_stack": ["Flutter", "GetX", "Firebase Authentication", "Cloud Firestore"],
      "features": {
        "authentication": "Firebase Auth for login/registration; user info (Name, Email, UID) saved to Firestore 'users' collection via UserModel; ValidationService validates email/password.",
        "notes_management": "Full CRUD via NoteController (GetX); notes saved to Firestore 'notes' collection with uid and timestamp; real-time stream filtered by userId, sorted by timestamp (newest first).",
        "realtime_chat": "1-on-1 messaging; MessageController generates unique chatroomId by sorting both users' UIDs (getChatroomId); messages stored in 'messages' sub-collection; updates parent chatroom with lastMessage/lastMessageTime; Firestore snapshots provide instant updates.",
        "recent_chats": "ChatController queries 'chatrooms' where participants array contains current UID, sorted by lastMessageTime (WhatsApp-style).",
        "user_search": "SearchPageController queries 'users' collection with isGreaterThanOrEqualTo for dynamic name search, filtering out current user.",
        "architecture": "GetX reactive state management (.obs, RxList, RxBool) with clean separation of Views, Controllers, Models, and Database logic."
      }
    },
    {
      "id": 8,
      "date": "13 July 2026",
      "title": "E-Commerce App featuring local SQLite authentication, native device calendar synchronization, and offline background task execution",
      "description": "A multi-feature Flutter app combining local authentication, e-commerce functionality, and native device calendar integration with offline background sync.",
      "tech_stack": ["Flutter", "GetX", "SQLite (sqflite)", "Realm Database", "device_calendar", "table_calendar", "workmanager", "connectivity_plus"],
      "features": {
        "authentication": "Local SQLite-based auth via RegisterDb; signup checks for existing email/phone, login verifies credentials, session flag (isLoggedIn) persists across restarts.",
        "ecommerce": {
          "products": "Browse product list and details, powered by Realm database (product.realm.dart).",
          "cart": "Add/remove products, adjust quantities; cart state managed reactively via GetX and persisted with Realm (cart_item.realm.dart).",
          "orders": "Place orders from cart; order history stored/retrieved via Realm (order.realm.dart)."
        },
        "calendar_integration": "Uses device_calendar package to sync with native calendar (Google/Apple); fetches events for next 365 days, allows creating events, displayed via table_calendar widget.",
        "background_sync": "workmanager runs background task (syncOfflineEvents) to push queued offline-created events once connectivity is restored (monitored via connectivity_plus).",
        "architecture": "GetX ecosystem throughout - dedicated controllers for Auth, Cart, Product, Orders, Calendar; reactive variables (.obs) auto-update UI; GetX used for navigation (Get.offAll)."
      }
    },
    {
      "id": 9,
      "date": "27 July 2026",
      "title": "Zoom Meeting Management App with Zoom API integration to create, join, and manage meetings seamlessly via embedded web view",
      "description": "A video conferencing management app integrated with the Zoom API, allowing users to create, join, and manage Zoom meetings directly within the app via an embedded web view.",
      "tech_stack": ["Flutter", "GetX", "Node.js", "MongoDB", "Zoom API", "flutter_inappwebview", "bcrypt", "permission_handler"],
      "features": {
        "authentication": "Registration and login with bcrypt password hashing; secure logout clears active session.",
        "dashboard": "Join meeting by Meeting ID field; scrollable meeting history list with pull-to-refresh; friendly empty state with refresh button.",
        "meeting_management": {
          "create": "Bottom-sheet UI to input Topic and Duration; backend calls Zoom API to generate real meeting link, ID, and password, saved to database.",
          "join": "Join button extracts joinUrl and launches meeting in-app.",
          "delete": "Confirmation dialog before deleting meeting from both database and Zoom's servers via API."
        },
        "in_app_video": "Embedded Web View (flutter_inappwebview) transforms Zoom link into Zoom Web Client link (/wc/join/), avoiding need for official Zoom app; automatic camera/mic permission handling via permission_handler; loading progress bar; easy exit via close button.",
        "technical": "GetX for state management; meetings tied to userId in MongoDB; robust error handling with Get.snackbar notifications."
      }
    },
    {
  "id": 10,
  "date": "29 july 2026",
  "title": "Flutter Auth & Profile CRUD App featuring comprehensive end-to-end Integration Testing",
  "description": "A Flutter application focused on seamless user authentication and complete profile management. It features a clean Material 3 UI, GetX for state management, and comprehensive end-to-end integration testing to ensure reliable user flows.",
  "tech_stack": [
    "Flutter",
    "GetX (State Management & Routing)",
    "Dio (Networking)",
    "Shared Preferences (Local Session Storage)",
    "Image Picker",
    "Integration Test (E2E Testing Framework)"
  ],
  "features": {
    "authentication": "Secure user Registration and Login flows managed via AuthController. Implements session persistence using SharedPreferences to seamlessly route logged-in users directly to their Profile screen on app launch.",
    "profile_management": "Complete CRUD functionality for user profiles. The Edit Profile screen allows users to dynamically update their Username, Phone, Age, Gender, and Address, with the UI immediately reflecting changes managed by the ProfileController.",
    "integration_testing": "end-to-end (E2E) automated testing via `complete_test.dart`. It programmatically verifies the entire user journey: filling out registration forms, logging in, verifying UI element renders, simulating typing in the edit profile form, saving, and successfully logging out.",
    "ui_ux": "A responsive and structured user interface built utilizing Flutter's Material 3 design system. It includes clearly defined form fields, loading indicators, and snackbar notifications for immediate user feedback.",
    "architecture": "Clean, feature-first modular architecture separating concerns into `auth` and `profile` modules, ensuring maintainability and scalability."
  }
},
 {
      "id": 11,
      "date": "31 July 2026",
      "title": "Local Notes Application strictly following Clean Architecture principles, using Riverpod",
      "description": "A local Todo/Notes application built with Flutter following clean architecture, separating UI, State, Data, and Database layers, using Riverpod for state management and SQLite for storage.",
      "tech_stack": ["Flutter", "Riverpod", "SQLite (sqflite)", "Clean Architecture"],
      "layers": {
        "database_layer": "db_helper.dart uses sqflite to create local database 'todo_app.db' with a 'todos' table (id, title, description, isCompleted as integer 0/1); Singleton pattern ensures single DB connection.",
        "data_model": "todo_model.dart defines Todo class (id, title, description, isCompleted) with toMap() and fromMap() helper methods to convert between Dart objects and SQLite Maps.",
        "repository_layer": "todo_repository.dart bridges database and app logic with CRUD functions: insert(), getAllTodos(), update(), delete().",
        "state_management": "todo_controller.dart (StateNotifier via Riverpod) holds List<Todo>; calls _loadTodos() on start and after every add/edit/delete to refresh in-memory list; todo_provider.dart exposes controllers app-wide.",
        "ui": "HomeView uses ref.watch(todoControllerProvider) to reactively rebuild ListView; AddEditTodoView handles input forms and calls addTodo()/updateTodo() via ref.read()."
      }
    },

{
  "id": 12,
  "date": "04 August 2026",
  "title": "ReelLike — Short Video Sharing App with Vertical Feed, Like System & Cloud Upload",
  "description": "A short-form video sharing app built with Flutter, inspired by Instagram Reels. Users upload videos to the cloud and browse an infinite vertical feed with real-time likes — powered by Firebase Firestore and Cloudinary.",
  "tech_stack": [
    "Flutter",
    "Riverpod (flutter_riverpod)",
    "Firebase Firestore (cloud_firestore)",
    "Cloudinary REST API",
    "Native Android Platform View (MethodChannel + EventChannel)",
    "image_picker",
    "video_player",
    "http"
  ],
  "features": {
    "vertical_video_feed": {
      "title": "Full-Screen Vertical Video Feed",
      "description": "PageView.builder (vertical) full-screen feed; visible reel auto-plays, others pause. Data from Firestore real-time stream, sorted newest first. Shows loading, empty, and error states."
    },
    "app_lifecycle_handling": {
      "title": "Lifecycle-Aware Playback",
      "description": "Videos auto-pause on app background/inactive and resume on foreground; also pause when navigating to upload screen and resume on return."
    },
    "like_unlike_system": {
      "title": "Like & Unlike Reels",
      "description": "Heart icon toggles like state (session-only, stored in local Set, no auth). Firestore 'likes' field updated atomically via FieldValue.increment()."
    },
    "video_upload": {
      "title": "Video Upload with Preview",
      "description": "Pick video from gallery, live looping preview, title input (max 100 chars) with validation, upload button with loading state, success/failure SnackBar."
    },
    "cloudinary_video_storage": {
      "title": "Cloud Storage via Cloudinary",
      "description": "Videos uploaded via unsigned preset using HTTP multipart POST to Cloudinary; returns secure CDN URL. Credentials currently hardcoded."
    },
    "firebase_firestore_database": {
      "title": "Firebase Firestore Database",
      "description": "'reels' collection stores id, title, videoUrl, createdAt, likes. Real-time sync across devices via snapshots()."
    },
    "native_android_video_player": {
      "title": "Native Android Video Player",
      "description": "Custom AndroidView-based player with unique MethodChannel/EventChannel per instance. Supports play/pause/retry, buffering/error states. Android-only, no iOS."
    },
    "state_management_riverpod": {
      "title": "Riverpod State Management",
      "description": "reelsFeedProvider (stream), reelControllerProvider (upload logic), plus service providers for Cloudinary/Firebase. Screens use ConsumerStatefulWidget."
    }
  },
  "architecture": {
    "pattern": "Service-Controller-View (Riverpod for DI)",
    "description": "Views render UI, Controllers manage logic/state, Services handle external APIs, Models define data structures."
  },

  
},{
  "id": 13,
  "date": "06 August 2026",
  "title": "AI Chat — Gemini-Powered Chatbot App with Markdown Rendering",
  "description": "A Flutter chatbot app using Riverpod and Google Gemini API. Users send messages and receive AI responses rendered in rich Markdown format.",

  "tech_stack": ["Flutter", "Riverpod", "Dio", "flutter_dotenv", "flutter_markdown_plus", "intl", "Material 3"],

  "architecture": "Riverpod Notifier Pattern — Controllers handle logic, Services handle API calls, Models hold data, Widgets render UI",

  "features": {
    "ai_chat": "Single-screen chat UI — user messages (blue, right) and AI responses (grey, left) with auto-scroll",
    "gemini_api": "REST calls to Gemini API (gemini-flash-latest) via Dio with .env-based API key",
    "markdown_rendering": "AI responses rendered as rich Markdown (bold, lists, code blocks) using flutter_markdown_plus",
    "timestamps": "Every message shows time in hh:mm a format",
    "loading_indicator": "Spinner shown while waiting for AI response",
    "error_handling": "Graceful handling of network errors and API failures"
  },

  "project_structure": {
    "main.dart": "Entry point — loads .env, initializes ProviderScope",
    "controllers/chat_controller.dart": "Manages messages list and loading state",
    "models/chat_state.dart": "Immutable state — messages + isLoading",
    "models/message_model.dart": "Message data — text, isUser, timestamp",
    "screens/ai_screen.dart": "Chat UI — message list, input field, send button",
    "services/gemini_service.dart": "Gemini API calls via Dio",
    "widgets/message_bubble.dart": "Styled chat bubble with Markdown support"
  },

}
,
   
 {
  "id": 14,
  "date": "12 August 2026",
  "title": "MoneyMate - Personal Expense Tracker with Multi-User Support, Shared Debits, Analytics Charts, Admin Panel, Google Maps Location, and Data Backup/Restore",
  "description": "A Flutter + Riverpod finance app for multiple users on one device to track income/expenses, share debits, view spending charts, attach receipts, and backup/restore data. Includes an admin panel to manage all users.",
  "tech_stack": [
    "Flutter",
    "Riverpod (flutter_riverpod) - State Management",
    "SQLite (sqflite) - Transaction Storage",
    "Realm Database - Auth & User Storage",
    "Syncfusion Flutter Charts - Analytics",
    "Google Maps Flutter - Location",
    "Geolocator & Geocoding - GPS & Address",
    "Image Picker - Receipt Upload",
    "Device Info Plus - Device Detection",
    "Share Plus - Backup Sharing",
    "File Picker - Backup Restore",
    "Archive (Zip) - Backup Compression"
  ],
  "features": {
    "authentication_and_multi_user": {
      "title": "Offline Authentication with Multi-User Account Switching",
      "description": "Offline signup/login via Realm. Multiple accounts per device, easy switching, first user = Admin, session persists on restart."
    },
    "transaction_management": {
      "title": "Complete Income & Expense CRUD with Categories and Payment Methods",
      "description": "Add/edit/delete Income & Expense with title, amount, date, category, payment method, notes, and optional receipt image. Stored per-user in SQLite, sorted by date."
    },
    "home_dashboard": {
      "title": "Home Dashboard with Summary Card, Monthly Overview, and Tabbed Transaction Lists",
      "description": "Summary card (Balance, Credit, Debit) with animated counters, monthly & weekly overview. Two tabs: My Debit and Shared Debit, both with infinite scroll. Tap, swipe-to-share, edit, delete supported."
    },
    "shared_debit_system": {
      "title": "Share Expenses Between Users on the Same Device",
      "description": "Share any expense with other device users via a picker dialog; appears in their Shared Debit tab with sender's name shown."
    },
    "analytics_and_charts": {
      "title": "Interactive Analytics with Syncfusion Charts, Category Breakdown, and Time Filters",
      "description": "Day/Month/Year filters, Expense/Income toggle. Shows trend charts, category-wise pie chart, and total income/expense/balance."
    },
    "transaction_detail_and_receipt_viewer": {
      "title": "Detailed Transaction View with Receipt Image Viewer and Edit Option",
      "description": "Detail screen with amount, title, category, date/time, payment method, notes, zoomable receipt viewer, and direct edit option."
    },
    "transaction_audit_logs": {
      "title": "Full Transaction Audit Log - Track Every Create, Update, and Delete Action",
      "description": "Logs every create/update/delete with old & new data and timestamp. History viewable per transaction; separate screen for deleted logs; auto-fixes missing logs on startup."
    },
    "transaction_history": {
      "title": "Full Transaction History with Search and Browsing",
      "description": "Dedicated History screen (bottom nav + 'SEE ALL') showing all transactions in a scrollable list."
    },
    "profile_screen": {
      "title": "User Profile with Location, Account Switching, Settings, and Admin Access",
      "description": "Shows name, email, location. Access to Maps location picker, Settings, account switching, and Admin Panel (admin only)."
    },
    "google_maps_location": {
      "title": "Google Maps Integration with GPS, Address Lookup, and Location Saving",
      "description": "GPS auto-detect via Geolocator, reverse geocoding for address, tap-to-select location, saved to profile in Realm."
    },
    "admin_panel": {
      "title": "Admin Dashboard - View All Users, Their Transactions, and Transfer Admin Rights",
      "description": "Shows all users grouped by location; view any user's summary & transactions, delete via swipe, and transfer admin rights."
    },
    "backup_and_restore": {
      "title": "Data Backup & Restore with Filtered Export and ZIP Compression",
      "description": "Backup All/Credit/Debit data as ZIP, share via native share sheet. Restore from .zip/.db with validation, WAL/SHM cleanup, auto-assigned to current user."
    },
    "settings_screen": {
      "title": "Settings with Active Device Info, Backup & Restore Controls",
      "description": "Shows active device info (via Device Info Plus) and Data Management section with Backup/Restore buttons."
    },
    "bottom_navigation": {
      "title": "4-Tab Bottom Navigation - Home, History, Charts, Add",
      "description": "Bottom nav with Home, History, Charts, and Add tabs for quick access."
    },
    "architecture_and_state_management": {
      "title": "Clean Architecture with Riverpod, Repository Pattern, and Dual Database System",
      "description": "Clean architecture: Models, Repositories, Riverpod StateNotifierProviders, Screens, reusable Widgets. Dual DB: Realm (auth/profile) + SQLite (transactions). AsyncValue for state."
    }
  }
}

    ,

  ]
};