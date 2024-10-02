import SwiftUI

/// A view that displays the weather forecast for the current week.
struct ForecastView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var city: String = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            BackgroundGradient()
            
            VStack {
                HeaderView(title: "This Week")
                
                // Forecast list
                if let forecast = weatherViewModel.weather?.forecast?.forecastday, !forecast.isEmpty {
                    ForecastList(forecast: forecast)
                } else {
                    NoForecastView()
                }
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Subviews

/// A view that displays a gradient background.
struct BackgroundGradient: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

/// A view that displays a header with a title.
/// - Parameter title: The title text to display.
struct HeaderView: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center) // Center the title
        }
    }
}

/// A view that displays a list of forecast data.
/// - Parameter forecast: An array of `ForecastDay` to display.
struct ForecastList: View {
    let forecast: [ForecastDay]
    
    var body: some View {
        List(forecast, id: \.date) { forecastDay in
            ForecastRow(forecastDay: forecastDay)
        }
    }
}
/// A view that displays the weather details for a single forecast day.
/// - Parameter forecastDay: The forecast data for a specific day.
struct ForecastRow: View {
    let forecastDay: ForecastDay
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(forecastDay.date)
                    .bold()
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Max Temp: \(String(format: "%.f", forecastDay.day.maxTempC))°C")
                    .foregroundColor(.white)
                    .font(.subheadline)
                Text("Min Temp: \(String(format: "%.f", forecastDay.day.minTempC))°C")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("\(forecastDay.day.condition.text)")
                    .foregroundColor(.white)
                    .font(.subheadline)
            }
            Spacer()
            AsyncImage(url: URL(string: "https:\(forecastDay.day.condition.icon)")) { image in
                image.resizable()
            } placeholder: {
                Color.clear
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
        .background(Color.black.opacity(0.2))
        .cornerRadius(10)
    }
}

/// A view that displays a message when no forecast data is available.
struct NoForecastView: View {
    var body: some View {
        Spacer()
        Text("No Forecast yet")
            .font(.headline)
            .foregroundColor(.white)
        
        Text("Please enter city to check this week's forecast")
            .font(.subheadline)
            .foregroundColor(.white)
    }
}
