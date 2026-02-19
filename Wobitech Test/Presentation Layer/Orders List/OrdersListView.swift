import SwiftUI

struct OrdersListView: View {
  var viewModel: OrdersListViewModel

  var body: some View {
    NavigationStack {
      stateContent
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .principal) {
            Text(viewModel.screenTitle)
              .font(.headline)
              .lineLimit(2)
              .minimumScaleFactor(0.7)
          }
          OrdersFilterToolbar(viewModel: viewModel)
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
      NavigationLink {
        OrderDetailsView(orderID: order.id)
      } label: {
        OrdersListItemView(order: order)
      }
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

private struct OrdersFilterToolbar: ToolbarContent {
  var viewModel: OrdersListViewModel

  var body: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      OrdersFilterMenu(viewModel: viewModel)
    }
  }
}

private struct OrdersFilterMenu: View {
  var viewModel: OrdersListViewModel

  var body: some View {
    Menu {
      OrdersFilterMenuButton(
        title: "All",
        isSelected: viewModel.isShowingAllFilters
      ) {
        viewModel.updateFilter(nil)
      }

      ForEach(viewModel.availableFilters, id: \.rawValue) { status in
        OrdersFilterMenuButton(
          title: viewModel.statusDisplayTitle(status),
          isSelected: viewModel.isSelectedFilter(status)
        ) {
          viewModel.updateFilter(status)
        }
      }
    } label: {
      Label("Filter: \(viewModel.filterButtonTitle)", systemImage: "line.3.horizontal.decrease.circle")
    }
  }
}

private struct OrdersFilterMenuButton: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Label(title, systemImage: isSelected ? "checkmark" : "")
    }
  }
}
