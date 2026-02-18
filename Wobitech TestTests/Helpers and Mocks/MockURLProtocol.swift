////
//  MockURLProtocol.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.
import Foundation

final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    enum Response {
        case http(HTTPURLResponse)
        case plain(URLResponse)
    }

    nonisolated(unsafe) static var requestHandler: (@Sendable (URLRequest) throws -> (Response, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "MockURLProtocol", code: 1))
            return
        }

        do {
            let (response, data) = try handler(request)
            switch response {
            case .http(let http):
                client?.urlProtocol(self, didReceive: http, cacheStoragePolicy: .notAllowed)
            case .plain(let plain):
                client?.urlProtocol(self, didReceive: plain, cacheStoragePolicy: .notAllowed)
            }
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
