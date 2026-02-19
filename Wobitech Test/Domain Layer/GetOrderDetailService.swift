////
//  GetOrderDetailService.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation

protocol GetOrderDetailUseCase: AnyObject {
  func getOrderList(for user: String) async throws -> OrderList
}

actor GetOrderDetailService: GetOrderListUseCase {
  static let sharedInstance = GetOrderListService()

  func getOrderList(for _: String) async throws -> OrderList {
    OrderList(orders: [])
  }
}
