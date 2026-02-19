import Foundation
import Observation

@Observable
final class OrdersListViewModel {
  var orders: [Order] = [
    Order(id: "1", status: .PENDING, name: "Order #1001", startDate: .now, estimatedDeliveryDate: .now.addingTimeInterval(86400), deliveryDate: nil),
    Order(id: "2", status: .INTRANSIT, name: "Order #1002", startDate: .now.addingTimeInterval(-86400), estimatedDeliveryDate: .now.addingTimeInterval(172_800), deliveryDate: nil),
    Order(id: "3", status: .DELIVERED, name: "Order #1003", startDate: .now.addingTimeInterval(-259_200), estimatedDeliveryDate: nil, deliveryDate: .now.addingTimeInterval(-86400))
  ]
}
