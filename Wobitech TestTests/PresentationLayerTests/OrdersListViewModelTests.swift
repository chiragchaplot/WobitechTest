//
//  OrdersListViewModelTests.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import Foundation
import Testing
@testable import Wobitech_Test

@Suite(.serialized)
@MainActor
struct OrdersListViewModelTests {
  @Test
  func onAppearTransitionsToSuccessfulStateOnServiceSuccess() async {
    let service = MockGetOrderListService(
      outcomes: [
        .success(
          OrderList(
            orders: [
              Order(
                id: "mock-1",
                status: .PENDING,
                name: "Chirag - Mock Order",
                startDate: .now,
                estimatedDeliveryDate: nil,
                deliveryDate: nil
              )
            ]
          )
        )
      ]
    )
    let viewModel = OrdersListViewModel(orderListService: service, user: "Chirag")

    #expect(viewModel.state == .noData)
    viewModel.onAppear()
    #expect([ScreenState.noData, .loading, .successful].contains(viewModel.state))

    await waitForState(.successful, in: viewModel)

    #expect(viewModel.state == .successful)
    #expect(viewModel.orders.count == 1)
    #expect(viewModel.orders.first?.name == "Chirag - Mock Order")

    let requestedUsers = await service.requestedUsers
    #expect(requestedUsers == ["Chirag"])
  }

  @Test
  func onAppearTransitionsToErrorStateOnServiceFailure() async {
    let service = MockGetOrderListService(outcomes: [.failure(.requestFailed(500))])
    let viewModel = OrdersListViewModel(orderListService: service, user: "Chirag")

    viewModel.onAppear()
    #expect([ScreenState.noData, .loading, .error].contains(viewModel.state))

    await waitForState(.error, in: viewModel)

    #expect(viewModel.state == .error)
    #expect(viewModel.orders.isEmpty)
  }

  @Test
  func dismissErrorMovesStateBackToNoData() async {
    let service = MockGetOrderListService(outcomes: [.failure(.requestFailed(500))])
    let viewModel = OrdersListViewModel(orderListService: service, user: "Chirag")

    viewModel.onAppear()
    await waitForState(.error, in: viewModel)
    #expect(viewModel.state == .error)

    viewModel.dismissError()

    #expect(viewModel.state == .noData)
  }

  @Test
  func retryFetchRefetchesAndCanRecoverAfterFailure() async {
    let service = MockGetOrderListService(
      outcomes: [
        .failure(.requestFailed(500)),
        .success(
          OrderList(
            orders: [
              Order(
                id: "mock-1",
                status: .DELIVERED,
                name: "Chirag - Recovered",
                startDate: .now,
                estimatedDeliveryDate: nil,
                deliveryDate: .now
              )
            ]
          )
        )
      ]
    )
    let viewModel = OrdersListViewModel(orderListService: service, user: "Chirag")

    viewModel.onAppear()
    await waitForState(.error, in: viewModel)
    #expect(viewModel.state == .error)

    viewModel.retryFetch()
    #expect([ScreenState.noData, .loading, .successful, .error].contains(viewModel.state))
    await waitForState(.successful, in: viewModel)

    #expect(viewModel.state == .successful)
    #expect(viewModel.orders.count == 1)
    #expect(viewModel.orders.first?.id == "mock-1")

    let callCount = await service.callCount
    #expect(callCount == 2)
  }

  @Test
  func updateFilterFiltersOrdersBySelectedStatus() {
    let viewModel = OrdersListViewModel(orderListService: MockGetOrderListService(), user: "Chirag")
    viewModel.orders = [
      Order(id: "1", status: .PENDING, name: "Pending", startDate: .now, estimatedDeliveryDate: nil, deliveryDate: nil),
      Order(id: "2", status: .INTRANSIT, name: "Transit", startDate: .now, estimatedDeliveryDate: nil, deliveryDate: nil),
      Order(id: "3", status: .DELIVERED, name: "Delivered", startDate: .now, estimatedDeliveryDate: nil, deliveryDate: nil)
    ]

    viewModel.updateFilter(.INTRANSIT)

    #expect(viewModel.filterButtonTitle == "In Transit")
    #expect(viewModel.screenTitle == "Orders - In Transit (1)")
    #expect(viewModel.filteredOrders.count == 1)
    #expect(viewModel.filteredOrders.first?.id == "2")
    #expect(viewModel.isShowingInTransitFilter)
    #expect(viewModel.isSelectedFilter(.INTRANSIT))
  }

  @Test
  func updateFilterWithNilShowsAllOrders() {
    let viewModel = OrdersListViewModel(orderListService: MockGetOrderListService(), user: "Chirag")
    viewModel.orders = [
      Order(id: "1", status: .PENDING, name: "Pending", startDate: .now, estimatedDeliveryDate: nil, deliveryDate: nil),
      Order(id: "2", status: .DELIVERED, name: "Delivered", startDate: .now, estimatedDeliveryDate: nil, deliveryDate: nil)
    ]
    viewModel.updateFilter(.PENDING)
    #expect(viewModel.filteredOrders.count == 1)

    viewModel.updateFilter(nil)

    #expect(viewModel.filterButtonTitle == "All")
    #expect(viewModel.screenTitle == "Orders (2)")
    #expect(viewModel.filteredOrders.count == 2)
    #expect(viewModel.isShowingAllFilters)
  }

  @Test
  func screenTitleUsesExpectedTextForEachFilterWithCount() {
    let viewModel = OrdersListViewModel(orderListService: MockGetOrderListService(), user: "Chirag")
    viewModel.orders = [
      Order(id: "1", status: .PENDING, name: "Pending", startDate: .now, estimatedDeliveryDate: nil, deliveryDate: nil),
      Order(id: "2", status: .INTRANSIT, name: "Transit", startDate: .now, estimatedDeliveryDate: nil, deliveryDate: nil),
      Order(id: "3", status: .DELIVERED, name: "Delivered", startDate: .now, estimatedDeliveryDate: nil, deliveryDate: nil)
    ]

    viewModel.updateFilter(nil)
    #expect(viewModel.screenTitle == "Orders (3)")

    viewModel.updateFilter(.INTRANSIT)
    #expect(viewModel.screenTitle == "Orders - In Transit (1)")

    viewModel.updateFilter(.PENDING)
    #expect(viewModel.screenTitle == "Orders - Pending Pick Up (1)")

    viewModel.updateFilter(.DELIVERED)
    #expect(viewModel.screenTitle == "Orders - Delivered (1)")
  }

  @Test
  func statusDisplayTitleReturnsExpectedTextForEachStatus() {
    let viewModel = OrdersListViewModel(orderListService: MockGetOrderListService(), user: "Chirag")

    #expect(viewModel.statusDisplayTitle(.PENDING) == "Pending")
    #expect(viewModel.statusDisplayTitle(.INTRANSIT) == "In Transit")
    #expect(viewModel.statusDisplayTitle(.DELIVERED) == "Delivered")
  }

  @Test
  func refreshRefetchesWithoutTransitioningToLoadingState() async {
    let service = MockGetOrderListService(delay: 0.2)
    let viewModel = OrdersListViewModel(orderListService: service, user: "Chirag")

    viewModel.onAppear()
    await waitForState(.successful, in: viewModel)
    #expect(viewModel.state == .successful)

    let refreshTask = Task {
      await viewModel.refresh()
    }

    try? await Task.sleep(for: .seconds(0.1))
    #expect(viewModel.state == .successful)

    await refreshTask.value
    #expect(viewModel.state == .successful)

    let callCount = await service.callCount
    #expect(callCount == 2)
  }
}

private extension OrdersListViewModelTests {
  /// View model state changes happen asynchronously via Task, so tests wait for
  /// the expected state to avoid race conditions and flaky assertions.
  func waitForState(
    _ expectedState: ScreenState,
    in viewModel: OrdersListViewModel,
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
}
