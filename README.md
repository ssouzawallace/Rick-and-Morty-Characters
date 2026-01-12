# Rick and Morty Characters – SwiftUI App (REST API)

## Overview
This is a native iOS application built with SwiftUI that displays characters from the Rick and Morty TV series. The app fetches data from the [Rick and Morty API](https://rickandmortyapi.com) and provides features to browse, search, and view detailed information about characters.

## Setup
No special requirements or third-party dependencies are needed to run this project.

To get started:
1. Open `Rick and Morty Characters.xcodeproj` in the root directory
2. Select an iOS simulator of your choice
3. Press Run to build and launch the app

## Architecture & Design Patterns

### MVVM Architecture
The application follows the MVVM (Model-View-ViewModel) pattern, which provides clear separation of concerns:
- **Models**: Data structures representing API responses and domain objects
- **Views**: SwiftUI components responsible for UI rendering
- **ViewModels**: Manage application state, handle business logic, and coordinate between views and services

This architecture aligns well with SwiftUI's reactive programming model through the `@Published` property wrapper and `ObservableObject` protocol.

### Project Structure
The project is organized into four main folders:

- **Model**: Contains all data structures including API response models and domain models, plus enum definitions and protocol extensions for presentability
- **Networking**: Contains the service layer with protocol definitions and the `ApiService` implementation for REST API communication
- **View**: Contains SwiftUI components including the character list view and character detail view
- **ViewModel**: Contains `ObservableObject` implementations that manage state and handle user interactions

### Search and Filtering
The search functionality uses two complementary approaches:
- **Text Search**: A searchable modifier that filters characters by `name` field in real-time
- **Status Filter**: A `searchScopes` modifier that allows filtering by character status (Alive, Dead, Unknown)

### Dependency Injection
The networking layer uses protocol-based dependency injection to support testability:
- Dependencies are declared as `Service` protocol with default implementations
- This allows for easy mocking in unit tests and swapping implementations without modifying calling code
- URL session is injected into `ApiService` for flexible configuration

### API Handling
The application gracefully handles API responses:
- Missing or empty data fields are populated with the placeholder text "Unknown"
- Supports pagination for large datasets
- Comprehensive error handling with user-facing error messages

## Key Features

### 1. Character List View
- Displays all characters in a scrollable list
- Pagination support for efficient data loading
- Pull-to-refresh functionality to reload data
- Real-time search and filtering

### 2. Character Search & Filter
- **Text Search**: Search characters by name with debounced input (250ms)
- **Status Filter**: Filter by character status (All, Alive, Dead, Unknown)
- Responsive filtering that updates the list in real-time

### 3. Character Details View
- Displays comprehensive information about a selected character:
  - Character name and image
  - Status (Alive/Dead/Unknown)
  - Species information
  - Gender
  - Origin location
  - Last known location
  - Episode count

## Technical Implementation

### No Third-Party Dependencies
The project uses only native Swift and SwiftUI frameworks to maintain simplicity and reduce external dependencies.

### Networking Layer
- Built with `URLSession` for HTTP requests
- Supports query parameters for pagination, name search, and status filtering
- Implements proper error handling with custom `NetworkingError` types
- Uses async/await for modern concurrency

### State Management
- `@Published` properties for reactive UI updates
- `ObservableObject` protocol for view model reactivity
- Combine framework for event-based programming
- Debounced search input to reduce API calls

### Data Persistence
Missing or incomplete API data is handled gracefully by substituting "Unknown" as placeholder text, ensuring a consistent user experience.

## Testing

The project includes comprehensive test coverage:

### Unit Tests (Target: `Rick and Morty CharactersTests`)
- **Service Tests**: Verify API response parsing and network requests using `MockURLProtocol`
- **ViewModel Tests**: Test state management, search filtering, and data transformations

### UI Tests (Target: `Rick and Morty CharactersUITests`)
- Basic UI test framework in place for future expansion
- UI testing infrastructure configured with XCTest

Tests are written with the `@MainActor` attribute to ensure proper UI thread execution.

## Future Enhancements

### Testing Improvements
- Expand unit test coverage with additional test cases and edge case scenarios
- Implement comprehensive UI tests to validate user workflows and screen navigation
- Add performance testing for large datasets

### Image Loading & Caching
- Implement automatic retry logic for failed image downloads using `AsyncImage`
- Add image caching to improve performance and reduce network usage
- Display placeholder or error state for missing character images

### UI/UX Enhancements
- Redesign the interface with a theme that matches Rick and Morty's aesthetic
- Add custom colors, background patterns, and fonts to enhance visual appeal
- Improve loading states and animations for better user feedback

### Feature Expansion
- Add **Locations Tab**: Browse and filter locations from the Rick and Morty universe
- Add **Episodes Tab**: View episodes and their associated characters
- Create tabbed navigation to allow easy switching between Characters, Locations, and Episodes
- Implement cross-feature navigation (e.g., view all characters in an episode)

### Platform Support
- **iPad Support**: Implement a SplitView layout for improved iPad UX on the Character List/Details relationship
- **Landscape Orientation**: Optimize layouts for both portrait and landscape modes
- **Dark Mode**: Ensure full support for light and dark appearance modes