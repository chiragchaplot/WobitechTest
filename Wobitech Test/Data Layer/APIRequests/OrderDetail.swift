//
//  OrderDetail.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation

struct OrderDetail {
  var id: String
  var status: OrderStatus
  var name: String
  var startDate: Date
  var estimatedDeliveryDate: Date?
  var deliveryDate: Date?
  var lastLocation: String
  var driverName: String
  var deliveryPhoto: Data?
}

