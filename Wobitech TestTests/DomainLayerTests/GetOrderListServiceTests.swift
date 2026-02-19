//
//  GetOrderListServiceTests.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation
import Testing
@testable import Wobitech_Test

@Suite(.serialized)
struct GetOrderListServiceTests {
  @Test
  func getOrderListReturnsDummyOrdersWhenShouldSucceedIsTrue() async throws {
    let service = GetOrderListService(shouldSucceed: true)

    let list = try await service.getOrderList(for: "Chirag")

    #expect(list.orders.count == 3)
    #expect(list.orders[0].id == "1")
    #expect(list.orders[0].status == .PENDING)
    #expect(list.orders[0].name == "Chirag - Order #1001")
    #expect(list.orders[1].status == .INTRANSIT)
    #expect(list.orders[2].status == .DELIVERED)
  }

  @Test
  func getOrderListThrowsNetworkErrorWhenShouldSucceedIsFalse() async {
    let service = GetOrderListService(shouldSucceed: false, delay: 0)

    do {
      _ = try await service.getOrderList(for: "Chirag")
      Issue.record("Expected NetworkError.requestFailed(500)")
    } catch let error as NetworkError {
      guard case let .requestFailed(statusCode) = error else {
        Issue.record("Expected NetworkError.requestFailed(500), got \(error)")
        return
      }
      #expect(statusCode == 500)
    } catch {
      Issue.record("Expected NetworkError.requestFailed(500), got \(error)")
    }
  }
}
