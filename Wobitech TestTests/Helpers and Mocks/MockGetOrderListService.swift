//
//  MockGetOrderListService.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation
@testable import Wobitech_Test

actor MockGetOrderListService: GetOrderListUseCase {
  enum Outcome {
    case success(OrderList)
    case failure(NetworkError)
  }

  private var outcomes: [Outcome]
  private let delay: Double
  private(set) var callCount = 0
  private(set) var requestedUsers: [String] = []

  init(
    outcomes: [Outcome] = [],
    delay: Double = 0
  ) {
    self.outcomes = outcomes
    self.delay = delay
  }

  func getOrderList(for user: String) async throws -> OrderList {
    requestedUsers.append(user)
    callCount += 1

    if delay > 0 {
      try? await Task.sleep(for: .seconds(delay))
    }

    let outcome = outcomes.isEmpty ? .success(Self.defaultOrderList(for: user, callCount: callCount)) : outcomes.removeFirst()
    switch outcome {
    case let .success(orderList):
      return orderList
    case let .failure(error):
      throw error
    }
  }

  private static func defaultOrderList(for user: String, callCount: Int) -> OrderList {
    OrderList(
      orders: [
        Order(
          id: "mock-\(callCount)",
          status: .PENDING,
          name: "\(user) - Mock Order",
          startDate: .now,
          estimatedDeliveryDate: nil,
          deliveryDate: nil
        )
      ]
    )
  }
}
