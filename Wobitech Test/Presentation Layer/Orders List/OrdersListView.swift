import SwiftUI

struct OrdersListView: View {
  var viewModel: OrdersListViewModel

  var body: some View {
    NavigationStack {
      stateContent
        .navigationTitle("Orders")
    }
    .onAppear(perform: viewModel.onAppear)
    .alert(
      "Error",
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
    } message: {
      Text("Please try again.")
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
    List(viewModel.orders, id: \.name) { order in
      OrdersListItemView(order: order)
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
}

#Preview {
  OrdersListView(viewModel: OrdersListViewModel())
}
