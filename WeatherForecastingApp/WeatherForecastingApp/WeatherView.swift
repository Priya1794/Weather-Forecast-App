import SwiftUI

struct WeatherView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var city: String = ""
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [.orange, .purple]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Get weather button
                VStack {
                    TextField("Enter city name", text: $city)
                        .padding(.all, 7) // Horizontal padding inside the TextField
                        .frame(height: 45) // Set the height of the TextField
                        .background(Color(.systemGray6)) // Background color
                        .cornerRadius(8) // Rounded corners
                        .padding()
                    
                    Button(action: {
                        if city.isEmpty {
                            showAlert = true
                        } else {
                            weatherViewModel.weather = nil
                            showAlert = false
                            weatherViewModel.fetchWeather(for: city)
                            
                            
                        }
                    }) {
                        Text("Check Weather")
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
                    // Display weather information
                    HStack {
                        // City selection and icon
                        VStack(alignment: .leading) {
                            Text(weather.location.name + ", " + weather.location.region)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            Text(weather.current.condition.text)
                                .font(.title3)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        AsyncImage(url: URL(string: "https:\(weather.current.condition.icon)")) { image in
                            image.resizable()
                        } placeholder: {
                            Color.clear
                        }
                        .frame(width: 128, height: 128)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
                    .padding()
                    
                    Spacer()
                    VStack {
                        Text("\(String(format: "%.f", weather.current.tempC))°C")
                            .font(.system(size: 80))
                            .bold()
                            .foregroundColor(.white)
                        
                        HStack {
                            VStack {
                                Text("Humidity")
                                    .foregroundColor(.white)
                                Text("\(String(describing: weather.current.humidity)) %")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            VStack {
                                Text("Wind Speed")
                                    .foregroundColor(.white)
                                Text("\(String(describing: weather.current.windKph)) kph")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            VStack {
                                Text("Sunrise")
                                    .foregroundColor(.white)
                                Text(weather.forecast?.forecastday.first?.astro.sunrise ?? "")
                                    .foregroundColor(.yellow)
                            }
                            Spacer()
                            VStack {
                                Text("Sunset")
                                    .foregroundColor(.white)
                                Text(weather.forecast?.forecastday.first?.astro.sunset ?? "")
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if weatherViewModel.errorMessage != nil{
                    // Clear previous weather data and show error
                    Text("Something went wrong, Please try again")
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
                        title: Text("Error"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                } else{
                    return Alert(
                        title: Text("Error"),
                        message: Text("Please enter a city to check the weather."),
                        dismissButton: .default(Text("OK"))
                        
                    )
                }
            }
        }
    }
}
