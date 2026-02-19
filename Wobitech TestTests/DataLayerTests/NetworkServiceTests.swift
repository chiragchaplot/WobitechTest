//
//  NetworkServiceTests.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation
import Testing
@testable import Wobitech_Test

@Suite(.serialized)
struct NetworkServiceTests {
  @Test
  func executeDecodesSuccessfulResponse() async throws {
    let payload = """
    {
      "value": "ok"
    }
    """.data(using: .utf8)!

    let service = makeService { request in
      #expect(request.url?.absoluteString == "https://api.wobitech.com.au/api/v1/orders?user=chirag")
      #expect(request.httpMethod == "GET")
      #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

      let response = try HTTPURLResponse(
        url: #require(request.url),
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      return (.http(response), payload)
    }

    let response: MockResponse = try await service.execute(MockAPIRequest(path: "orders", parameters: ["user": "chirag"]))
    #expect(response.value == "ok")
  }

  @Test
  func executeThrowsInvalidURLWhenRequestCannotBeBuilt() async {
    let service = makeService { _ in
      Issue.record("Network should not be called when request URL is invalid")
      let response = HTTPURLResponse(url: URL(string: "https://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
      return (.http(response), Data())
    }

    do {
      let _: MockResponse = try await service.execute(InvalidAPIRequest())
      Issue.record("Expected NetworkError.invalidURL")
    } catch let error as NetworkError {
      guard case .invalidURL = error else {
        Issue.record("Expected NetworkError.invalidURL, got \(error)")
        return
      }
    } catch {
      Issue.record("Expected NetworkError.invalidURL, got \(error)")
    }
  }

  @Test
  func executeThrowsRequestFailedForNon2xxStatus() async {
    let service = makeService { request in
      let response = HTTPURLResponse(
        url: request.url ?? URL(string: "https://api.wobitech.com.au")!,
        statusCode: 500,
        httpVersion: nil,
        headerFields: nil
      )!
      return (.http(response), Data("{}".utf8))
    }

    do {
      let _: MockResponse = try await service.execute(MockAPIRequest(path: "orders"))
      Issue.record("Expected NetworkError.requestFailed(500)")
    } catch let error as NetworkError {
      guard case let .requestFailed(statusCode) = error else {
        Issue.record("Expected NetworkError.requestFailed(500), got \(error)")
        return
      }
      #expect(statusCode == 500)
    } catch {
      Issue.record("Expected NetworkError.requestFailed(500), got \(error)")
    }
  }

  @Test
  func executeThrowsUnknownForNonHTTPResponse() async {
    let service = makeService { request in
      let response = URLResponse(
        url: request.url ?? URL(string: "https://api.wobitech.com.au")!,
        mimeType: "application/json",
        expectedContentLength: 0,
        textEncodingName: nil
      )
      return (.plain(response), Data())
    }

    do {
      let _: MockResponse = try await service.execute(MockAPIRequest(path: "orders"))
      Issue.record("Expected NetworkError.unknown")
    } catch let error as NetworkError {
      guard case .unknown = error else {
        Issue.record("Expected NetworkError.unknown, got \(error)")
        return
      }
    } catch {
      Issue.record("Expected NetworkError.unknown, got \(error)")
    }
  }

  @Test
  func executeThrowsDecodingErrorForInvalidPayload() async {
    let service = makeService { request in
      let response = HTTPURLResponse(
        url: request.url ?? URL(string: "https://api.wobitech.com.au")!,
        statusCode: 200,
        httpVersion: nil,
        headerFields: nil
      )!
      return (.http(response), Data("{\"unexpected\": 1}".utf8))
    }

    do {
      let _: MockResponse = try await service.execute(MockAPIRequest(path: "orders"))
      Issue.record("Expected NetworkError.decodingError")
    } catch let error as NetworkError {
      guard case .decodingError = error else {
        Issue.record("Expected NetworkError.decodingError, got \(error)")
        return
      }
    } catch {
      Issue.record("Expected NetworkError.decodingError, got \(error)")
    }
  }
}

private extension NetworkServiceTests {
  func makeService(
    _ handler: @escaping @Sendable (URLRequest) throws -> (MockURLProtocol.Response, Data)
  ) -> NetworkService {
    MockURLProtocol.requestHandler = handler
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [MockURLProtocol.self]
    return NetworkService(session: URLSession(configuration: configuration))
  }
}
