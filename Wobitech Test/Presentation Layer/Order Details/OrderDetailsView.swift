import SwiftUI

struct OrderDetailsView: View {
  var viewModel: OrderDetailsViewModel

  init(orderID: String) {
    viewModel = OrderDetailsViewModel(orderID: orderID)
  }

  init(viewModel: OrderDetailsViewModel) {
    self.viewModel = viewModel
  }

  var body: some View {
    List {
      row("Order ID", value: viewModel.orderID)
      row("Order", value: viewModel.orderName)
      row("Status", value: viewModel.status.rawValue)
      row("Start Date", value: viewModel.startDate.formatted(date: .abbreviated, time: .shortened))
      row("Estimated Delivery", value: formatted(viewModel.estimatedDeliveryDate))
      row("Delivered At", value: formatted(viewModel.deliveryDate))
    }
    .navigationTitle("Order Details")
  }

  private func formatted(_ date: Date?) -> String {
    guard let date else { return "N/A" }
    return date.formatted(date: .abbreviated, time: .shortened)
  }

  private func row(_ title: String, value: String) -> some View {
    HStack {
      Text(title)
      Spacer()
      Text(value)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.trailing)
    }
  }
}

#Preview {
  NavigationStack {
    OrderDetailsView(orderID: "mock-1")
  }
}
