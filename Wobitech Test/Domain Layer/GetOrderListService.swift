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
  private(set) var cachedOrderList: OrderList = .init(orders: [])

  init(
    shouldSucceed: Bool = true
  ) {
    self.shouldSucceed = shouldSucceed
  }

  func getOrderList(for _: String) async throws -> OrderList {
    try await Task.sleep(for: .seconds(3)) // Never add this. I am doing it just to simulate api call

    guard shouldSucceed else {
      throw NetworkError.requestFailed(500)
    }
    let fetchedList = OrderList(orders: Order.mockOrders)
    cachedOrderList = fetchedList
    return fetchedList
  }

  func getCachedOrder(by orderID: String) -> Order? {
    cachedOrderList.orders.first(where: { $0.id == orderID })
  }
}
