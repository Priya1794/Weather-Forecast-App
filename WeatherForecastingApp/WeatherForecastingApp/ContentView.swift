//
//  ContentView.swift
//  WeatherForecastingApp
//
//  Created by Priya Mehndiratta on 30/09/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            WeatherView()
                .tabItem {
                    Label("Current Weather", systemImage: "cloud.sun.fill")
                }
                .tag(0)

            ForecastView()
                .tabItem {
                    Label("5-Day Forecast", systemImage: "calendar")
                }
                .tag(1)
        }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
