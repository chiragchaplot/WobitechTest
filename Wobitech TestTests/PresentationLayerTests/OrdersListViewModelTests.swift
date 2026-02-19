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
    let service = SuccessfulGetOrderListUseCase()
    let viewModel = OrdersListViewModel(orderListService: service, user: "Chirag")

    #expect(viewModel.state == .noData)
    viewModel.onAppear()
    #expect(viewModel.state == .loading || viewModel.state == .successful)

    await waitForState(.successful, in: viewModel)

    #expect(viewModel.state == .successful)
    #expect(viewModel.orders.count == 1)
    #expect(viewModel.orders.first?.name == "Chirag - Mock Order")

    let requestedUsers = await service.requestedUsers
    #expect(requestedUsers == ["Chirag"])
  }

  @Test
  func onAppearTransitionsToErrorStateOnServiceFailure() async {
    let viewModel = OrdersListViewModel(orderListService: FailingGetOrderListUseCase(), user: "Chirag")

    viewModel.onAppear()
    #expect(viewModel.state == .loading || viewModel.state == .error)

    await waitForState(.error, in: viewModel)

    #expect(viewModel.state == .error)
    #expect(viewModel.orders.isEmpty)
  }

  @Test
  func dismissErrorMovesStateBackToNoData() async {
    let viewModel = OrdersListViewModel(orderListService: FailingGetOrderListUseCase(), user: "Chirag")

    viewModel.onAppear()
    await waitForState(.error, in: viewModel)
    #expect(viewModel.state == .error)

    viewModel.dismissError()

    #expect(viewModel.state == .noData)
  }

  @Test
  func retryFetchRefetchesAndCanRecoverAfterFailure() async {
    let service = SequencedGetOrderListUseCase(
      outcomes: [.failure, .success]
    )
    let viewModel = OrdersListViewModel(orderListService: service, user: "Chirag")

    viewModel.onAppear()
    await waitForState(.error, in: viewModel)
    #expect(viewModel.state == .error)

    viewModel.retryFetch()
    #expect(viewModel.state == .loading)
    await waitForState(.successful, in: viewModel)

    #expect(viewModel.state == .successful)
    #expect(viewModel.orders.count == 1)
    #expect(viewModel.orders.first?.id == "mock-1")

    let callCount = await service.callCount
    #expect(callCount == 2)
  }
}

private extension OrdersListViewModelTests {
  func waitForState(
    _ expectedState: ScreenState,
    in viewModel: OrdersListViewModel,
    timeoutNanoseconds: UInt64 = 1_000_000_000
  ) async {
    let start = Date()

    while viewModel.state != expectedState {
      if Date().timeIntervalSince(start) > Double(timeoutNanoseconds) / 1_000_000_000 {
        Issue.record("Timed out waiting for state: \(expectedState)")
        return
      }
      try? await Task.sleep(nanoseconds: 20_000_000)
    }
  }
}

private actor SuccessfulGetOrderListUseCase: GetOrderListUseCase {
  private(set) var requestedUsers: [String] = []

  func getOrderList(for user: String) async throws -> OrderList {
    requestedUsers.append(user)
    return OrderList(
      orders: [
        Order(
          id: "mock-1",
          status: .PENDING,
          name: "\(user) - Mock Order",
          startDate: .now,
          estimatedDeliveryDate: nil,
          deliveryDate: nil
        )
      ]
    )
  }
}

private actor FailingGetOrderListUseCase: GetOrderListUseCase {
  func getOrderList(for _: String) async throws -> OrderList {
    throw NetworkError.requestFailed(500)
  }
}

private actor SequencedGetOrderListUseCase: GetOrderListUseCase {
  enum Outcome {
    case success
    case failure
  }

  private var outcomes: [Outcome]
  private(set) var callCount = 0

  init(outcomes: [Outcome]) {
    self.outcomes = outcomes
  }

  func getOrderList(for user: String) async throws -> OrderList {
    callCount += 1

    guard !outcomes.isEmpty else {
      return OrderList(orders: [])
    }

    let next = outcomes.removeFirst()
    switch next {
    case .success:
      return OrderList(
        orders: [
          Order(
            id: "mock-1",
            status: .DELIVERED,
            name: "\(user) - Recovered",
            startDate: .now,
            estimatedDeliveryDate: nil,
            deliveryDate: .now
          )
        ]
      )
    case .failure:
      throw NetworkError.requestFailed(500)
    }
  }
}
