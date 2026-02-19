////
//  OrderListItemView.swift
//  Wobitech Test by Chirag Chaplot
//
//  Created on 19/2/2026.

import SwiftUI

struct OrdersListItemView: View {
  private var order: Order

  init(order: Order) {
    self.order = order
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(order.name)
        .font(.headline)
      Text(order.status.rawValue)
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
  }
}

#Preview {
  OrdersListView(viewModel: OrdersListViewModel())
}
