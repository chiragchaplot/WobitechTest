//
//  HomeView.swift
//  Wobitech Test
//
//  Created by Chirag Chaplot on 18/2/2026.
//

import SwiftUI

struct HomeView: View {
  @State private var ordersListViewModel = OrdersListViewModel()
  @State private var orderDetailsViewModel = OrderDetailsViewModel()

  var body: some View {
    TabView {
      OrdersListView(viewModel: ordersListViewModel)
        .tabItem {
          Label(L10n.text("home.tab.orders"), systemImage: "list.bullet")
        }

//      OrderDetailsView(viewModel: orderDetailsViewModel)
//        .tabItem {
//          Label(L10n.text("home.tab.details"), systemImage: "doc.text.magnifyingglass")
//        }
    }
  }
}

#Preview {
  HomeView()
}
