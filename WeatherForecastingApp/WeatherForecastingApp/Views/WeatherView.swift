import SwiftUI

// MARK: - Main Weather View
struct WeatherView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var city: String = ""
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            // Background gradient
            BackgroundLinearGradient()
            
            VStack(spacing: 20) {
                VStack {
                    TextField(StringConstants.enterCityName, text: $city)
                        .padding(.all, 7) // Horizontal padding inside the TextField
                        .frame(height: 45) // Set the height of the TextField
                        .background(Color(.systemGray6)) // Background color
                        .cornerRadius(8) // Rounded corners
                        .padding()
                    
                    Button(action: {
                        if city.isEmpty {
                            showAlert = true
                            weatherViewModel.errorMessage = nil
                        } else {
                            weatherViewModel.weather = nil
                            showAlert = false
                            weatherViewModel.fetchWeather(for: city)
                        }
                    }) {
                        Text(StringConstants.checkWeather)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    .padding(.horizontal)
                }
                
                // Show weather information if available
                if let weather = weatherViewModel.weather {
                    WeatherDisplay(weather: weather)
                } else if weatherViewModel.errorMessage != nil{
                    // Clear previous weather data and show error
                    Text(AlertMessages.defaultAlert.description)
                        .foregroundColor(.red)
                        .padding()
                        .onAppear {
                            // Clear the weather data when there's an error
                            weatherViewModel.weather = nil
                            showAlert = true // Show alert for the error message
                        }
                }
                
                Spacer()
            }.alert(isPresented: $showAlert) {
                if let errorMessage = weatherViewModel.errorMessage {
                    return Alert(
                        title: Text(StringConstants.error),
                        message: Text(errorMessage),
                        dismissButton: .default(Text(StringConstants.ok))
                    )
                } else{
                    return Alert(
                        title: Text(StringConstants.error),
                        message: Text(AlertMessages.enterCityToCheckWeather.description),
                        dismissButton: .default(Text(StringConstants.ok))
                        
                    )
                }
            }
        }
    }
}

// MARK: - Subviews

/// A view that displays a gradient background.
struct BackgroundLinearGradient: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.orange, .purple]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}


/// A view that displays weather information.
struct WeatherDisplay: View {
    var weather: WeatherResponse

    var body: some View {
        VStack {
            CityInfoView(location: weather.location, condition: weather.current.condition)
            TemperatureView(temperature: weather.current.tempC, humidity: weather.current.humidity, windSpeed: weather.current.windKph)
            SunInfoView(astro: weather.forecast?.forecastday.first?.astro)
        }
    }
}

/// A view that displays information about the city.
struct CityInfoView: View {
    var location: Location
    var condition: WeatherCondition

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(location.name), \(location.region)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                Text(condition.text)
                    .font(.title3)
                    .foregroundColor(.white)
            }
            Spacer()
            AsyncImage(url: URL(string: "https:\(condition.icon)")) { image in
                image.resizable()
            } placeholder: {
                Color.clear
            }
            .frame(width: 128, height: 128)
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
        .padding()
    }
}

/// A view that displays temperature and related information.
struct TemperatureView: View {
    var temperature: Double
    var humidity: Int
    var windSpeed: Double

    var body: some View {
        VStack {
            Text("\(String(format: "%.f", temperature))°C")
                .font(.system(size: 80))
                .bold()
                .foregroundColor(.white)
            HStack {
                InfoLabel(title: StringConstants.humidity, value: "\(humidity) %")
                Spacer()
                InfoLabel(title: StringConstants.windSpeed, value: "\(windSpeed) kph")
            }
            .padding(.horizontal)
        }
    }
}

/// A view that displays sunrise and sunset times.
struct SunInfoView: View {
    var astro: Astro?

    var body: some View {
        HStack {
            InfoLabel(title: StringConstants.sunrise, value: astro?.sunrise ?? "")
            Spacer()
            InfoLabel(title: StringConstants.sunset, value: astro?.sunset ?? "")
        }
        .padding(.horizontal)
    }
}

/// A view that displays a title and a value.
struct InfoLabel: View {
    var title: String
    var value: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.white)
            Text(value)
                .font(.title)
                .foregroundColor(.white)
        }
    }
}
