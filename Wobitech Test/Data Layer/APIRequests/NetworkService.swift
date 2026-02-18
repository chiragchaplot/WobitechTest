//
//  NetworkService.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Int)
    case decodingError
    case unknown
}

protocol NetworkServiceProtocol {
    func execute<T: Decodable>(_ request: APIRequest) async throws -> T
}

actor NetworkService: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func execute<T: Decodable>(_ request: APIRequest) async throws -> T {
        // The request now handles its own URL construction logic
        guard let urlRequest = request.asURLRequest() else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.requestFailed(httpResponse.statusCode)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
