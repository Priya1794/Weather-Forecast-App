import Foundation

class WeatherService {
    static let shared = WeatherService()
    private let apiKey = "bbcc40f2edec42d18b793404243009"
    private let forecastDays = 5
    
    private init() {}
    
    // Fetch 5-day weather forecast for a city
    func fetchForecast(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "http://api.weatherapi.com/v1/forecast.json?key=\(apiKey)&q=\(city)&days=\(forecastDays)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            print("response is \(String(describing: response))")
            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            do {
                let decodedForecast = try JSONDecoder().decode(WeatherResponse.self, from: data)
                completion(.success(decodedForecast))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
