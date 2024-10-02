//
//  ContentView.swift
//  WeatherForecastingApp
//
//  Created by Priya Mehndiratta on 30/09/24.
//

import SwiftUI

// MARK: - ContentView
/// The main view of the Weather Forecasting application.
struct ContentView: View {
    
    // MARK: Properties
    @State private var selectedTab = 0
    
    // MARK: Initializer
    init() {
        // Change the appearance of the tab bar background and the items
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    // MARK: Body
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


// MARK: - Preview
/// A preview provider for the ContentView, allowing live previews in Xcode.
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
