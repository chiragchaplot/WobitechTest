////
//  APIRequest.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.


import Foundation

protocol APIRequest {
    
    var baseURL: String { get }
    
    /// The specific path for this request (e.g., "user/profile")
    var path: String { get }
    
    /// The HTTP method (defaulting to .get)
    var method: HTTPRequestMethod { get }
    
    /// The version of the API (defaulting to v1)
    var version: String { get }
    
    /// Optional query parameters for GET or body data for POST
    var parameters: [String: Any]? { get }
    var body: Encodable? { get }
    
    /// Custom headers specific to this one request
    var additionalHeaders: [String: String] { get }
    
    func asURLRequest() -> URLRequest?
}

// MARK: - Default Implementations
extension APIRequest {
    var baseURL: String { "api.wobitech.com.au" }
    var method: HTTPRequestMethod { .GET }
    var version: String { "v1" }
    var parameters: [String: Any]? { nil }
    var body: Encodable? { nil }
    var additionalHeaders: [String: String] { [:] }
    func asURLRequest() -> URLRequest? {
        // Construct the full URL string
        let urlString = "https://\(baseURL)/api/\(version)/\(path)"
        
        guard var components = URLComponents(string: urlString) else { return nil }
        
        // 1. Handle Query Parameters (for GET requests)
        if let parameters = parameters {
            components.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        guard let url = components.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // 2. Handle Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        additionalHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        // 3. Handle Body (for POST/PUT etc)
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        return request
    }
}

enum HTTPRequestMethod: String {
    case `GET`
    case `POST`
    case `PUT`
    case `DELETE`
    case `PATCH`
}
