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

    var body: some Scene {
           WindowGroup {
               ContentView()
                   .environment(\.managedObjectContext, persistenceController.container.viewContext)
                   .environmentObject(WeatherViewModel(coreDataService: CoreDataService())) // Inject CoreDataService
           }
       }
}
