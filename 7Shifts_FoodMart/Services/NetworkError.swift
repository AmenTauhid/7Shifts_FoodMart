import Foundation

/// Custom error types for network operations to provide user-friendly error messages.
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case noData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL provided is invalid."
        case .requestFailed(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .noData:
            return "No data received from server."
        }
    }
}
