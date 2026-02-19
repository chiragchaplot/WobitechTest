////
//  GetOrderDetailService.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation

protocol GetOrderDetailUseCase: AnyObject {
  func getOrderDetail(for orderID: String) async throws -> OrderDetail
}

actor GetOrderDetailService: GetOrderDetailUseCase {
  static let sharedInstance = GetOrderDetailService()
  private let orderListService: GetOrderListService

  init(orderListService: GetOrderListService = .sharedInstance) {
    self.orderListService = orderListService
  }

  func getOrderDetail(for orderID: String) async throws -> OrderDetail {
    guard let order = await orderListService.getCachedOrder(by: orderID) else {
      throw NetworkError.requestFailed(404)
    }

    return OrderDetail(
      id: order.id,
      status: order.status,
      name: order.name,
      startDate: order.startDate,
      estimatedDeliveryDate: order.estimatedDeliveryDate,
      deliveryDate: order.deliveryDate,
      lastLocation: "",
      driverName: "",
      deliveryPhoto: nil
    )
  }
}
