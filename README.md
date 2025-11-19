# FoodMart by Ayman Tauhid

A simple iOS grocery shopping app built with SwiftUI.

## Features

- Browse food items in a grid layout
- Filter items by category
- Pull to refresh
- Error handling with retry

## Architecture

The app follows **MVVM** (Model-View-ViewModel) pattern:

```
7Shifts_FoodMart/
├── Models/           # Data models (FoodItem, FoodCategory)
├── Views/            # SwiftUI views
│   └── Components/   # Reusable UI components
├── ViewModels/       # Business logic and state management
├── Services/         # Network layer
└── Repository/       # Data access layer
```

## Requirements

- iOS 16.0+
- Xcode 15.0+

## Setup

1. Clone the repository
2. Open `7Shifts_FoodMart.xcodeproj` in Xcode
3. Build and run on simulator or device

## API

The app fetches data from:
- Food items: `https://7shifts.github.io/mobile-takehome/api/food_items.json`
- Categories: `https://7shifts.github.io/mobile-takehome/api/food_item_categories.json`

## Testing

### Unit Tests
Run unit tests with `Cmd + U` or via Product > Test

Tests cover:
- Model JSON decoding
- Network service
- Repository layer
- ViewModel logic and filtering

### UI Tests
UI tests verify:
- App launch and navigation
- Filter sheet functionality
- Category toggling
- Pull to refresh

## Design Decisions

### Why MVVM?
- **Separation of concerns**: Views only handle UI, ViewModels handle logic
- **Testability**: ViewModels can be tested without UI
- **Maintainability**: Easy to locate and modify code

### Why Protocol-Oriented Design?
- **Dependency injection**: Pass mock implementations for testing
- **Loose coupling**: Components don't depend on concrete types
- **Example**: `NetworkServiceProtocol` allows `MockNetworkService` in tests

### Why Repository Pattern?
- **Abstraction**: ViewModel doesn't know about network details
- **Single source of truth**: All data access goes through repository
- **Flexibility**: Easy to add caching or local storage later
