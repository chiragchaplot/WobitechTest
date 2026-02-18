////
//  GetOrderListService.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation

protocol GetOrderListUseCase: AnyObject {
    func getOrderList(for user: String) async throws -> OrderList
}

actor GetOrderListService: GetOrderListUseCase {
    static let sharedInstance = GetOrderListService()
    
    func getOrderList(for user: String) async throws -> OrderList {
        var orderList: OrderList = OrderList(orders: [])
        return orderList
    }
}
