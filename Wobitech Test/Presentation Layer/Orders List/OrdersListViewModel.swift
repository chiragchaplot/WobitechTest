import Foundation
import Observation

@Observable
final class OrdersListViewModel {
  // MARK: Services

  var orderListService: GetOrderListUseCase

  // MARK: Properties

  var user: String
  private(set) var state: ScreenState

  init(orderListService: GetOrderListUseCase = GetOrderListService.sharedInstance,
       user: String = "Chirag") {
    self.orderListService = orderListService
    self.user = user
    state = .noData
  }

  var orders: [Order] = []

  func onAppear() {
    if state != .successful, orders.isEmpty {
      fetchOrders()
    }
  }

  func retryFetch() {
    fetchOrders()
  }

  func dismissError() {
    if state == .error {
      state = .noData
    }
  }

  private func fetchOrders() {
    Task {
      await MainActor.run {
        self.state = .loading
      }

      do {
        let fetchedOrders = try await orderListService.getOrderList(for: user)
        await MainActor.run {
          self.processOrders(fetchedOrders: fetchedOrders)
        }
      } catch {
        await MainActor.run {
          self.handleErrors()
        }
      }
    }
  }

  /// This method is generally added when viewModel needs to do any data transformation on retrieved information, if needed.
  private func processOrders(fetchedOrders: OrderList) {
    state = .successful
    orders = fetchedOrders.orders
  }

  private func handleErrors() {
    state = .error
  }
}
