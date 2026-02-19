//
//  GetOrderDetailServiceTests.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.
//

import Foundation
import Testing
@testable import Wobitech_Test

@Suite(.serialized)
struct GetOrderDetailServiceTests {
  @Test
  func getOrderDetailReturnsDecodedDetailWhenNetworkSucceeds() async throws {
    let detail = makeOrderDetail(id: "1", status: .INTRANSIT)
    let networkService = MockNetworkService(executeResults: [.success(detail)])
    let service = GetOrderDetailService(
      networkService: networkService,
      orderListService: GetOrderListService(shouldSucceed: true)
    )

    let response = try await service.getOrderDetail(for: "1")

    #expect(response.id == "1")
    #expect(response.status == .INTRANSIT)
    #expect(response.name == "Order #1001")

    let requestedPaths = await networkService.requestedPaths
    #expect(requestedPaths == ["orders/1"])
  }

  @Test
  func streamOrderDetailContinuesPollingWhenFirstRequestFails() async {
    let networkService = MockNetworkService(
      executeResults: [
        .failure(NetworkError.requestFailed(500)),
        .success(makeOrderDetail(id: "1", status: .PENDING))
      ]
    )
    let service = GetOrderDetailService(
      networkService: networkService,
      orderListService: GetOrderListService(shouldSucceed: true)
    )

    let stream = await service.streamOrderDetail(for: "1", pollingInterval: 0.01)
    let firstDetail = await firstStreamValue(from: stream, timeoutSeconds: 1)

    #expect(firstDetail != nil)
    #expect(firstDetail?.id == "1")
    let executeCount = await networkService.executeCallCount
    #expect(executeCount >= 2)
  }
}

private extension GetOrderDetailServiceTests {
  func makeOrderDetail(id: String, status: OrderStatus) -> OrderDetail {
    OrderDetail(
      id: id,
      status: status,
      name: "Order #1001",
      fromName: "Warehouse Team",
      finalDeliveryName: "Chirag",
      fromAddress: "Sydney",
      finalAddress: "Melbourne",
      startDate: .now,
      estimatedDeliveryDate: .now.addingTimeInterval(86400),
      deliveryDate: nil,
      lastLocation: "Hub",
      driverName: "Alex",
      deliveryPhoto: nil
    )
  }

  func firstStreamValue(
    from stream: AsyncThrowingStream<OrderDetail, Error>,
    timeoutSeconds: TimeInterval
  ) async -> OrderDetail? {
    await withTaskGroup(of: OrderDetail?.self) { group in
      group.addTask {
        do {
          var iterator = stream.makeAsyncIterator()
          return try await iterator.next()
        } catch {
          Issue.record("Expected non-failing stream, got error: \(error)")
          return nil
        }
      }

      group.addTask {
        try? await Task.sleep(for: .seconds(timeoutSeconds))
        return nil
      }

      let firstFinished = await group.next() ?? nil
      group.cancelAll()
      return firstFinished
    }
  }
}

private actor MockNetworkService: NetworkServiceProtocol {
  private var executeResults: [Result<OrderDetail, Error>]
  private(set) var executeCallCount = 0
  private(set) var requestedPaths: [String] = []

  init(executeResults: [Result<OrderDetail, Error>]) {
    self.executeResults = executeResults
  }

  func execute<T: Decodable>(_ request: APIRequest) async throws -> T {
    requestedPaths.append(request.path)
    executeCallCount += 1

    let next = executeResults.isEmpty ? .failure(NetworkError.unknown) : executeResults.removeFirst()
    switch next {
    case let .success(detail):
      guard let typed = detail as? T else {
        throw NetworkError.decodingError
      }
      return typed
    case let .failure(error):
      throw error
    }
  }

  func stream<T: Decodable>(
    _ request: APIRequest,
    pollingInterval _: TimeInterval
  ) async -> AsyncThrowingStream<T, Error> {
    // Not used by GetOrderDetailService (it uses execute in its polling loop).
    requestedPaths.append(request.path)
    return AsyncThrowingStream { continuation in
      continuation.finish()
    }
  }
}
