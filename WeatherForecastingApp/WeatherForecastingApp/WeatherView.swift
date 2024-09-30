import SwiftUI

struct WeatherView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var city: String = ""

    var body: some View {
        VStack {
            TextField("Enter city name", text: $city)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Get Weather") {
                weatherViewModel.fetchWeather(for: city)
            }
            .padding()

            if let weather = weatherViewModel.weather {
                Text("Temperature: \(weather.current.tempC)°C")
                Text("Humidity: \(weather.current.humidity)%")
                Text("Description: \(weather.current.condition.text )")
            } else if let errorMessage = weatherViewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

