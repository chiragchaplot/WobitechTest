//
//  OrderListDecodingTests.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.
//

import Foundation
import Testing
@testable import Wobitech_Test

@Suite("Order List Decoding")
struct OrderListDecodingTests {
  @Test
  func orderListDecodesAllFieldsCorrectly() throws {
    let firstStartDate = try isoDate("2026-02-19T10:30:00Z")
    let firstEstimatedDeliveryDate = try isoDate("2026-02-20T11:45:00Z")
    let secondStartDate = try isoDate("2026-02-18T09:00:00Z")
    let secondDeliveryDate = try isoDate("2026-02-18T14:15:00Z")

    let json = """
    {
      "orders": [
        {
          "id": "order-1",
          "status": "PENDING",
          "name": "Order Alpha",
          "startDate": "2026-02-19T10:30:00Z",
          "estimatedDeliveryDate": "2026-02-20T11:45:00Z",
          "deliveryDate": null
        },
        {
          "id": "order-2",
          "status": "DELIVERED",
          "name": "Order Beta",
          "startDate": "2026-02-18T09:00:00Z",
          "estimatedDeliveryDate": null,
          "deliveryDate": "2026-02-18T14:15:00Z"
        }
      ]
    }
    """

    let decoded: OrderList = try decode(json, as: OrderList.self)
    #expect(decoded.orders.count == 2)

    let first = try #require(decoded.orders.first)
    #expect(first.id == "order-1")
    #expect(first.status == .PENDING)
    #expect(first.name == "Order Alpha")
    #expect(first.startDate == firstStartDate)
    #expect(first.estimatedDeliveryDate == firstEstimatedDeliveryDate)
    #expect(first.deliveryDate == nil)

    let second = decoded.orders[1]
    #expect(second.id == "order-2")
    #expect(second.status == .DELIVERED)
    #expect(second.name == "Order Beta")
    #expect(second.startDate == secondStartDate)
    #expect(second.estimatedDeliveryDate == nil)
    #expect(second.deliveryDate == secondDeliveryDate)
  }
}

private extension OrderListDecodingTests {
  func decode<T: Decodable>(_ json: String, as type: T.Type) throws -> T {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try decoder.decode(type, from: Data(json.utf8))
  }

  func isoDate(_ value: String) throws -> Date {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return try #require(formatter.date(from: value))
  }
}
