////
//  GetOrderDetailService.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation

protocol GetOrderDetailUseCase: AnyObject {
  func getOrderDetail(for orderID: String) async throws -> OrderDetail
  func streamOrderDetail(
    for orderID: String,
    pollingInterval: TimeInterval
  ) async -> AsyncThrowingStream<OrderDetail, Error>
}

actor GetOrderDetailService: GetOrderDetailUseCase {
  static let sharedInstance = GetOrderDetailService()
  private let networkService: NetworkServiceProtocol
  private let orderListService: GetOrderListService

  init(
    networkService: NetworkServiceProtocol = NetworkService(),
    orderListService: GetOrderListService = .sharedInstance
  ) {
    self.networkService = networkService
    self.orderListService = orderListService
  }

  func getOrderDetail(for orderID: String) async throws -> OrderDetail {
    let request = OrderDetailRequest(orderID: orderID)

    do {
      return try await networkService.execute(request)
    } catch {
      guard let order = await orderListService.getCachedOrder(by: orderID) else {
        throw error
      }

      return mapCachedOrderToDetail(order)
    }
  }

  func streamOrderDetail(
    for orderID: String,
    pollingInterval: TimeInterval = 10
  ) async -> AsyncThrowingStream<OrderDetail, Error> {
    AsyncThrowingStream { continuation in
      let task = Task {
        let request = OrderDetailRequest(orderID: orderID)
        let sanitizedInterval = max(pollingInterval, 0.01)

        while !Task.isCancelled {
          do {
            let latestDetail: OrderDetail = try await networkService.execute(request)
            continuation.yield(latestDetail)
          } catch {
            // Keep polling and skip transient failures.
          }

          do {
            try await Task.sleep(for: .seconds(sanitizedInterval))
          } catch {
            break
          }
        }

        continuation.finish()
      }

      continuation.onTermination = { _ in
        task.cancel()
      }
    }
  }

  private func mapCachedOrderToDetail(_ order: Order) -> OrderDetail {
    OrderDetail(
      id: order.id,
      status: order.status,
      name: order.name,
      fromName: "Warehouse Team",
      finalDeliveryName: order.name,
      fromAddress: "San Jose Fulfillment Center",
      finalAddress: "Customer Address for Order #\(order.id)",
      startDate: order.startDate,
      estimatedDeliveryDate: order.estimatedDeliveryDate,
      deliveryDate: order.deliveryDate,
      lastLocation: "",
      driverName: "",
      deliveryPhoto: nil
    )
  }
}
