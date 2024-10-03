//
//  MockCoreDataService.swift
//  WeatherForecastingAppTests
//
//  Created by Priya Mehndiratta on 03/10/24.
//

import Foundation
@testable import WeatherForecastingApp

/// A mock implementation of the `CoreDataServiceProtocol` for testing purposes.
final class MockCoreDataService: CoreDataServiceProtocol {
    
    // MARK: - Properties
        
    /// The result to be returned by the fetchWeather method.
    var fetchWeatherResult: Result<WeatherResponse, Error>?
    /// Indicates whether the weather response is considered valid.
    var validationResult: Bool = true
    /// A flag to check if saveWeather was called.
    var saveWeatherCalled = false

    // MARK: - CoreDataServiceProtocol Methods

    /// Fetches weather data for a given city.
    /// - Parameters:
    ///   - city: The name of the city for which to fetch weather data.
    ///   - completion: A closure that is called with the result of the fetch operation.
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        if let result = fetchWeatherResult {
            completion(result)
        }
    }

    /// Validates the given weather response.
    /// - Parameter weather: The weather response to validate.
    /// - Returns: A Boolean indicating whether the response is valid.
    func validateWeatherResponse(_ weather: WeatherResponse) -> Bool {
        return validationResult
    }

    /// Saves the provided weather data for a given city.
    /// - Parameters:
    ///   - weather: The weather response to save.
    ///   - city: The name of the city for which to save the weather data.
    func saveWeather(_ weather: WeatherResponse, for city: String) {
        saveWeatherCalled = true
    }
}


