import Foundation

/// ViewModel responsible for fetching and managing weather data.
/// Fetches weather from Core Data or API based on availability and stores the result in Core Data.
class WeatherViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Published property to hold the fetched weather data, updates the UI when changed.
    @Published var weather: WeatherResponse?
    /// Published property to hold an error message in case of failure, updates the UI when set.
    @Published var errorMessage: String?
    
    // MARK: - CoreData Service
    
    /// A reference to the CoreDataService/WeatherServiceProtocol protocol for accessing and saving weather data in Core Data.
    var coreDataService: CoreDataServiceProtocol
    var weatherService: WeatherServiceProtocol
    
    // MARK: - Initializer
    
    /// Initializes the ViewModel with a CoreData service.
    /// - Parameter coreDataService: A protocol for fetching/saving weather data in Core Data, defaults to CoreDataService.
    ///             weatherService:A protocol for fetching/saving weather data from API
    init(coreDataService: CoreDataServiceProtocol, weatherService: WeatherServiceProtocol) {
        self.coreDataService = coreDataService
        self.weatherService = weatherService
    }
    
    // MARK: - Weather Fetching Methods
    
    /// Fetches the weather data for a specified city.
    /// First tries to fetch from Core Data, if not found, fetches from API.
    /// - Parameter city: The name of the city for which to fetch the weather.
    func fetchWeather(for city: String) {
        // Fetch weather from Core Data
        coreDataService.fetchWeather(for: city) { [weak self] result in
            switch result {
            case .success(let cachedWeather):
                // Successfully fetched from Core Data, update the weather and reset the error
                DispatchQueue.main.async {
                    self?.weather = cachedWeather
                    self?.errorMessage = nil
                }
            case .failure:
                // Failed to fetch from Core Data, proceed to fetch from API
                self?.fetchWeatherIfNotFoundFromCoreData(for: city)
            }
        }
    }
    
    /// Fetches weather data from the API if it's not available in Core Data.
    /// Saves the result to Core Data upon a successful API response.
    /// - Parameter city: The name of the city for which to fetch the weather.
    func fetchWeatherIfNotFoundFromCoreData(for city: String){
        
        self.weatherService.fetchWeatherFromAPI(for: city) { result in
            switch result {
            case .success(let weatherResponse):
                // Successfully fetched from API, update the weather and save it to Core Data
                DispatchQueue.main.async {
                self.weather = weatherResponse
                if let weather = self.weather{
                        if self.coreDataService.validateWeatherResponse(weather) {
                            self.weather = weatherResponse
                            self.errorMessage = nil
                            self.coreDataService.saveWeather(weather, for: city)
                        } else {
                            self.weather = nil
                            self.errorMessage = AlertMessages.invalidWeatherResponse.description
                        }
                    }
                }
               
            case .failure(let error):
                // Failed to fetch from API, set the error message with details
                DispatchQueue.main.async {
                    self.weather = nil
                    self.errorMessage = "\(AlertMessages.failedToFetchWeather.description)  \(error.localizedDescription)"
                }
            }
        }
    }
}
