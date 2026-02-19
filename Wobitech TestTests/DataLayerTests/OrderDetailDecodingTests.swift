//
//  OrderDetailDecodingTests.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.
//

import Foundation
import Testing
@testable import Wobitech_Test

@Suite("Order Detail Decoding")
struct OrderDetailDecodingTests {
  @Test
  func orderDetailDecodesAllFieldsCorrectly() throws {
    let startDate = try isoDate("2026-02-17T08:20:00Z")
    let estimatedDeliveryDate = try isoDate("2026-02-19T12:00:00Z")

    // "ZGF0YQ==" is base64 for "data"
    let json = """
    {
      "id": "order-3",
      "status": "INTRANSIT",
      "name": "Order Gamma",
      "fromName": "Warehouse Team",
      "finalDeliveryName": "Chirag",
      "fromAddress": "Sydney",
      "finalAddress": "Melbourne",
      "startDate": "2026-02-17T08:20:00Z",
      "estimatedDeliveryDate": "2026-02-19T12:00:00Z",
      "deliveryDate": null,
      "lastLocation": "Distribution Hub",
      "driverName": "Alex",
      "deliveryPhoto": "ZGF0YQ=="
    }
    """

    let decoded: OrderDetail = try decode(json, as: OrderDetail.self)

    #expect(decoded.id == "order-3")
    #expect(decoded.status == .INTRANSIT)
    #expect(decoded.name == "Order Gamma")
    #expect(decoded.fromName == "Warehouse Team")
    #expect(decoded.finalDeliveryName == "Chirag")
    #expect(decoded.fromAddress == "Sydney")
    #expect(decoded.finalAddress == "Melbourne")
    #expect(decoded.startDate == startDate)
    #expect(decoded.estimatedDeliveryDate == estimatedDeliveryDate)
    #expect(decoded.deliveryDate == nil)
    #expect(decoded.lastLocation == "Distribution Hub")
    #expect(decoded.driverName == "Alex")
    #expect(decoded.deliveryPhoto == Data("data".utf8))
  }
}

private extension OrderDetailDecodingTests {
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
