import Foundation
import CoreData
import Combine

class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()
    
    private let coreDataService: CoreDataServiceProtocol
    
    init(coreDataService: CoreDataServiceProtocol = CoreDataService()) {
        self.coreDataService = coreDataService
    }
    
    func fetchWeather(for city: String) {
        
        coreDataService.fetchWeather(for: city) { [weak self] result in
            switch result {
            case .success(let cachedWeather):
                self?.weather = cachedWeather
                self?.errorMessage = nil
            case .failure:
                self?.weather = nil
                self?.errorMessage = "Failed to fetch weather"
            }
        }
        
        if (self.weather == nil){
            self.fetchWeatherIfNotFoundFromCoreData(for: city)
        }
    }
    
    func fetchWeatherIfNotFoundFromCoreData(for city: String){
        
        WeatherService.shared.fetchWeatherFromAPI(for: city) { result in
            print (" results are ", result)
            switch result {
            case .success(let weatherResponse):
                // Assign the weather response if the fetch was successful
                self.weather = weatherResponse
                if let weather = self.weather{
                    self.coreDataService.saveWeather(weather, for: city)
                }
                self.errorMessage = nil
            case .failure(let error):
                // Handle the error case
                self.weather = nil
                self.errorMessage = "Failed to fetch weather: \(error.localizedDescription)"
            }
        }
    }
}
