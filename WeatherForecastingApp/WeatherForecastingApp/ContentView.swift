//
//  ContentView.swift
//  WeatherForecastingApp
//
//  Created by Priya Mehndiratta on 30/09/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
   
        @State private var city: String = ""
        
        var body: some View {
            NavigationView {
                VStack {
                    TextField("Enter city name", text: $city)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Get Weather") {
                    }
                    .padding()
                    
                }
                .navigationTitle("Weather App")
            }
        }
    }

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
