# COORBAssessment

## Overview
COORBAssessment is an iOS app designed to allow users to explore countries and their details, including their name, capital, currency, and flag. The app features a search bar for adding countries, supports location-based default country selection, and integrates persistent storage for offline support.

### This project includes:
- **CountryListView**: A list of countries that users can manage (add, remove, view details).
- **CountryDetailView**: A detailed view of a selected country.
- **Offline Support**: Disk-cached country list with stale-while-revalidate so cold starts feel instant.
- **Location-Based Default Country**: Adds a default country based on the user's location or a fallback country (Egypt).

## Features
- **Search Functionality**: Users can search for countries and add them to the main list. The search trims whitespace and is case-insensitive.
- **Swipe to Delete**: Users can swipe to remove a country from the list.
- **Five-Country Cap**: The list is capped at five entries; trying to add a sixth shows an alert instead of silently dropping the oldest.
- **Location Integration**: Automatically adds the first country based on the user's GPS location.
- **Offline Support**: Disk cache for the master country list (24h TTL with stale-while-revalidate) and persistent storage for the user's saved countries.
- **Detail View**: Displays the country's name, capital, currency, and flag, with a graceful placeholder for countries without a flag image.

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/mwefky/COORB.git
   ```
2. Open the project in Xcode:
   ```bash
   open COORBAssessment.xcodeproj
   ```
3. Ensure your system has the necessary configurations:
   - Xcode 15+
   - iOS 16+
4. Run the project:
   - Select a simulator or device and press Cmd + R.

The Xcode project is generated from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen). To regenerate it after structural changes:
```bash
brew install xcodegen
xcodegen generate
```

## How to Run Tests

### Unit Tests
Unit tests are written using XCTest. From Xcode press Cmd + U, or from the command line:
```bash
xcodebuild test \
  -project COORBAssessment.xcodeproj \
  -scheme COORBAssessment \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Unit tests cover:
- Networking, decoding, and DTO mapping.
- Disk cache (save, load, corruption, TTL freshness).
- Persistence of the user's saved list.
- Country list policy (limit and duplicate rules).
- Use cases (load, add, remove, get saved, resolve default).
- Location provider authorisation states and geocoding.
- View model behaviours (loading, search, add/remove, default resolution).

### UI Tests
UI tests live in `COORBAssessmentUITests` and exercise the real app against the live API.
- Searching for a country and adding it to the list.
- Swipe-to-delete from the saved list.
- Navigating to the detail view and verifying the capital is shown.

UI tests pass `--reset` as a launch argument to clear the saved list before each test.

### Snapshot Tests
Visual regression coverage uses [`swift-snapshot-testing`](https://github.com/pointfreeco/swift-snapshot-testing). Reference images live under `COORBAssessmentTests/Snapshots/__Snapshots__/`. Snapshots were recorded on iPhone 16 simulator (iOS 18.4); running on a different simulator may produce diffs.

## Architecture
The project follows MVVM with a Clean Architecture-leaning layering. Each layer is protocol-backed and dependency-injected for testability.

```
COORBAssessment/
├── Network/         APIClient, endpoints, error type
├── Models/          Country (domain), CountryDTO, CountryMapper
├── Storage/         CountriesCache (disk + TTL), LocalStore (UserDefaults)
├── Repositories/    CountriesRepository (combines network + cache)
├── Location/        LocationProvider, Geocoding, DefaultCountryResolver
├── Policies/        CountryListPolicy (limit + duplicate rules)
├── UseCases/        Single-action layer between view models and the data layer
├── DesignSystem/    Theme + reusable view modifiers
├── Coordinator/     AppCoordinator wires up the dependency graph
├── Features/
│   ├── CountryList/   View, ViewModel, search field, row
│   └── CountryDetail/ View, ViewModel
├── Extensions/
└── Resources/
```

## Key Components
- **APIClient**: Generic async/await REST client with typed errors and a protocol seam for testing.
- **CountriesRepository**: API-first with stale-while-revalidate disk cache (24h TTL); falls back to stale cache on network failure.
- **LocalStore**: Persists the user's saved countries via `UserDefaults`. Pure storage — no business rules.
- **CountryListPolicy**: Enforces the five-country cap and prevents duplicates.
- **LocationProvider**: `CoreLocation` wrapper that publishes the country name once geocoded.
- **DefaultCountryResolver**: Picks a default country from the available list based on location, with Egypt as the fallback.
- **Use Cases**: `LoadCountriesUseCase`, `AddCountryUseCase`, `RemoveCountryUseCase`, `GetSavedCountriesUseCase`, `ResolveDefaultCountryUseCase` — view models talk to these instead of touching repositories or storage directly.
- **Theme + ViewModifiers**: Centralised colors, spacing, radii, shadows, and reusable `cardStyle()` / `infoCardStyle()` / `screenBackground()` modifiers.
- **CountryListViewModel** / **CountryDetailViewModel**: Thin orchestrators bound to the views via Combine.
- **AppCoordinator**: Owns the dependency graph and produces the root view.

## Future Enhancements
- ~~**Integrate Facebook SnapshotKit for UI Tests**: Use SnapshotKit to take screenshots during UI tests for visual regression testing.~~
- **Support for Advanced UI Testing**: Expand UI tests to cover edge cases, such as large country lists or poor network conditions.
- **Localization**: Add support for multiple languages to make the app more accessible.
- **Background Sync**: Refresh the cache periodically while the app is foregrounded.
- **Analytics**: Integrate analytics tools (e.g., Firebase) to track user behavior.
- **Accessibility Improvements**: Ensure all UI elements support VoiceOver and dynamic text sizes.
