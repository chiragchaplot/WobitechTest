import SwiftUI

struct OrderDetailsView: View {
  var viewModel: OrderDetailsViewModel

  init(orderID: String) {
    viewModel = OrderDetailsViewModel(orderID: orderID)
  }

  var body: some View {
    List {
      row("Order ID", value: viewModel.displayModel.orderID)
      row("Order", value: viewModel.displayModel.orderName)
      row("Status", value: viewModel.displayModel.statusText)
      row("Start Date", value: viewModel.displayModel.startDateText)

      if viewModel.isOrderDelivered {
        row("Delivered At", value: viewModel.displayModel.deliveredAtText)
      } else {
        row("Estimated Delivery", value: viewModel.displayModel.estimatedDeliveryText)
      }
      row("Last Location", value: viewModel.displayModel.lastLocationText)
      if viewModel.isOrderPendingPickUp {
        row("Driver", value: viewModel.displayModel.driverNameText)
      }
    }
    .navigationTitle("Order Details")
    .onAppear(perform: viewModel.onAppear)
    .alert(
      "Unable to fetch order detail",
      isPresented: Binding(
        get: { viewModel.state == .error },
        set: { isPresented in
          if !isPresented {
            viewModel.dismissError()
          }
        }
      )
    ) {
      Button("Try Again") {
        viewModel.retryFetch()
      }
      Button("Cancel", role: .cancel) {}
    }
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
