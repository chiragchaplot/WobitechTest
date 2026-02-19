import SwiftUI

struct OrderDetailsView: View {
  var viewModel: OrderDetailsViewModel
  private let deliveryImageView: AnyView

  init(
    orderID: String,
    deliveryImageView: AnyView = AnyView(OrderDeliveredImageView())
  ) {
    viewModel = OrderDetailsViewModel(orderID: orderID)
    self.deliveryImageView = deliveryImageView
  }

  var body: some View {
    stateContent
      .navigationTitle("Order Details")
      .onAppear(perform: viewModel.onAppear)
      .onDisappear(perform: viewModel.onDisappear)
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

  @ViewBuilder
  private var stateContent: some View {
    switch viewModel.state {
    case .successful:
      successfulStateView
    case .loading:
      loadingStateView
    case .noData:
      noDataStateView
    case .error:
      errorStateView
    }
  }

  private var successfulStateView: some View {
    List {
      row("Order ID", value: viewModel.displayModel.orderID)
      row("Order", value: viewModel.displayModel.orderName)
      row("From Name", value: viewModel.displayModel.fromNameText)
      row("Final Delivery Name", value: viewModel.displayModel.finalDeliveryNameText)
      row("From Address", value: viewModel.displayModel.fromAddressText)
      row("Final Address", value: viewModel.displayModel.finalAddressText)
      row("Status", value: viewModel.displayModel.statusText)
      row("Start Date", value: viewModel.displayModel.startDateText)

      if viewModel.isOrderDelivered {
        row("Delivered At", value: viewModel.displayModel.deliveredAtText)
        deliveryImageView
      } else {
        row("Estimated Delivery", value: viewModel.displayModel.estimatedDeliveryText)
        row("Last Location", value: viewModel.displayModel.lastLocationText)
      }
      if viewModel.isOrderPendingPickUp {
        row("Driver", value: viewModel.displayModel.driverNameText)
      }
    }
  }

  private var loadingStateView: some View {
    ProgressView()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var noDataStateView: some View {
    Text("Loading Data...")
      .foregroundStyle(.secondary)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var errorStateView: some View {
    Color.clear
      .frame(maxWidth: .infinity, maxHeight: .infinity)
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
