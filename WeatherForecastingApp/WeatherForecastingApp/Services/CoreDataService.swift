//
//  CoreDataService.swift
//  WeatherForecastingApp
//
//  Created by Priya Mehndiratta on 01/10/24.
//


import Foundation
import CoreData

// MARK: - CoreDataServiceProtocol
/// A protocol that defines methods for fetching and saving weather data to Core Data.
protocol CoreDataServiceProtocol {
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
    func saveWeather(_ weatherResponse: WeatherResponse, for city: String)
    func validateWeatherResponse(_ weatherResponse: WeatherResponse)-> Bool
}

// MARK: - CoreDataService
/// CoreDataService class handles saving and retrieving weather data from Core Data.
class CoreDataService: CoreDataServiceProtocol {
    
    // MARK: - Properties
    
    /// The Core Data context from the shared Persistence Controller.
    private let context = PersistenceController.shared.container.viewContext
    
    // MARK: - Fetch Weather Methods
    
    /// Fetches weather data for a specific city from Core Data.
    /// - Parameters:
    ///   - city: The name of the city to fetch weather data for.
    ///   - completion: A closure that returns a Result with either the WeatherResponse or an Error.
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        self.fetchCoreDataWeather(for: city) { result in
            switch result {
            case .success(let weatherResponse):
                completion(.success(weatherResponse))
            case .failure(let error):
                // Handle the error case
                completion(.failure(error))
                
            }
        }
    }
    
    /// Helper function that handles the actual fetching logic from Core Data.
    /// - Parameters:
    ///   - city: The name of the city to fetch weather data for.
    ///   - completion: A closure that returns a Result with either the WeatherResponse or an Error.
    private func fetchCoreDataWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        // First, attempt to fetch from Core Data
        let fetchRequest: NSFetchRequest<WeatherModel> = WeatherModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "city ==[c] %@", city) 
        
        do {
            let results = try context.fetch(fetchRequest)
            
            guard let weatherCache = results.first else{
                return
            }
            
            let location = mapLocation(from: weatherCache)
            let current = mapCurrentWeather(from: weatherCache)
            let forecast = mapForecast(from: weatherCache)
            
            let weatherResponse = WeatherResponse(location: location, current: current, forecast: forecast)
            completion(.success(weatherResponse))
            
            return
        } catch {
            completion(.failure(error))
            return
        }
    }
    
    // MARK: - Mapping Core Data Models to Weather Models
    
    /// Maps the LocationModel from Core Data to the Location struct.
    /// - Parameter weatherCache: The cached WeatherModel from Core Data.
    /// - Returns: The corresponding Location model.
    private func mapLocation(from weatherCache: WeatherModel) -> Location {
        return Location(
            name: weatherCache.location?.name ?? "",
            region: weatherCache.location?.region ?? "",
            country: weatherCache.location?.country ?? "",
            lat: weatherCache.location?.lat ?? 0,
            lon: weatherCache.location?.long ?? 0
        )
    }
    
    /// Maps the CurrentWeatherModel from Core Data to the CurrentWeather struct.
    /// - Parameter weatherCache: The cached WeatherModel from Core Data.
    /// - Returns: The corresponding CurrentWeather model.
    private func mapCurrentWeather(from weatherCache: WeatherModel) -> CurrentWeather {
        return CurrentWeather(
            tempC: weatherCache.current?.tempC ?? 0,
            tempF: weatherCache.current?.tempF ?? 0,
            isDay: Int(weatherCache.current?.isDay ?? 0),
            condition: WeatherCondition(
                text: weatherCache.current?.condition?.text ?? "",
                icon: weatherCache.current?.condition?.icon ?? "",
                code: Int(weatherCache.current?.condition?.code ?? 0)
            ),
            windMph: weatherCache.current?.windMph ?? 0,
            windKph: weatherCache.current?.windKph ?? 0,
            humidity: Int(weatherCache.current?.humidity ?? 0)
        )
    }
    
    /// Maps the ForecastModel from Core Data to the Forecast struct.
    /// - Parameter weatherCache: The cached WeatherModel from Core Data.
    /// - Returns: The corresponding Forecast model with a list of forecast days.
    private func mapForecast(from weatherCache: WeatherModel) -> Forecast {
        var forecastDays: [ForecastDay] = []

        if let forecastEntity = weatherCache.forecast,
           let forecastDaysEntities = forecastEntity.forecastDays?.allObjects as? [ForecastDayModel] {
            // Sort forecastDaysEntities based on a date property (replace 'date' with the actual property name)
            let sortedForecastDaysEntities = forecastDaysEntities.sorted {
                // Assuming ForecastDayModel has a date property of type Date
                guard let firstDate = $0.date, let secondDate = $1.date else { return false }
                return firstDate < secondDate
            }
            
            // Map the sorted entities to ForecastDay
            forecastDays = sortedForecastDaysEntities.map { mapForecastDay(from: $0) }
            
        }

        return Forecast(forecastday: forecastDays)
    }
    
    /// Maps the ForecastDayModel from Core Data to the ForecastDay struct.
    /// - Parameter forecastDayEntity: The cached ForecastDayModel from Core Data.
    /// - Returns: The corresponding ForecastDay model.
    private func mapForecastDay(from forecastDayEntity: ForecastDayModel) -> ForecastDay {
        let day = Day(
            maxTempC: forecastDayEntity.day?.maxTempC ?? 0,
            minTempC: forecastDayEntity.day?.minTempC ?? 0,
            avgTempC: forecastDayEntity.day?.avgTempC ?? 0,
            maxWindMph: forecastDayEntity.day?.maxWindMph ?? 0,
            maxWindKph: forecastDayEntity.day?.maxWindKph ?? 0,
            condition: WeatherCondition(
                text: forecastDayEntity.day?.condition?.text ?? "",
                icon: forecastDayEntity.day?.condition?.icon ?? "",
                code: Int(forecastDayEntity.day?.condition?.code ?? 0)
            )
        )
        
        let astro = Astro(
            sunrise: forecastDayEntity.astro?.sunrise ?? "",
            sunset: forecastDayEntity.astro?.sunset ?? ""
        )
        
        return ForecastDay(date: forecastDayEntity.date ?? "", day: day, astro: astro)
    }
    
    // MARK: - Save Weather Method
    
    /// Saves the weather data for a specific city to Core Data.
    /// - Parameters:
    ///   - weatherResponse: The weather data to be saved.
    ///   - city: The city name associated with the weather data.
    func saveWeather(_ weatherResponse: WeatherResponse, for city: String) {
        
        let locationEntity = createLocationEntity(from: weatherResponse.location)
        let currentWeatherEntity = createCurrentWeatherEntity(from: weatherResponse.current)
        let forecastEntity = createForecastEntity(from: weatherResponse.forecast)
        
        guard let foreCastEntity = forecastEntity else{
            print("Error in saving core data weather data")
            return
        }
        
        let weatherEntity = WeatherModel(context: context)
        weatherEntity.current = currentWeatherEntity
        weatherEntity.location = locationEntity
        weatherEntity.forecast = foreCastEntity
        weatherEntity.city = city
    
        saveContext()
    }
    
    /// Creates a LocationModel from the Location struct to save in Core Data.
    /// - Parameter location: The location data to be saved.
    /// - Returns: The corresponding LocationModel.
    private func createLocationEntity(from location: Location) -> LocationModel {
        let locationEntity = LocationModel(context: context)
        locationEntity.name = location.name
        locationEntity.region = location.region
        locationEntity.country = location.country
        locationEntity.lat = location.lat
        locationEntity.long = location.lon
        return locationEntity
    }
    
    /// Creates a CurrentWeatherModel from the CurrentWeather struct to save in Core Data.
    /// - Parameter current: current weather data to be saved.
    /// - Returns: The corresponding CurrentWeatherModel.
    private func createCurrentWeatherEntity(from current: CurrentWeather) -> CurrentWeatherModel {
        let currentWeatherEntity = CurrentWeatherModel(context: context)
        currentWeatherEntity.tempC = current.tempC
        currentWeatherEntity.tempF = current.tempF
        currentWeatherEntity.isDay = Int16(current.isDay)
        currentWeatherEntity.humidity = Int16(current.humidity)
        currentWeatherEntity.windKph = current.windKph
        currentWeatherEntity.windMph = current.windMph
        currentWeatherEntity.condition = createWeatherConditionEntity(from: current.condition)
        return currentWeatherEntity
    }

    /// Creates a WeatherConditionModel from the WeatherCondition struct to save in Core Data.
    /// - Parameter current: condition data to be saved.
    /// - Returns: The corresponding WeatherConditionModel.
    private func createWeatherConditionEntity(from condition: WeatherCondition) -> WeatherConditionModel {
        let conditionEntity = WeatherConditionModel(context: context)
        conditionEntity.text = condition.text
        conditionEntity.icon = condition.icon
        conditionEntity.code = Int16(condition.code)
        return conditionEntity
    }
    
    /// Creates a ForecastModel from the Forecast struct to save in Core Data.
    /// - Parameter current: forecast data to be saved.
    /// - Returns: The corresponding ForecastModel
    private func createForecastEntity(from forecast: Forecast?) -> ForecastModel? {
        let forecastEntity = ForecastModel(context: context)
        
        guard let weatherForecast = forecast,weatherForecast.forecastday.count > 0 else{
            print("Error in saving forecast data")
            return nil
        }
        
        forecast?.forecastday.forEach { forecastDay in
            let forecastDayEntity = ForecastDayModel(context: context)
            forecastDayEntity.date = forecastDay.date
            forecastDayEntity.day = createDayEntity(from: forecastDay.day)
            forecastDayEntity.astro = createAstroEntity(from: forecastDay.astro)
            forecastEntity.addToForecastDays(forecastDayEntity)
        }
        
        return forecastEntity
    }
    
    /// Creates a DayModel from the Day struct to save in Core Data.
    /// - Parameter day: forecast data to be saved.
    /// - Returns: The corresponding DayModel
    private func createDayEntity(from day: Day) -> DayModel {
        let dayEntity = DayModel(context: context)
        dayEntity.maxTempC = day.maxTempC
        dayEntity.minTempC = day.minTempC
        dayEntity.avgTempC = day.avgTempC
        dayEntity.maxWindMph = day.maxWindMph
        dayEntity.maxWindKph = day.maxWindKph
        dayEntity.condition = createWeatherConditionEntity(from: day.condition)
        return dayEntity
    }
    
    /// Creates a AstroModel from the Astro struct to save in Core Data.
    /// - Parameter astro: forecast data to be saved.
    /// - Returns: The corresponding AstroModel
    private func createAstroEntity(from astro: Astro) -> AstroModel {
        let astroEntity = AstroModel(context: context)
        astroEntity.sunrise = astro.sunrise
        astroEntity.sunset = astro.sunset
        return astroEntity
    }

    // MARK: - Save Context
    
    /// Saves the Core Data context and handles any errors.
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("Failed to save weather response: \(error)")
        }
    }
    
    /// Validate wetaher repoonse before saving in core data
    /// - Parameter weatherResponse: weather response to be validated
    /// - Returns: Bool value
    func validateWeatherResponse(_ weatherResponse: WeatherResponse) -> Bool {
        // Check if the location is valid
        let location = weatherResponse.location
        
        // Validate location fields
        guard !location.name.isEmpty,
              !location.region.isEmpty,
              !location.country.isEmpty else {
            print("Location fields are empty.")
            return false
        }
        
        // Check if the current weather is valid
        let currentWeather = weatherResponse.current
        
        // Validate current weather fields
        guard currentWeather.tempC != 0 || currentWeather.tempF != 0 else {
            print("Temperature values are invalid.")
            return false
        }
        
        // Check if the forecast is valid
        guard let forecast = weatherResponse.forecast else {
            print("Forecast data is nil.")
            return false
        }
        
        // Validate forecast fields
        guard !forecast.forecastday.isEmpty else {
            print("Forecast days are empty.")
            return false
        }
        
        // Additional checks on the day structure
        for day in forecast.forecastday {
            guard !day.date.isEmpty else {
                print("Forecast day date is empty.")
                return false
            }
            
            // Validate day temperatures
            guard day.day.maxTempC >= day.day.minTempC else {
                print("Max temperature cannot be less than min temperature for date: \(day.date)")
                return false
            }
            
            guard day.day.avgTempC >= day.day.minTempC && day.day.avgTempC <= day.day.maxTempC else {
                print("Avg temperature is out of range for date: \(day.date)")
                return false
            }
            
            // Validate wind conditions
            guard day.day.maxWindMph >= 0 && day.day.maxWindKph >= 0 else {
                print("Invalid wind speed for date: \(day.date)")
                return false
            }
            
            // Validate weather condition
            let condition = day.day.condition
            
            guard !condition.text.isEmpty, !condition.icon.isEmpty else {
                print("Weather condition properties are empty for date: \(day.date)")
                return false
            }
            
            guard condition.code >= 0 else {
                print("Invalid weather condition code for date: \(day.date)")
                return false
            }
            
            // Validate astro data
            let astro = day.astro
            guard !astro.sunrise.isEmpty, !astro.sunset.isEmpty else {
                print("Astro properties are empty for date: \(day.date)")
                return false
            }
            
        }
        
        // All checks passed
        return true
    }

}
