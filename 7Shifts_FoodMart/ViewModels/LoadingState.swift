import Foundation

/// Represents the current state of data loading.
enum LoadingState: Equatable {
    case idle       // Initial state, no action taken
    case loading    // Data is being fetched
    case success    // Data loaded successfully
    case error(String)  // Error occurred with message
}
