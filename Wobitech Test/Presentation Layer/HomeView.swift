//
//  ContentView.swift
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
                    Label("Orders", systemImage: "list.bullet")
                }

            OrderDetailsView(viewModel: orderDetailsViewModel)
                .tabItem {
                    Label("Details", systemImage: "doc.text.magnifyingglass")
                }
        }
    }
}

#Preview {
    HomeView()
}
