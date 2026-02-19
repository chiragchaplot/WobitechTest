//
//  OrderDetailRequest.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.
import Foundation

struct OrderDetailRequest: APIRequest {
  let orderID: String

  var path: String {
    "orders/\(orderID)"
  }
}
