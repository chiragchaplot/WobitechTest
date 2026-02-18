# Wobitech Test

## Architecture
This app is structured with separate presentation, domain, and data layers.

- App entry point: `Wobitech_TestApp` in `Wobitech Test/Wobitech_TestApp.swift`
- Presentation layer: `Wobitech Test/Presentation Layer/ContentView.swift`
- Domain layer:
  - `GetOrderListUseCase` protocol in `Wobitech Test/Domain Layer/GetOrderListService.swift`
  - `GetOrderListService` actor (currently returns an empty `OrderList` placeholder)
- Data layer:
  - `APIRequest` protocol + default URLRequest builder in `Wobitech Test/Data Layer/APIRequests/APIRequest.swift`
  - `NetworkServiceProtocol` and `NetworkService` actor in `Wobitech Test/Data Layer/APIRequests/NetworkService.swift`
  - Order entities in `Wobitech Test/Data Layer/APIRequests/OrderList.swift`

## Testing
Unit tests use Swift Testing (`import Testing`) in `Wobitech TestTests/`.

- `Wobitech TestTests/NetworkServiceTests.swift` covers `NetworkService.execute` for:
  - successful decoding (2xx)
  - invalid request URL
  - non-2xx HTTP status handling
  - non-HTTP response handling
  - decoding failures
- Test helpers and mocks:
  - `Wobitech TestTests/Helpers and Mocks/MockURLProtocol.swift`
  - `Wobitech TestTests/Helpers and Mocks/MockRequests.swift`
  - `Wobitech TestTests/Helpers and Mocks/MockResponse.swift`

## Current Status
- `ContentView` currently shows the default SwiftUI starter UI.
- Domain and data layers are in place, but not yet wired into the presentation layer.
- `GetOrderListService` is currently a scaffold and does not call `NetworkService` yet.

## Formatting and Linting
This project runs SwiftFormat and SwiftLint automatically on every build:

- SwiftFormat: `.swiftformat`
- SwiftLint: `.swiftlint.yml`

Install tools with Homebrew:

```sh
brew install swiftformat swiftlint
```

Run them manually from the project root:

```sh
swiftformat .
swiftlint --fix
```
