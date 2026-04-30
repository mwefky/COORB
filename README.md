# COORB

iOS coding assessment - a small countries explorer.
Search for a country, view its capital and currency, and pin up to 5 favorites.
The first country is added based on your GPS, with a fallback when permission is denied.

## Requirements

- Xcode 15 or later
- iOS 16+
- Swift 5.9+

## Getting started

```bash
open COORBAssessment.xcodeproj
```

The project file is generated from `project.yml` using [XcodeGen](https://github.com/yonaskolb/XcodeGen).
If you make structural changes you can regenerate it:

```bash
brew install xcodegen
xcodegen generate
```

## Running tests

`Cmd + U` in Xcode, or from the command line:

```bash
xcodebuild test \
  -project COORBAssessment.xcodeproj \
  -scheme COORBAssessment \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Project layout

```
COORBAssessment/
├── Network/        REST client + endpoint + error types
└── ...             (more layers added per feature)
COORBAssessmentTests/
```

More notes will land here as features come in.
