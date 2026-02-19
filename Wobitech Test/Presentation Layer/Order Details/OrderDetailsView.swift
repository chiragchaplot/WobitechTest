import SwiftUI

struct OrderDetailsView: View {
  var viewModel: OrderDetailsViewModel

  var body: some View {
    NavigationStack {
      List {
        row("Order", value: viewModel.orderName)
        row("Status", value: viewModel.status.rawValue)
        row("Start Date", value: viewModel.startDate.formatted(date: .abbreviated, time: .shortened))
        row("Estimated Delivery", value: formatted(viewModel.estimatedDeliveryDate))
        row("Delivered At", value: formatted(viewModel.deliveryDate))
      }
      .navigationTitle("Order Details")
    }
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
  OrderDetailsView(viewModel: OrderDetailsViewModel())
}
