//
//  Constants.swift
//  WeatherForecastingApp
//
//  Created by Priya Mehndiratta on 03/10/24.
//

import UIKit

// MARK: - Alert Messages

/// Enum for handling alert messages throughout the app.
enum AlertMessages: CustomStringConvertible {
    case invalidWeatherResponse
    case defaultAlert
    case enterCityToCheckWeather
    case errorSavingCoreData
    case failedToFetchWeather
    var description: String
    {
        switch self
        {
        case .invalidWeatherResponse:          
            return "Invalid weather response: Failed to cache weather"
        case .defaultAlert:                    
            return "Something went wrong, Please try again later."
        case .enterCityToCheckWeather:
            return "Please enter a city to check the weather."
        case .errorSavingCoreData:
            return "Error in saving core data weather data"
        case .failedToFetchWeather:
            return "Failed to fetch weather:"
        }
    }
}

// MARK: - Text Messages

/// Enum for handling specific text messages displayed in the app.
enum TextMesages: CustomStringConvertible {
    case thisWeek
    case noForecastYet
    case enterCityToCheckForecast
    var description: String
    {
        switch self
        {
        case .thisWeek:
            return "This Week"
        case .noForecastYet:
            return "No Forecast yet"
        case .enterCityToCheckForecast:
            return "Please enter city to check this week's forecast"
        }
    }
}

// MARK: - String Constants

/// Struct containing static string constants used throughout the app.
struct StringConstants {
    static let sunrise = "Sunrise"
    static let sunset = "Sunset"
    static let humidity = "Humidity"
    static let windSpeed = "Wind Speed(kph)"
    static let error = "Error"
    static let ok = "OK"
    static let enterCityName = "Enter city name"
    static let checkWeather = "Check Weather"
    static let currentWeather = "Current Weather"
    static let fiveDayForcast = "5-Day Forecast"
}

// MARK: - Service Constants

/// Struct containing constant values related to the weather API service.
/// Centralizes API endpoint information for easier management
struct ServiceConstants {
    static let WEATHER_API = "http://api.weatherapi.com/v1/forecast.json"
    
}

