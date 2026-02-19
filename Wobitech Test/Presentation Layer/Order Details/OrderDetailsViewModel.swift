import Foundation
import Observation

@Observable
final class OrderDetailsViewModel {
  var orderName: String = "Order #1002"
  var status: OrderStatus = .INTRANSIT
  var startDate: Date = .now.addingTimeInterval(-86400)
  var estimatedDeliveryDate: Date? = .now.addingTimeInterval(172_800)
  var deliveryDate: Date?
}
