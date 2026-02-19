# Wobitech Test

## Architecture
This app is structured with separate presentation, domain, and data layers.

- App entry point: `Wobitech_TestApp` in `Wobitech Test/Wobitech_TestApp.swift`
- Presentation layer:
  - `HomeView` in `Wobitech Test/Presentation Layer/HomeView.swift`
  - `OrdersListView` in `Wobitech Test/Presentation Layer/Orders List/OrdersListView.swift`
  - `OrdersListViewModel` (`@Observable`) in `Wobitech Test/Presentation Layer/Orders List/OrdersListViewModel.swift`
  - `OrderDetailsView` in `Wobitech Test/Presentation Layer/Order Details/OrderDetailsView.swift`
  - `OrderDetailsViewModel` (`@Observable`) in `Wobitech Test/Presentation Layer/Order Details/OrderDetailsViewModel.swift`
- Domain layer:
  - `GetOrderListUseCase` protocol in `Wobitech Test/Domain Layer/GetOrderListService.swift`
  - `GetOrderListService` actor with simulated API delay and success/failure toggle (`shouldSucceed`)
- Data layer:
  - `APIRequest` protocol + default URLRequest builder in `Wobitech Test/Data Layer/APIRequests/APIRequest.swift`
  - `NetworkServiceProtocol` and `NetworkService` actor in `Wobitech Test/Data Layer/APIRequests/NetworkService.swift`
  - Order entities in `Wobitech Test/Data Layer/APIRequests/OrderList.swift`

## Testing
Unit tests use Swift Testing (`import Testing`) in `Wobitech TestTests/`.

- Data layer tests:
  - `Wobitech TestTests/DataLayerTests/NetworkServiceTests.swift` covers `NetworkService.execute` for:
  - successful decoding (2xx)
  - invalid request URL
  - non-2xx HTTP status handling
  - non-HTTP response handling
  - decoding failures
- Domain layer tests:
  - `Wobitech TestTests/DomainLayerTests/GetOrderListServiceTests.swift` covers success and failure behavior of `GetOrderListService`
- Presentation layer tests:
  - `Wobitech TestTests/PresentationLayerTests/OrdersListViewModelTests.swift` covers state transitions, retry, pull-to-refresh behavior, and status filtering
- Test helpers and mocks:
  - `Wobitech TestTests/Helpers and Mocks/MockURLProtocol.swift`
  - `Wobitech TestTests/Helpers and Mocks/MockRequests.swift`
  - `Wobitech TestTests/Helpers and Mocks/MockResponse.swift`
  - `Wobitech TestTests/Helpers and Mocks/MockGetOrderListService.swift`

## Current Status
- `HomeView` is a `TabView` with exactly 2 tabs:
  - `Orders` tab (orders list)
  - `Details` tab (order details)
- Each tab is its own view and has its own `@Observable` view model.
- `OrdersListView` supports pull-to-refresh and status-based filtering (All, Pending, In Transit, Delivered).
- `OrdersListView` reacts to screen state:
  - `successful`: shows list
  - `loading`: shows progress view
  - `noData`: shows “Loading Data...”
  - `error`: shows retry alert
- `GetOrderListService` currently simulates network behavior and returns mock data.

## Formatting and Linting
SwiftFormat and SwiftLint are configured as Xcode build script phases on the `Wobitech Test` target and run on every build.

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
