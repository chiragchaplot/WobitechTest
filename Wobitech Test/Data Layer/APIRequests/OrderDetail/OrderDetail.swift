//
//  OrderDetail.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation

struct OrderDetail: Decodable {
  var id: String
  var status: OrderStatus
  var name: String
  var fromName: String
  var finalDeliveryName: String
  var fromAddress: String
  var finalAddress: String
  var startDate: Date
  var estimatedDeliveryDate: Date?
  var deliveryDate: Date?
  var lastLocation: String
  var driverName: String
  var deliveryPhoto: Data?
}
