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

3. **Start the Mock API:**
   You need `Node.js` installed. In a separate terminal window, run:
   ```bash
   npm install
   npm start
   ```
   *(Ensure your terminal is in the project root where `package.json` and `db.json` are located).*

4. **Run the Flutter Application:**
   You can run the app on the web or an emulator:
   ```bash
   flutter run -d web-server --dart-define=API_BASE_URL=http://localhost:3000
   ```
   *(If you are running on Android/iOS, change `http://localhost:3000` to your local machine's IP address or `http://10.0.2.2:3000` for Android emulator).*

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

## 7. Platform Configuration
### iOS
To support camera and photo library access via `image_picker`, the following usage descriptions were added to `ios/Runner/Info.plist`:
- `NSCameraUsageDescription`: Required to take photos for task evidence.
- `NSPhotoLibraryUsageDescription`: Required to select existing photos for task evidence.

### Android
Starting with `image_picker` version 0.8.1+, no additional configuration is required in `AndroidManifest.xml` for basic image selection and camera usage. Standard intents are used which do not mandate explicit permission declarations. Thus, the Android configuration remains untouched and fully compatible.

## 8. Mock Server & Chat Bot
- The Express server (`server.js`) was extended to emulate a production environment for the Chat feature.
- `GET /api/tasks/:id/messages` successfully serves wrapped data and loads the task assignees into `meta.participants`.
- Simulated chat replies are exclusively sourced from the validated pool of assignees, guaranteeing that no rogue participants are injected into a task.

## 9. Main Dependencies
- `flutter_riverpod`: State management.
- `dio`: HTTP client for API requests.
- `go_router`: Declarative routing and navigation.
- `image_picker`: For selecting photos from the camera or gallery.
- `intl`: For parsing and formatting dates nicely.

## 10. Known Limitations
- **Image Uploads:** Since `json-server` does not handle multipart file uploads natively, attaching an image during a status update is simulated. The app will successfully display the image from memory on the Web/Native, but it saves a placeholder image URL (`https://picsum.photos/400/300`) to the database.
- **Real-time Chat:** The chat uses standard HTTP requests rather than WebSockets. Polling or manual refresh is typically required, though optimistic UI updates are implemented for a smoother experience.

## 11. Assumptions Made During Development
- The app should focus on a clean, premium, and responsive user experience.
- The user ID is mocked as `"user_001"` since there is no authentication layer.
- The `json-server` handles simple PATCH requests, but complex array append operations (like adding a status transition to the history) must be processed on the client side by fetching the array, appending the item, and patching the whole array back.

## 12. AI Usage and Verification
During development, my primary focus was designing the architecture and writing the core logic. I utilized AI assistance (Gemini 3.1 Pro) as a secondary copilot to accelerate specific tasks:
- **Assisted parts:** Used to generate boilerplate for unit tests (`task_list_provider_test.dart`), draft basic setup scripts like the Node.js mock server, and quickly query Riverpod 3.x quirks. AI was also used to scaffold the extensive regression test suite (mocking repositories, simulating image pickers).
- **Rejected/Changed test:** The AI originally suggested a test for `ChatInputField` that asserted success merely by checking if `sendMessage` was called on a Mock class. I rejected this and changed it to explicitly wait for `tester.pumpAndSettle()` and assert that the text field was cleared, which is the actual user-facing outcome we care about.
- **Verification of failures:** To verify that tests fail for the intended reasons, I manually injected regressions into the codebase (e.g., returning early before `.clear()`, or skipping the `hasImage` validation check) and observed the test runner catch the exact failure. This proved the tests are actively protecting the behaviors.
- **Risk of AI-generated tests:** A significant risk identified during review is that AI often generates "tautological tests" that simply mock an interface and assert that the mock was called with specific arguments, rather than testing observable state changes in the UI. This provides high code coverage but zero actual confidence in the application's behavior. I actively rewrote several tests to ensure they assert on `find.text()` and Widget states instead of just checking spy methods.

## 13. Automated Tests
A comprehensive suite of meaningful, automated regression tests has been included to verify core logic and protect against known blocking defects without requiring a live server or physical device.

The test suite covers:
- **Core & Models:** Validation of wrapped API responses (`PaginatedResponse`), `PaginationMeta`, and parsing resilience for `ChatMessageModel`.
- **Task Listing:** Regression tests for search debounce, state-preservation, and UI states (Loading, Empty, Success, Error).
- **Status Transition:** Regression tests for "false success" bugs. Validates Note-only, Image-only, missing evidence boundaries, and form preservation upon network failure.
- **Task Chat:** Validates deterministic sorting, input clearing behavior, participant matching, and prevents duplicate messages upon retry.

You can run the tests using:
```bash
flutter test
```
