# Wobitech Test

## Project Overview
The app uses a clean layered structure:

- `Presentation Layer`: SwiftUI views + `@Observable` view models
- `Domain Layer`: use-case/service actors
- `Data Layer`: request models and shared network service

Entry point:

- `Wobitech Test/Wobitech_TestApp.swift`

## Current User Flows

### Orders List
Files:

- `Wobitech Test/Presentation Layer/Orders List/OrdersListView.swift`
- `Wobitech Test/Presentation Layer/Orders List/OrdersListViewModel.swift`

Behavior:

- Fetches orders on first appear
- Supports pull-to-refresh
- Supports filter menu: `All`, `Pending`, `In Transit`, `Delivered`
- Dynamic title includes filter and count
- Screen state handling:
  - `.loading`: progress view
  - `.successful`: list + navigation to order details
  - `.noData`: `Loading Data...`
  - `.error`: alert with retry

### Order Details
Files:

- `Wobitech Test/Presentation Layer/Order Details/OrderDetailsView.swift`
- `Wobitech Test/Presentation Layer/Order Details/OrderDetailsViewModel.swift`
- `Wobitech Test/Presentation Layer/Order Details/OrderDeliveredImageView.swift`

Behavior:

- List-to-details navigation passes only `orderID`
- View model fetches detail through `GetOrderDetailUseCase`
- UI is driven by `OrderDetailsDisplayModel`
- Displays:
  - Order ID, Order name
  - From name, final delivery name
  - From address, final address
  - Status, start date
  - Estimated delivery or delivered-at (based on status)
  - Last location (for non-delivered)
  - Driver (for pending pickup)
- If status is delivered, shows delivered image from asset `deliveredPhoto` using a square reusable view

## Services and Data

### Order List Service
File:

- `Wobitech Test/Domain Layer/GetOrderListService.swift`

Behavior:

- Simulates API delay (`3` seconds)
- Returns mock data when `shouldSucceed = true`
- Throws `NetworkError.requestFailed(500)` when `shouldSucceed = false`
- Caches latest fetched list for detail fallback

### Order Detail Service
File:

- `Wobitech Test/Domain Layer/GetOrderDetailService.swift`

Related request/models:

- `Wobitech Test/Data Layer/APIRequests/OrderDetail/OrderDetailRequest.swift`
- `Wobitech Test/Data Layer/APIRequests/OrderDetail/OrderDetail.swift`
- `Wobitech Test/Data Layer/APIRequests/OrderList/OrderList.swift`

Behavior:

- `getOrderDetail(for:)`:
  - Calls network with `OrderDetailRequest` (`/api/v1/orders/{orderID}`)
  - Falls back to cached order list mapping when network fetch fails and cache exists
- `streamOrderDetail(for:pollingInterval:)`:
  - Polls every `10` seconds by default
  - Swallows transient poll errors and keeps polling
  - Does not terminate stream on temporary failures

### Network Service
File:

- `Wobitech Test/Data Layer/APIRequests/Common/NetworkService.swift`

Behavior:

- Builds and executes requests from `APIRequest`
- Decodes JSON with ISO-8601 dates
- Throws typed `NetworkError` values

## Testing
Tests use Swift Testing (`import Testing`) under `Wobitech TestTests/`.

### Data Layer

- `Wobitech TestTests/DataLayerTests/NetworkServiceTests.swift`
  - execute success/error paths
  - stream polling behavior

### Domain Layer

- `Wobitech TestTests/DomainLayerTests/GetOrderListServiceTests.swift`
- `Wobitech TestTests/DomainLayerTests/GetOrderDetailServiceTests.swift`
  - detail fetch decoding/path behavior
  - stream keeps polling after initial failure and eventually yields

### Presentation Layer

- `Wobitech TestTests/PresentationLayerTests/OrdersListViewModelTests.swift`
- `Wobitech TestTests/PresentationLayerTests/OrderDetailsViewModelTests.swift`
  - detail fetch success/error state transitions
  - display model mapping
  - streaming starts only for `PENDING`/`INTRANSIT`
  - no streaming for `DELIVERED`

### Test Helpers and Mocks

- `Wobitech TestTests/Helpers and Mocks/MockURLProtocol.swift`
- `Wobitech TestTests/Helpers and Mocks/MockRequests.swift`
- `Wobitech TestTests/Helpers and Mocks/MockResponse.swift`
- `Wobitech TestTests/Helpers and Mocks/MockGetOrderListService.swift`
- `Wobitech TestTests/Helpers and Mocks/MockGetOrderDetailService.swift`

## Build Tooling
SwiftFormat and SwiftLint are configured to run on build.

Config files:

- `.swiftformat`
- `.swiftlint.yml`

Install tools:

```sh
brew install swiftformat swiftlint
```

Manual run:

```sh
swiftformat .
swiftlint --fix
swiftlint
```
