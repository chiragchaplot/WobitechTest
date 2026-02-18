# Wobitech Test

## Architecture
This is a small SwiftUI app with a lightweight, presentation-first structure.

- App entry point: `Wobitech_TestApp` in `Wobitech Test/Wobitech_TestApp.swift`.
  - Creates the main `WindowGroup` and renders `ContentView`.
- Presentation layer: SwiftUI views in `Wobitech Test/Presentation Layer/`.
  - `ContentView` is the root view and the current UI composition point.

At this stage there are no explicit data, domain, or service layers. Those can be added later as the app grows.

## Formatting and Linting
This project runs SwiftFormat and SwiftLint automatically on every build:

- SwiftFormat: auto-formats code using `.swiftformat`.
- SwiftLint: auto-fixes lint violations using `.swiftlint.yml`.

If you do not have them installed, run:

```sh
brew install swiftformat swiftlint
```
