import Foundation

/// A service class responsible for fetching weather data from the API.
class WeatherService {
    
    // MARK: - Singleton Instance
    
    /// Singleton instance of `WeatherService` to ensure there's only one instance used throughout the app.
    static let shared = WeatherService()
    
    // MARK: - Properties
    
    /// API key for authenticating requests to the weather API.
    private let apiKey = "bbcc40f2edec42d18b793404243009"
    /// Number of forecast days to retrieve in the weather request.
    private let forecastDays = 5
    
    // MARK: - Initializer
    
    /// Private initializer to enforce the singleton pattern.
    private init() {}

    // MARK: - API Methods
    
    /// Fetches weather data from the API for a given city.
    /// - Parameters:
    ///   - city: The name of the city to fetch the weather for.
    ///   - completion: A closure that takes a `Result` with either a `WeatherResponse` or an `Error`.
    func fetchWeatherFromAPI(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        // Construct the API request URL with the city name and forecast days.
        let urlString = "http://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(city)&days=\(forecastDays)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        // Start a data task to fetch the weather data.
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            // Ensure we received data from the server.
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                // Attempt to decode the received JSON data into a WeatherResponse model.
                let decodedForecast = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(decodedForecast))
               
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}
