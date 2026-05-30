# Conservatio iOS App

Native iOS app built with SwiftUI, consuming the KMP shared module.

## Setup

1. Install Xcode 15.4 or later
2. Run `./gradlew :shared:assembleXCFramework` from the project root to build the shared framework
3. Open this directory in Xcode: File > Open > select `iosApp/`
4. Create a new Xcode project in this directory (SwiftUI App, target iOS 17+)
5. Add the generated XCFramework from `shared/build/XCFrameworks/` to your project
6. Build and run on simulator or device

## Architecture

- SwiftUI views with MVVM pattern
- KMP shared module provides domain models, repositories, and API client
- Native camera and image annotation using platform APIs
- Core Data or shared SQLDelight for local persistence

## Design

The app follows Apple Human Interface Guidelines with a custom warm heritage color palette:
- Primary: Terracotta (#C25B3A)
- Secondary: Stone Blue (#3A6B8C)
- Tertiary: Warm Gold (#D4A843)

See `Theme/` for color and typography definitions.
