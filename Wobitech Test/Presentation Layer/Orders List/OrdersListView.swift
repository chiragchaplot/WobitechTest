import SwiftUI

struct OrdersListView: View {
  var viewModel: OrdersListViewModel

  var body: some View {
    NavigationStack {
      List(viewModel.orders, id: \.name) { order in
        VStack(alignment: .leading, spacing: 4) {
          Text(order.name)
            .font(.headline)
          Text(order.status.rawValue)
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
      }
      .navigationTitle("Orders")
    }
  }
}

#Preview {
  OrdersListView(viewModel: OrdersListViewModel())
}
