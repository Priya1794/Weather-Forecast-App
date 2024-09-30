import SwiftUI

struct ForecastView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var city: String = ""
    
    var body: some View {
        VStack {
            TextField("Enter city name", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Get Forecast") {
                //                forecastViewModel.fetchForecast(for: city)
            }
            .padding()
            
            // Check if forecast data exists and display it
            if let forecast = weatherViewModel.weather?.forecast?.forecastday, !forecast.isEmpty {
                List(forecast, id: \.date) { forecastDay in
                    VStack(alignment: .leading) {
                        Text(forecastDay.date)
                            .font(.headline)
                        
                        // Accessing the day's weather information
                        Text("Max Temp: \(forecastDay.day.maxTempC)°C")
                        Text("Min Temp: \(forecastDay.day.minTempC)°C")
                        Text("Condition: \(forecastDay.day.condition.text)")
                    }
                }
            } else if let errorMessage = weatherViewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
            
        }
        .padding()
    }
}
