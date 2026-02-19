import Foundation
import Observation

@Observable
final class OrdersListViewModel {
  // MARK: Services

  var orderListService: GetOrderListUseCase

  // MARK: Properties

  var user: String
  private(set) var state: ScreenState
  private(set) var selectedStatusFilter: OrderStatus?

  init(orderListService: GetOrderListUseCase = GetOrderListService.sharedInstance,
       user: String = "Chirag") {
    self.orderListService = orderListService
    self.user = user
    state = .noData
    selectedStatusFilter = nil
  }

  var orders: [Order] = []
  var filteredOrders: [Order] {
    guard let selectedStatusFilter else { return orders }
    return orders.filter { $0.status == selectedStatusFilter }
  }

  func onAppear() {
    if state != .successful, orders.isEmpty {
      fetchOrders()
    }
  }

  func retryFetch() {
    Task {
      await fetchOrders(showLoadingState: true)
    }
  }

  func refresh() async {
    await fetchOrders(showLoadingState: false)
  }

  func updateFilter(_ status: OrderStatus?) {
    selectedStatusFilter = status
  }

  func dismissError() {
    if state == .error {
      state = .noData
    }
  }

  private func fetchOrders() {
    Task {
      await fetchOrders(showLoadingState: true)
    }
  }

  private func fetchOrders(showLoadingState: Bool) async {
    if showLoadingState {
      await MainActor.run {
        self.state = .loading
      }
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

  var filterButtonTitle: String {
    guard let selectedStatusFilter else { return "All" }
    return statusDisplayTitle(selectedStatusFilter)
  }

  var screenTitle: String {
    "\(baseScreenTitle) (\(filteredOrders.count))"
  }

  var availableFilters: [OrderStatus] {
    [
      .PENDING,
      .INTRANSIT,
      .DELIVERED
    ]
  }

  var isShowingAllFilters: Bool {
    selectedStatusFilter == nil
  }

  var isShowingPendingFilter: Bool {
    selectedStatusFilter == .PENDING
  }

  var isShowingInTransitFilter: Bool {
    selectedStatusFilter == .INTRANSIT
  }

  var isShowingDeliveredFilter: Bool {
    selectedStatusFilter == .DELIVERED
  }

  func isSelectedFilter(_ filter: OrderStatus) -> Bool {
    switch filter {
    case .PENDING:
      isShowingPendingFilter
    case .INTRANSIT:
      isShowingInTransitFilter
    case .DELIVERED:
      isShowingDeliveredFilter
    }
  }

  func statusDisplayTitle(_ status: OrderStatus) -> String {
    switch status {
    case .PENDING:
      "Pending"
    case .INTRANSIT:
      "In Transit"
    case .DELIVERED:
      "Delivered"
    }
  }

  private var baseScreenTitle: String {
    guard let selectedStatusFilter else { return "Orders" }
    switch selectedStatusFilter {
    case .PENDING:
      return "Orders - Pending Pick Up"
    case .INTRANSIT:
      return "Orders - In Transit"
    case .DELIVERED:
      return "Orders - Delivered"
    }
  }

  private func processOrders(fetchedOrders: OrderList) {
    state = .successful
    orders = fetchedOrders.orders
  }

  private func handleErrors() {
    state = .error
  }
}
