import Foundation
import Observation

struct OrderDetailsDisplayModel {
  var orderID: String
  var orderName: String
  var statusText: String
  var startDateText: String
  var estimatedDeliveryText: String
  var deliveredAtText: String
  var lastLocationText: String
  var driverNameText: String
  var deliveryPhoto: Data?
}

@Observable
final class OrderDetailsViewModel {
  let orderID: String
  var orderDetailService: GetOrderDetailUseCase
  private(set) var state: ScreenState
  private(set) var orderStatus: OrderStatus?
  private(set) var displayModel: OrderDetailsDisplayModel
  var isOrderDelivered: Bool {
    orderStatus == .DELIVERED
  }

  var isOrderPendingPickUp: Bool {
    orderStatus == .PENDING
  }

  init(
    orderID: String = "mock-1",
    orderDetailService: GetOrderDetailUseCase = GetOrderDetailService.sharedInstance
  ) {
    self.orderID = orderID
    self.orderDetailService = orderDetailService
    state = .noData
    orderStatus = nil
    displayModel = OrderDetailsDisplayModel(
      orderID: orderID,
      orderName: "N/A",
      statusText: "N/A",
      startDateText: "N/A",
      estimatedDeliveryText: "N/A",
      deliveredAtText: "N/A",
      lastLocationText: "N/A",
      driverNameText: "N/A",
      deliveryPhoto: nil
    )
  }

  func onAppear() {
    if state != .successful {
      fetchOrderDetail()
    }
  }

  func retryFetch() {
    fetchOrderDetail()
  }

  func dismissError() {
    if state == .error {
      state = .noData
    }
  }

  private func fetchOrderDetail() {
    Task {
      await MainActor.run {
        self.state = .loading
      }

      do {
        let detail = try await orderDetailService.getOrderDetail(for: orderID)
        await MainActor.run {
          self.orderStatus = detail.status
          self.displayModel = self.mapToDisplayModel(detail)
          self.state = .successful
        }
      } catch {
        await MainActor.run {
          self.orderStatus = nil
          self.state = .error
        }
      }
    }
  }

  private func mapToDisplayModel(_ detail: OrderDetail) -> OrderDetailsDisplayModel {
    OrderDetailsDisplayModel(
      orderID: detail.id,
      orderName: detail.name,
      statusText: detail.status.rawValue,
      startDateText: detail.startDate.formatted(date: .abbreviated, time: .shortened),
      estimatedDeliveryText: formatted(detail.estimatedDeliveryDate),
      deliveredAtText: formatted(detail.deliveryDate),
      lastLocationText: detail.lastLocation.isEmpty ? "N/A" : detail.lastLocation,
      driverNameText: detail.driverName.isEmpty ? "N/A" : detail.driverName,
      deliveryPhoto: detail.deliveryPhoto
    )
  }

  private func formatted(_ date: Date?) -> String {
    guard let date else { return "N/A" }
    return date.formatted(date: .abbreviated, time: .shortened)
  }
}
