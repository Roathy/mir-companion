# Gemini Project Context: mir_companion_app

This document provides context for the `mir_companion_app`, a Flutter project. It outlines the project's purpose, architecture, and development conventions to guide future work.

## 1. Project Overview

- **Project Name:** `mironline` / `mir-companion`
- **Purpose:** A mobile companion application for the "Make it Real!" language learning book series.
- **Platform:** Flutter (for iOS and Android).
- **Key Features:**
    - User authentication via Google Sign-In and email/password.
    - A feature-driven experience including a welcome tour, English Grammar Program (EGP) levels and units, and other learning activities.
    - Token-based authentication with secure storage.

## 2. Technologies & Libraries

- **State Management:** **Riverpod** with code generation (`riverpod_generator`). Providers are the primary way to manage state and access dependencies.
- **Networking:** The project uses both `dio` and `http`.
    - `dio` is exposed via a Riverpod provider (`apiClientProvider`) and is used for fetching feature-specific data (e.g., EGP levels).
    - The `http` package is used within the `AuthService` for authentication-related requests.
- **Data Modeling:** The project has `freezed` and `json_serializable` as dependencies, but some existing domain models are plain Dart classes. This suggests a mixed or evolving convention.
- **Authentication:** `google_sign_in` for Google auth and `flutter_secure_storage` for persisting auth tokens.
- **Environment Variables:** `envied` is used for managing environment-specific configuration.
- **Code Generation:** `build_runner` is a critical part of the development workflow for Riverpod, Freezed, and Envied.

## 3. Architecture

- **Feature-Driven:** The codebase is organized by features in the `lib/features` directory. Each feature folder typically contains subdirectories for `presentation`, `domain`, and `data`.
- **State & Dependencies:** Riverpod providers are used to inject dependencies (like `ApiClient`, `AuthService`) and manage application state. Providers are defined both globally (e.g., `lib/services/providers.dart`) and within their respective feature modules.
- **API Interaction:** API requests require custom headers, including an `Authorization` bearer token and a custom `X-App-MirHorizon` header containing an MD5 hash.

## 4. Development Workflow

1.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

2.  **Run Code Generation:**
    A `build_runner` command is required to generate code for Riverpod, Freezed, and Envied. Use the `watch` command in a separate terminal during development to automatically regenerate files on change.
    ```bash
    dart run build_runner watch --delete-conflicting-outputs
    ```

3.  **Run the App:**
    ```bash
    flutter run
    ```

## 5. Coding Conventions & Best Practices

- **State Management:** For new features, prefer creating providers using the `@riverpod` annotation syntax (`riverpod_generator`).
- **Immutability:** Given the use of `freezed`, new data models should be immutable.
- **Networking:** For consistency, new API calls should prefer using the `dio` instance provided by `apiClientProvider` rather than using the `http` package directly.
- **Error Handling:** Many parts of the code have `// TODO: Add proper error handling`. Future work should focus on implementing robust error handling and user feedback mechanisms.
- **Routing:** The app uses a simple `MaterialApp` named routes map in `lib/main.dart`. For more complex navigation, consider migrating to a package like `go_router`.
