////
//  GetOrderListService.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation

protocol GetOrderListUseCase: AnyObject {
  /// Retrieves orders pending for user
  func getOrderList(for user: String) async throws -> OrderList
}

actor GetOrderListService: GetOrderListUseCase {
  static let sharedInstance = GetOrderListService()
  var shouldSucceed: Bool

  init(
    shouldSucceed: Bool = true
  ) {
    self.shouldSucceed = shouldSucceed
  }

  func getOrderList(for user: String) async throws -> OrderList {
    try await Task.sleep(for: .seconds(3)) // Never add this. I am doing it just to simulate api call

    guard shouldSucceed else {
      throw NetworkError.requestFailed(500)
    }

    return OrderList(
      orders: [
        Order(
          id: "1",
          status: .PENDING,
          name: "\(user) - Order #1001",
          startDate: .now.addingTimeInterval(-86400),
          estimatedDeliveryDate: .now.addingTimeInterval(86400),
          deliveryDate: nil
        ),
        Order(
          id: "2",
          status: .INTRANSIT,
          name: "\(user) - Order #1002",
          startDate: .now.addingTimeInterval(-172_800),
          estimatedDeliveryDate: .now.addingTimeInterval(172_800),
          deliveryDate: nil
        ),
        Order(
          id: "3",
          status: .DELIVERED,
          name: "\(user) - Order #1003",
          startDate: .now.addingTimeInterval(-345_600),
          estimatedDeliveryDate: nil,
          deliveryDate: .now.addingTimeInterval(-43200)
        )
      ]
    )
  }
}
