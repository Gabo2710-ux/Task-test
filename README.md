# Task Manager Application

## 1. Project Overview
This project is a modern, responsive, and elegant Task Manager application built with Flutter. It allows users to view a paginated list of tasks, search for specific tasks, create new tasks, update task statuses (with photo attachments), and participate in task-specific chat threads with an automated simulated bot. The application features a premium UI with a Dark/Light mode toggle.

## 2. Setup Instructions
To run this project locally, follow these steps:

1. **Clone or Extract the Repository:**
   Ensure you are in the root directory of the project (`prueba`).

2. **Install Dependencies:**
   Run the following command in your terminal:
   ```bash
   flutter pub get
   ```

3. **Start the Mock API (json-server):**
   You need `Node.js` installed. In a separate terminal window, run:
   ```bash
   npx json-server --watch db.json --port 3000
   ```
   *(Ensure your terminal is in the project root where `db.json` is located).*

4. **Run the Flutter Application:**
   You can run the app on the web or an emulator:
   ```bash
   flutter run -d web-server
   ```
   *(If you are running on Android/iOS, you might need to change the `baseUrl` in `lib/core/api/api_client.dart` from `http://localhost:3000` to your local machine's IP address or `10.0.2.2` for Android emulator).*

## 3. Flutter Version Used
- **Flutter SDK:** 3.x (Dart SDK `^3.12.2`)

## 4. Supported Platforms
- **Web** (Fully tested and supported)
- **Android / iOS** (Fully supported, adaptive design implemented)
- **Windows / macOS / Linux** (Supported via Flutter desktop capabilities)

## 5. Architectural Approach
The application follows a **Feature-First Architecture** (a lightweight implementation of Clean Architecture). The codebase is divided into clear features:
- `core/`: Contains shared resources like API clients, routing, themes, UI widgets, and utilities.
- `features/tasks/`: Handles the listing, pagination, searching, and creation of tasks.
- `features/task_details/`: Manages the detailed view of a task, status updates, and history timeline.
- `features/chat/`: Manages the messaging interface and simulated bot responses.

Each feature is subdivided into:
- **Models:** Data structures and JSON serialization.
- **Repositories:** Network calls and data mapping.
- **Providers:** State management logic.
- **Presentation:** UI Screens and Widgets.

## 6. State-Management Approach
- **Riverpod (`flutter_riverpod`)**: Used for robust, reactive, and scalable state management.
- **FutureProvider / NotifierProvider**: Used to handle asynchronous API calls (fetching tasks, updating status) and caching data efficiently.
- **StateProvider**: Used for synchronous UI states (like toggling Dark Mode).

## 7. Main Dependencies
- `flutter_riverpod`: State management.
- `dio`: HTTP client for API requests.
- `go_router`: Declarative routing and navigation.
- `image_picker`: For selecting photos from the camera or gallery.
- `intl`: For parsing and formatting dates nicely.

## 8. Instructions for Running the Mock API
The application relies on `json-server` to mock a REST API. 
Run this command from the root of the project:
```bash
npx json-server --watch db.json --port 3000
```
This will expose endpoints like `http://localhost:3000/tasks` and `http://localhost:3000/messages`.

## 9. Known Limitations
- **Image Uploads:** Since `json-server` does not handle multipart file uploads natively, attaching an image during a status update is simulated. The app will successfully display the image from memory on the Web/Native, but it saves a placeholder image URL (`https://picsum.photos/400/300`) to the database.
- **Real-time Chat:** The chat uses standard HTTP requests rather than WebSockets. Polling or manual refresh is typically required, though optimistic UI updates are implemented for a smoother experience.

## 10. Assumptions Made During Development
- The app should focus on a clean, premium, and responsive user experience.
- The user ID is mocked as `"user_001"` since there is no authentication layer.
- The `json-server` handles simple PATCH requests, but complex array append operations (like adding a status transition to the history) must be processed on the client side by fetching the array, appending the item, and patching the whole array back.

## 11. Use of AI Tools
AI assistance was utilized during development to:
- Refactor the UI to implement a cohesive "Premium" aesthetic and integrate a global Dark Mode using `ThemeData`.
- Rapidly debug platform-specific errors, such as mitigating `dart:io` `File` unsupported errors on Flutter Web by migrating to `XFile` and `kIsWeb`.
- Generate automated unit test structures and placeholder data for the mock database.

## 12. Automated Tests
A small suite of meaningful automated tests has been included to verify core logic:
- `test/task_model_test.dart`: Validates JSON parsing, serialization, and correct field mapping for data models.
- `test/widget_test.dart`: Contains basic widget mounting tests.
You can run the tests using:
```bash
flutter test
```
