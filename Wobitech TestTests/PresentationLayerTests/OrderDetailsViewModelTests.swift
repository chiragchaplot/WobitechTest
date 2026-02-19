//
//  OrderDetailsViewModelTests.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.
//

import Foundation
import Testing
@testable import Wobitech_Test

@Suite(.serialized)
@MainActor
struct OrderDetailsViewModelTests {
  @Test
  func onAppearTransitionsToSuccessfulAndMapsDisplayModel() async {
    let detail = makeDetail(
      id: "1",
      status: .PENDING,
      name: "Order One",
      fromName: "Warehouse A",
      finalDeliveryName: "John",
      fromAddress: "Sydney",
      finalAddress: "Melbourne"
    )
    let service = MockGetOrderDetailService(
      getDetailOutcome: .success(detail)
    )
    let viewModel = OrderDetailsViewModel(orderID: "1", orderDetailService: service)

    #expect(viewModel.state == .noData)
    viewModel.onAppear()

    await waitForState(.successful, in: viewModel)

    #expect(viewModel.state == .successful)
    #expect(viewModel.displayModel.orderID == "1")
    #expect(viewModel.displayModel.orderName == "Order One")
    #expect(viewModel.displayModel.fromNameText == "Warehouse A")
    #expect(viewModel.displayModel.finalDeliveryNameText == "John")
    #expect(viewModel.displayModel.fromAddressText == "Sydney")
    #expect(viewModel.displayModel.finalAddressText == "Melbourne")
    #expect(viewModel.isOrderDelivered == false)

    let requestedIDs = await service.requestedOrderIDs
    #expect(requestedIDs == ["1"])
  }

  @Test
  func onAppearTransitionsToErrorWhenFetchFails() async {
    let service = MockGetOrderDetailService(
      getDetailOutcome: .failure(NetworkError.requestFailed(500))
    )
    let viewModel = OrderDetailsViewModel(orderID: "1", orderDetailService: service)

    viewModel.onAppear()
    await waitForState(.error, in: viewModel)

    #expect(viewModel.state == .error)
    #expect(viewModel.orderStatus == nil)
  }

  @Test
  func deliveredOrderDoesNotStartStreaming() async {
    let service = MockGetOrderDetailService(
      getDetailOutcome: .success(makeDetail(id: "1", status: .DELIVERED)),
      streamValues: [makeDetail(id: "1", status: .DELIVERED, name: "Should Not Stream")]
    )
    let viewModel = OrderDetailsViewModel(orderID: "1", orderDetailService: service)

    viewModel.onAppear()
    await waitForState(.successful, in: viewModel)
    try? await Task.sleep(for: .seconds(0.05))

    let streamCallCount = await service.streamCallCount
    #expect(streamCallCount == 0)
    #expect(viewModel.isOrderDelivered)
  }

  @Test
  func pendingOrderStartsStreamingAndAppliesLatestValue() async {
    let initial = makeDetail(id: "1", status: .PENDING, lastLocation: "Warehouse")
    let streamed = makeDetail(id: "1", status: .INTRANSIT, lastLocation: "On Route")
    let service = MockGetOrderDetailService(
      getDetailOutcome: .success(initial),
      streamValues: [streamed],
      streamDelaySeconds: 0.05
    )
    let viewModel = OrderDetailsViewModel(orderID: "1", orderDetailService: service)

    viewModel.onAppear()
    await waitForState(.successful, in: viewModel)
    await waitForLastLocation("On Route", in: viewModel)

    let streamCallCount = await service.streamCallCount
    #expect(streamCallCount == 1)
    #expect(viewModel.displayModel.lastLocationText == "On Route")
    #expect(viewModel.orderStatus == .INTRANSIT)
  }

  @Test
  func dismissErrorMovesStateBackToNoData() async {
    let service = MockGetOrderDetailService(
      getDetailOutcome: .failure(NetworkError.requestFailed(500))
    )
    let viewModel = OrderDetailsViewModel(orderID: "1", orderDetailService: service)

    viewModel.onAppear()
    await waitForState(.error, in: viewModel)
    #expect(viewModel.state == .error)

    viewModel.dismissError()
    #expect(viewModel.state == .noData)
  }
}

private extension OrderDetailsViewModelTests {
  /// View model work is asynchronous, so polling avoids race conditions in tests.
  func waitForState(
    _ expectedState: ScreenState,
    in viewModel: OrderDetailsViewModel,
    timeoutSeconds: TimeInterval = 1
  ) async {
    let start = Date()
    while viewModel.state != expectedState {
      if Date().timeIntervalSince(start) > timeoutSeconds {
        Issue.record("Timed out waiting for state: \(expectedState)")
        return
      }
      try? await Task.sleep(for: .milliseconds(20))
    }
  }

  func waitForLastLocation(
    _ expectedValue: String,
    in viewModel: OrderDetailsViewModel,
    timeoutSeconds: TimeInterval = 1
  ) async {
    let start = Date()
    while viewModel.displayModel.lastLocationText != expectedValue {
      if Date().timeIntervalSince(start) > timeoutSeconds {
        Issue.record("Timed out waiting for last location: \(expectedValue)")
        return
      }
      try? await Task.sleep(for: .milliseconds(20))
    }
  }

  func makeDetail(
    id: String,
    status: OrderStatus,
    name: String = "Mock Order",
    fromName: String = "Warehouse",
    finalDeliveryName: String = "Customer",
    fromAddress: String = "From Address",
    finalAddress: String = "Final Address",
    lastLocation: String = "N/A"
  ) -> OrderDetail {
    OrderDetail(
      id: id,
      status: status,
      name: name,
      fromName: fromName,
      finalDeliveryName: finalDeliveryName,
      fromAddress: fromAddress,
      finalAddress: finalAddress,
      startDate: .now,
      estimatedDeliveryDate: .now.addingTimeInterval(3600),
      deliveryDate: status == .DELIVERED ? .now : nil,
      lastLocation: lastLocation,
      driverName: "Driver A",
      deliveryPhoto: nil
    )
  }
}
