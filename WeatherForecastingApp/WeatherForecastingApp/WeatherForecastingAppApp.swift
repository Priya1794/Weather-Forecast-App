//
//  WeatherForecastingAppApp.swift
//  WeatherForecastingApp
//
//  Created by Priya Mehndiratta on 30/09/24.
//

import SwiftUI

@main
struct WeatherForecastingAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
