//
//  MockWeatherService.swift
//  WeatherForecastingAppTests
//
//  Created by Priya Mehndiratta on 03/10/24.
//

import Foundation
@testable import WeatherForecastingApp

/// A mock implementation of the `WeatherServiceProtocol` for testing purposes.
final class MockWeatherService: WeatherServiceProtocol {
    // MARK: - Properties
        
    /// The result to be returned by the fetchWeatherFromAPI method.
    var fetchWeatherResult: Result<WeatherResponse, Error>?

    // MARK: - WeatherServiceProtocol Methods

    /// Fetches weather data from the API for a given city.
    /// - Parameters:
    ///   - city: The name of the city for which to fetch weather data.
    ///   - completion: A closure that is called with the result of the fetch operation.
    func fetchWeatherFromAPI(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        if let result = fetchWeatherResult {
            completion(result)
        }
    }
}
