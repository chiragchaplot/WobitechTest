import Foundation
import Observation

@Observable
final class OrderDetailsViewModel {
  let orderID: String
  var orderName: String
  var status: OrderStatus
  var startDate: Date
  var estimatedDeliveryDate: Date?
  var deliveryDate: Date?

  init(orderID: String = "mock-1") {
    self.orderID = orderID
    orderName = "Order #\(orderID)"
    status = .INTRANSIT
    startDate = .now.addingTimeInterval(-86400)
    estimatedDeliveryDate = .now.addingTimeInterval(172_800)
    deliveryDate = nil
  }
}
