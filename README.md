# Sitchomatic

An iOS application built with Swift and SwiftUI, designed for automated site login testing and credential verification with advanced proxy management, VPN integration, and human-emulation capabilities.

## Requirements

- **Xcode:** 16.0+
- **Swift:** 6.2+ toolchain (project currently uses Swift 5 language mode with `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- **iOS Deployment Target:** 18.0
- **macOS:** Ventura 13.5+ (for Xcode 16)

## Project Structure

```
ios/
├── Sitchomatic/                    # Main app target
│   ├── SitchomaticApp.swift        # @main entry point
│   ├── ContentView.swift           # Root view with navigation
│   ├── Sitchomatic.entitlements    # App Groups entitlements
│   ├── Assets.xcassets/            # App icon, accent color, background images
│   ├── Models/                     # 45 data models & type definitions
│   ├── Services/                   # 170+ service files (core business logic)
│   │   ├── Patterns/               # Pattern-matching utilities
│   │   └── WireProxy/              # Custom WireGuard proxy implementation
│   │       ├── Crypto/             # Cryptographic operations
│   │       ├── Handshake/          # WireGuard handshake protocol
│   │       ├── TCPStack/           # TCP/IP stack
│   │       └── Transport/          # Network transport layer
│   ├── Utilities/                  # 14 utility/helper files
│   ├── ViewModels/                 # 16 view models (MVVM)
│   └── Views/                      # 93 SwiftUI views
├── SitchomaticWidget/              # Widget extension target
│   ├── SitchomaticWidgetBundle.swift
│   ├── SitchomaticWidget.swift
│   ├── CommandCenterActivityAttributes.swift
│   ├── CommandCenterLiveActivity.swift
│   └── Info.plist
├── SitchomaticTests/               # Unit test target
├── SitchomaticUITests/             # UI test target
├── Sitchomatic.xcodeproj/          # Xcode project
└── SplitScreenBG.imageset/         # Split-screen background asset
```

## Architecture

### Design Patterns

- **MVVM** — Views, ViewModels, and Models are cleanly separated
- **Singleton Services** — Core services use `@MainActor class` with `static let shared`
- **Actor Isolation** — 170+ `@MainActor` annotations, 10+ custom `actor` declarations
- **Modern Concurrency** — 341+ `async` functions with structured `Task` usage throughout

### Key Services

| Service | Purpose |
|---------|---------|
| `DualSiteWorkerService` | Orchestrates parallel login testing across Joe and Ignition sites |
| `LoginAutomationEngine` | Drives login form interaction via WebKit |
| `HardwareTypingEngine` | Human-like typing with Gaussian timing delays (Box-Muller distribution) |
| `CoordinateInteractionEngine` | Coordinate-based click/tap emulation with jitter |
| `OnDeviceAIService` | On-device AI analysis via Grok API + Apple FoundationModels (iOS 26.0+) |
| `ProxyRotationService` | Proxy rotation, health checks, and failover |
| `VPNProtocolTestService` | VPN connection testing and diagnostics |
| `LoginURLRotationService` | URL pool management with rotation strategies |
| `GrokKeychain` | Secure Keychain storage for API keys |
| `DebugLogger` | Structured logging with categories, levels, and network error classification |

### Widget Extension

The `SitchomaticWidget` target provides:

- **Static Widget** — Displays time-based information (`.systemSmall`, `.systemMedium`, `.systemLarge`)
- **Command Center Live Activity** — Real-time progress tracking with Dynamic Island support showing:
  - Completed/total count, working/failed counts
  - Elapsed time, success rate
  - Site-specific theming (Joe/Ignition/PPSR/Double)
  - Lock screen banner, compact, expanded, and minimal presentations

## Frameworks & Dependencies

### Apple Frameworks

| Framework | Usage |
|-----------|-------|
| SwiftUI | Primary UI framework |
| UIKit | WebView hosting, image processing |
| WebKit | WKWebView for site automation |
| Combine | Reactive data flow |
| Vision | OCR and image analysis |
| Security | Keychain API key storage |
| CryptoKit | Cryptographic operations |
| ActivityKit | Live Activities & Dynamic Island |
| Network | NWConnection, NWEndpoint |
| NetworkExtension | VPN/tunnel APIs |
| BackgroundTasks | Background processing |
| AppIntents | Siri/Shortcuts integration |
| FoundationModels | On-device AI (runtime-gated to iOS 26.0+) |
| Observation | Observable macro (iOS 17+) |

### Third-Party Dependencies (SPM)

| Package | Purpose |
|---------|---------|
| [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) | ZIP file handling |

## Concurrency & Swift 6 Readiness

The codebase uses modern Swift concurrency throughout:

- **Actor isolation:** `@MainActor` on all UI-touching classes, custom `actor` types for thread-safe state
- **Async/await:** 341+ async functions, zero callback-based async patterns
- **Sendable:** 100+ `nonisolated Sendable` structs, 8 justified `@unchecked Sendable` usages
- **@preconcurrency imports:** Used for bridging non-Sendable frameworks (`WebKit`, `Network`, etc.)
- **Task.sleep:** All delayed operations use `Task.sleep(for:)` — zero legacy `DispatchQueue.asyncAfter` calls
- **`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`** is set on the main app and widget targets

## Building

### Xcode

1. Open `ios/Sitchomatic.xcodeproj` in Xcode 16+
2. Select the **Sitchomatic** scheme
3. Choose a simulator or device (iOS 18.0+)
4. Build with ⌘B

### Command Line

```bash
cd ios
xcodebuild -project Sitchomatic.xcodeproj \
  -scheme Sitchomatic \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  build
```

### Rork

This project is configured for [Rork](https://rork.com) compilation via `rork.json`:

```json
{
  "$schema": "https://rork.com/schema/rork.json",
  "apps": [
    {
      "name": "Sitchomatic",
      "path": "ios",
      "framework": "swift"
    }
  ]
}
```

## Configuration

### App Groups

The app uses App Groups for data sharing between the main app and widget extension:
- `group.app.rork.ve5l1conjgc135kle8kuj`

### API Keys

API keys (e.g., Grok/xAI) are stored securely in the iOS Keychain via `GrokKeychain.swift`. No keys are hardcoded in source.

## Code Quality

| Metric | Value |
|--------|-------|
| Swift files | 350 |
| Lines of code | 114,601 |
| Syntax errors | 0 |
| TODO/FIXME markers | 0 |
| Merge conflict markers | 0 |
| `@MainActor` annotations | 170+ |
| Custom actors | 10+ |
| Async functions | 341+ |
| Legacy DispatchQueue.asyncAfter | 0 (all modernized) |

## License

Private repository. All rights reserved.
