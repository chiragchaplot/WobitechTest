import Foundation
import Observation

struct OrderDetailsDisplayModel {
  var orderID: String
  var orderName: String
  var fromNameText: String
  var finalDeliveryNameText: String
  var fromAddressText: String
  var finalAddressText: String
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
  private var detailUpdatesTask: Task<Void, Never>?
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
      fromNameText: "N/A",
      finalDeliveryNameText: "N/A",
      fromAddressText: "N/A",
      finalAddressText: "N/A",
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
    if state == .successful {
      startStreamingIfNeeded()
      return
    }
    fetchOrderDetail()
  }

  func retryFetch() {
    stopStreaming()
    fetchOrderDetail()
  }

  func dismissError() {
    if state == .error {
      state = .noData
    }
  }

  func onDisappear() {
    stopStreaming()
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
          self.startStreamingIfNeeded()
        }
      } catch {
        await MainActor.run {
          self.stopStreaming()
          self.orderStatus = nil
          self.state = .error
        }
      }
    }
  }

  private func startStreamingIfNeeded() {
    guard shouldObserveOrderUpdates else {
      stopStreaming()
      return
    }

    guard detailUpdatesTask == nil else { return }

    detailUpdatesTask = Task {
      let stream = await orderDetailService.streamOrderDetail(for: orderID, pollingInterval: 10)

      do {
        for try await latestDetail in stream {
          await MainActor.run {
            self.orderStatus = latestDetail.status
            self.displayModel = self.mapToDisplayModel(latestDetail)

            if !self.shouldObserveOrderUpdates {
              self.stopStreaming()
            }
          }
        }
      } catch {
        await MainActor.run {
          self.stopStreaming()
          self.state = .error
        }
      }
    }
  }

  private func stopStreaming() {
    detailUpdatesTask?.cancel()
    detailUpdatesTask = nil
  }

  private var shouldObserveOrderUpdates: Bool {
    orderStatus == .PENDING || orderStatus == .INTRANSIT
  }

  private func mapToDisplayModel(_ detail: OrderDetail) -> OrderDetailsDisplayModel {
    OrderDetailsDisplayModel(
      orderID: detail.id,
      orderName: detail.name,
      fromNameText: detail.fromName.isEmpty ? "N/A" : detail.fromName,
      finalDeliveryNameText: detail.finalDeliveryName.isEmpty ? "N/A" : detail.finalDeliveryName,
      fromAddressText: detail.fromAddress.isEmpty ? "N/A" : detail.fromAddress,
      finalAddressText: detail.finalAddress.isEmpty ? "N/A" : detail.finalAddress,
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
