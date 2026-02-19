////
//  OrderList.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.
import Foundation

struct OrderList {
  var orders: [Order]
}

struct Order {
  var status: OrderStatus
  var name: String
  var startDate: Date
  var estimatedDeliveryDate: Date?
  var deliveryDate: Date?
}

enum OrderStatus: String, Equatable {
  case PENDING
  case INTRANSIT
  case DELIVERED
}
