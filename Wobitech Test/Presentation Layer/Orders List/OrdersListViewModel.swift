import Foundation
import Observation

@Observable
final class OrdersListViewModel {
    var orders: [Order] = [
        Order(status: .PENDING, name: "Order #1001", startDate: .now, estimatedDeliveryDate: .now.addingTimeInterval(86_400), deliveryDate: nil),
        Order(status: .INTRANSIT, name: "Order #1002", startDate: .now.addingTimeInterval(-86_400), estimatedDeliveryDate: .now.addingTimeInterval(172_800), deliveryDate: nil),
        Order(status: .DELIVERED, name: "Order #1003", startDate: .now.addingTimeInterval(-259_200), estimatedDeliveryDate: nil, deliveryDate: .now.addingTimeInterval(-86_400))
    ]
}
