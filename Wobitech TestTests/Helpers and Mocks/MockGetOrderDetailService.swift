//
//  MockGetOrderDetailService.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.
//

import Foundation
@testable import Wobitech_Test

actor MockGetOrderDetailService: GetOrderDetailUseCase {
  enum Outcome {
    case success(OrderDetail)
    case failure(Error)
  }

  private let getDetailOutcome: Outcome
  private let streamValues: [OrderDetail]
  private let streamDelaySeconds: TimeInterval

  private(set) var requestedOrderIDs: [String] = []
  private(set) var streamRequestedOrderIDs: [String] = []
  private(set) var streamCallCount = 0

  init(
    getDetailOutcome: Outcome,
    streamValues: [OrderDetail] = [],
    streamDelaySeconds: TimeInterval = 0
  ) {
    self.getDetailOutcome = getDetailOutcome
    self.streamValues = streamValues
    self.streamDelaySeconds = streamDelaySeconds
  }

  func getOrderDetail(for orderID: String) async throws -> OrderDetail {
    requestedOrderIDs.append(orderID)

    switch getDetailOutcome {
    case let .success(orderDetail):
      return orderDetail
    case let .failure(error):
      throw error
    }
  }

  func streamOrderDetail(
    for orderID: String,
    pollingInterval _: TimeInterval
  ) async -> AsyncThrowingStream<OrderDetail, Error> {
    streamCallCount += 1
    streamRequestedOrderIDs.append(orderID)

    return AsyncThrowingStream { continuation in
      let task = Task {
        for detail in streamValues {
          if streamDelaySeconds > 0 {
            try? await Task.sleep(for: .seconds(streamDelaySeconds))
          }
          continuation.yield(detail)
        }
        continuation.finish()
      }

      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }
}
