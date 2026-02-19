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
      .navigationTitle(L10n.text("orderDetails.navigation.title"))
      .onAppear(perform: viewModel.onAppear)
      .onDisappear(perform: viewModel.onDisappear)
      .alert(
        L10n.text("orderDetails.alert.error.title"),
        isPresented: Binding(
          get: { viewModel.state == .error },
          set: { isPresented in
            if !isPresented {
              viewModel.dismissError()
            }
          }
        )
      ) {
        Button(L10n.text("common.button.tryAgain")) {
          viewModel.retryFetch()
        }
        Button(L10n.text("common.button.cancel"), role: .cancel) {}
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
      row(L10n.text("orderDetails.row.orderId"), value: viewModel.displayModel.orderID)
      row(L10n.text("orderDetails.row.order"), value: viewModel.displayModel.orderName)
      row(L10n.text("orderDetails.row.fromName"), value: viewModel.displayModel.fromNameText)
      row(L10n.text("orderDetails.row.finalDeliveryName"), value: viewModel.displayModel.finalDeliveryNameText)
      row(L10n.text("orderDetails.row.fromAddress"), value: viewModel.displayModel.fromAddressText)
      row(L10n.text("orderDetails.row.finalAddress"), value: viewModel.displayModel.finalAddressText)
      row(L10n.text("orderDetails.row.status"), value: viewModel.displayModel.statusText)
      row(L10n.text("orderDetails.row.startDate"), value: viewModel.displayModel.startDateText)

      if viewModel.isOrderDelivered {
        row(L10n.text("orderDetails.row.deliveredAt"), value: viewModel.displayModel.deliveredAtText)
        deliveryImageView
      } else {
        row(L10n.text("orderDetails.row.estimatedDelivery"), value: viewModel.displayModel.estimatedDeliveryText)
        row(L10n.text("orderDetails.row.lastLocation"), value: viewModel.displayModel.lastLocationText)
      }
      if viewModel.isOrderPendingPickUp {
        row(L10n.text("orderDetails.row.driver"), value: viewModel.displayModel.driverNameText)
      }
    }
  }

  private var loadingStateView: some View {
    ProgressView()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  private var noDataStateView: some View {
    Text(L10n.text("common.loadingData"))
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
