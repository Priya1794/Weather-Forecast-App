import SwiftUI

struct ForecastView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var city: String = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Text("This Week")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center) // Center the title
                    
                }
                
                // Forecast list
                if let forecast = weatherViewModel.weather?.forecast?.forecastday, !forecast.isEmpty {
                    List(forecast, id: \.date) { forecastDay in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(forecastDay.date)
                                    .bold()
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Max Temp:\( String(format:"%.f", forecastDay.day.maxTempC))°C")
                                
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                Text("Min Temp:\( String(format:"%.f", forecastDay.day.minTempC))°C")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Text("\(forecastDay.day.condition.text)")
                                    .foregroundColor(.white).font(.subheadline)
                            }
                            Spacer()
                            AsyncImage(url: URL(string: "https:\(forecastDay.day.condition.icon)")) { image in
                                image.resizable()
                            } placeholder: {
                                Color.clear
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(.rect(cornerRadius: 10))
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(10)
                    }
                } else {
                    Spacer()
                    Text("No Forecast yet")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    
                    Text("Please enter city to check next week forecast")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                }
                Spacer()
            }
            .padding()
        }
    }
}
