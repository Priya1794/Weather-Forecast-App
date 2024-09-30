//
//  WeatherForecastingAppApp.swift
//  WeatherForecastingApp
//
//  Created by Priya Mehndiratta on 30/09/24.
//

import SwiftUI


@main
struct WeatherForecastingApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var weatherViewModel = WeatherViewModel()

    var body: some Scene {
        WindowGroup {
          
            ContentView().environmentObject(weatherViewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
