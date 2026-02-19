////
//  OrderList.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.
import Foundation

struct OrderList {
  var orders: [Order]
}

struct Order: Identifiable {
  var id: String
  var status: OrderStatus
  var name: String
  var startDate: Date
  var estimatedDeliveryDate: Date?
  var deliveryDate: Date?

  static let mockOrders: [Order] = {
    let statuses: [OrderStatus] = [.PENDING, .INTRANSIT, .DELIVERED]
    let user = "Chirag" // Defaulting for mock data

    return (1 ... 15).map { i in
      let randomStatus = statuses.randomElement() ?? .PENDING
      return Order(
        id: "\(i)",
        status: randomStatus,
        name: "\(user) - Order #\(1000 + i)",
        startDate: .now.addingTimeInterval(Double(-86400 * i)),
        estimatedDeliveryDate: randomStatus == .DELIVERED ? nil : .now.addingTimeInterval(Double(86400 * i)),
        deliveryDate: randomStatus == .DELIVERED ? .now.addingTimeInterval(Double(-3600 * i)) : nil
      )
    }
  }()
}

enum OrderStatus: String, Equatable {
  case PENDING
  case INTRANSIT
  case DELIVERED
}
