# Take-Home Assignment: SwiftUI Feature – Rick and Morty Characters (REST)

## Setup
There are no special requirements for setting up this project.
Simply open the `Rick and Morty Characters.xcodeproj` file in the root folder and Run or Test the application making sure to select the iOS simulator of your choice.

## Decisions
To keep the project focused on native Swift/SwiftUI features, no third-party libraries were used.
This project is architected using MVVM since it's simple yet very suitable for maintainability and decoupling. It also aligns well with the State/Binding paradigm of SwiftUI by using the `ObservedObject` protocol.

During development and testing, I noticed that some information provided by the API could be missing or empty. The application attempts to recover from these scenarios as gracefully as possible by filling empty values with the word "Unknown". 

The project is divided into 4 main folders: Model, Networking, View, and ViewModel.

### Model
Contains all models used by the application

### Networking
Contains structs used to call the REST API

### View
Contains SwiftUI views used in the application. Mainly a List View and a Details View.

### ViewModel
Contains view models responsible for managing application state and business logic, handling user interactions and data binding with SwiftUI views.

### Search
In order to maintain a cleaner interface, the search feature uses two different native methods. The text search bar targets the `name` field, while the `status` filter uses a `searchScopes` modifier.

### Dependency Injection
Dependencies are declared as protocols with a default value as much as possible specialy in the Networking Layer.
Since the application is simple enough to not justify the use of a more robust DI solution such as SwiftInject, for instance, the decision was to at least make the some classes to rely on abstractions instead of implementations so we can swap different implementation easily.

## Possible Improvements & Add Next

- Unit tests focused primarily on API calls and model parsing, as the UI is tested separately in a different target. More test cases and test scenarios could be implemented in order to cover more use cases even in the SUTs that are already being tested

- UI test cases could be implemented in the future in order to assert the correctness of the Design

- The image download could fail and a automatic retry function could be implemented using AsyncImage

- The current design is very plain black & white and in the future could be replaced by a more futuristic/cartoonish one to match the theme of Rick and Morty making use of colors, custom background and custom fonts

- There's more data that could be integrated into the app to improve User Experience. As a suggestion, the application could implemented tabs in order to navigate in the Locations and Episodes information and reuse these screens so they could be accessible also from the Characters tab

- To make the iPad UX more effective, this application could use a SplitView for the List -> Details relationship   
