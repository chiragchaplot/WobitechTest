import SwiftUI

struct OrdersListView: View {
  var viewModel: OrdersListViewModel

  var body: some View {
    NavigationStack {
      stateContent
        .navigationTitle("Orders")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Menu {
              Button {
                viewModel.updateFilter(nil)
              } label: {
                Label("All", systemImage: viewModel.isShowingAllFilters ? "checkmark" : "")
              }

              ForEach(viewModel.availableFilters, id: \.rawValue) { status in
                Button {
                  viewModel.updateFilter(status)
                } label: {
                  Label(
                    status.displayTitle,
                    systemImage: viewModel.isSelectedFilter(status) ? "checkmark" : ""
                  )
                }
              }
            } label: {
              Label("Filter: \(viewModel.filterButtonTitle)", systemImage: "line.3.horizontal.decrease.circle")
            }
          }
        }
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
    List(viewModel.filteredOrders, id: \.id) { order in
      OrdersListItemView(order: order)
    }
    .refreshable {
      await viewModel.refresh()
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

private extension OrderStatus {
  var displayTitle: String {
    switch self {
    case .PENDING:
      "Pending"
    case .INTRANSIT:
      "In Transit"
    case .DELIVERED:
      "Delivered"
    }
  }
}
