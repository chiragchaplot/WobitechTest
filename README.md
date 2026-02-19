# Wobitech Test

## Architecture
I used a hybrid of Clean Architecture + SOLID + MVVM because of time and clarity.

- `Presentation Layer`: SwiftUI views and `@Observable` view models.
- `Domain Layer`: use cases/services with business rules.
- `Data Layer`: API request/response models and network abstraction.

Why this approach:

- clean separation of concerns
- modular structure for safe extension
- strong testability
- predictable data flow

Dependency injection is used throughout (network service, use cases, and view model dependencies) so behavior can be replaced with mocks in tests.

## Data And State Flow
- Screen state is explicitly modeled through `ScreenState` (`.noData`, `.loading`, `.successful`, `.error`).
- Orders list flow:
1. View triggers `onAppear`.
2. ViewModel requests data from `GetOrderListUseCase`.
3. State transitions are explicit (`loading -> successful/error/noData`).
4. UI renders state-based content.
- Order detail flow:
1. Details screen loads initial detail via `GetOrderDetailUseCase`.
2. For non-delivered states, updates are observed through `AsyncThrowingStream` polling.
3. UI is driven by mapped display model (`OrderDetailsDisplayModel`) rather than raw transport model.

## Domain vs UI Models
The UI is not directly coupled to raw API/domain models.

- Domain/data entities are mapped into UI-ready values in the ViewModel.
- Presentation renders from `OrderDetailsDisplayModel`.
- If API contracts change, most changes are isolated to Data + Domain + mapping, instead of forcing view rewrites.

This keeps the UI domain-driven while reducing tight transport-model coupling.

## Testing Strategy
I followed a TDD/test-alongside mindset while building.

- Unit tests are present across Data, Domain, and Presentation layers.
- Mocks are used to control success, failure, delay, and retries deterministically.
- State transition testing is a major focus:
  - loading -> success
  - loading -> error
  - error -> retry -> success
  - empty -> noData

Current test suites:

- `Wobitech TestTests/DataLayerTests/NetworkServiceTests.swift`
- `Wobitech TestTests/DomainLayerTests/GetOrderListServiceTests.swift`
- `Wobitech TestTests/DomainLayerTests/GetOrderDetailServiceTests.swift`
- `Wobitech TestTests/PresentationLayerTests/OrdersListViewModelTests.swift`
- `Wobitech TestTests/PresentationLayerTests/OrderDetailsViewModelTests.swift`

What I intentionally did not complete due to time:

- UI/snapshot testing was skipped.
- Async stream polling tests in order details are partially covered but not as deeply as desired.

## Trade-offs Due To Time
- I used `AsyncThrowingStream` + polling for status updates.  
  Ideally, I would explore remote notifications/push-driven updates to reduce battery and data usage.
- I used mocks extensively, but I could have used richer/randomized test data generators for faster scenario setup.
- Localization was added recently. While centralized now, it is still string-key based and can still feel like replacing one magic string with another.
- I would prefer a stronger typed localization approach (for example enum-backed localized keys/structures) to improve compile-time safety and injection patterns similar to API dependencies.

## Safe Evolution
If a new state like `CANCELLED` is introduced, expected change points are:

1. `OrderStatus` domain model update.
2. Filtering/title/display mappings in view models.
3. Strings/localization keys.
4. Any stream/update rule that depends on active states.

What would likely break first:

- switch exhaustiveness in mappings and filters
- tests asserting known state sets

How tests protect this:

- existing state transition tests and mapping tests fail fast on missing handling paths.

## How To Run
Open in Xcode:

1. Open `Wobitech Test.xcodeproj`.
2. Run scheme `Wobitech Test` on iOS Simulator.
3. Run tests with `Product > Test`.

CLI (example):

```sh
xcodebuild test -scheme "Wobitech Test" -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Future Improvements
For production readiness, I would add:

- real backend integration (replace mocked service)
- offline caching and sync strategy
- stronger error categorization and recovery UX
- CI with pull request test checks
- performance instrumentation
- accessibility pass (VoiceOver labels, dynamic type, contrast audits)
- feature flags for controlled rollout

Thought exercise (no code implemented):

- Real-time driver tracking would be added via a map module behind an abstraction boundary (protocol-based map adapter).
- The map SDK integration would be isolated in infrastructure/presentation adapter layers so business logic and state remain testable without the SDK runtime.

## Tooling
SwiftFormat and SwiftLint are configured.

```sh
brew install swiftformat swiftlint
swiftformat .
swiftlint --fix
swiftlint
```
