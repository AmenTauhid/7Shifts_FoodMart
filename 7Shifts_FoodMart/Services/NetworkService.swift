import Foundation

// MARK: - Protocol

/// Protocol for network operations, enabling dependency injection for testing.
protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from urlString: String) async throws -> T
}

// MARK: - Implementation

/// Handles all network requests using URLSession.
/// Uses async/await for modern Swift concurrency.
final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Fetches and decodes JSON data from a URL.
    /// - Parameter urlString: The URL to fetch from
    /// - Returns: Decoded object of type T
    /// - Throws: `NetworkError` for various failure cases
    func fetch<T: Decodable>(from urlString: String) async throws -> T {
        // 1. Validate URL
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        // 2. Create request with cache disabled for fresh data
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData

        // 3. Perform network request
        let data: Data
        do {
            let (responseData, _) = try await session.data(for: request)
            data = responseData
        } catch {
            throw NetworkError.requestFailed(error)
        }

        // 4. Validate response data
        guard !data.isEmpty else {
            throw NetworkError.noData
        }

        // 5. Decode JSON to model
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
