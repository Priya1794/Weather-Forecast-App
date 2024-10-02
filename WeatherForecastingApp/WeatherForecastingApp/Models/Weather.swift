import Foundation

// MARK: - WeatherResponse
/// A struct representing the weather response from the API.
struct WeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
    let forecast:Forecast?
}

// MARK: - Location
/// A struct representing the location details.
struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
}

// MARK: - CurrentWeather
/// A struct representing the current weather conditions.
struct CurrentWeather: Codable {
    let tempC: Double  // Temperature in Celsius
    let tempF: Double  // Temperature in Fahrenheit
    let isDay: Int
    let condition: WeatherCondition
    let windMph: Double
    let windKph: Double
    let humidity: Int
    
    // MARK: CodingKeys
    /// Coding keys to map JSON keys to struct properties.
    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case tempF = "temp_f"
        case isDay = "is_day"
        case windMph = "wind_mph"
        case windKph = "wind_kph"
        case condition
        case humidity
    }
}

// MARK: - WeatherCondition
/// A struct representing the weather condition details.
struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int
}

// MARK: - Forecast
/// A struct representing the forecast data.
struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

// MARK: - ForecastDay
/// A struct representing a single day's forecast.
struct ForecastDay: Codable {
    let date: String
    let day: Day
    let astro: Astro
}

// MARK: - Day
/// A struct representing the weather data for a specific day.
struct Day: Codable {
    let maxTempC: Double
    let minTempC: Double
    let avgTempC: Double
    let maxWindMph: Double
    let maxWindKph: Double
    let condition: WeatherCondition

    // MARK: CodingKeys
    /// Coding keys to map JSON keys to struct properties.
    enum CodingKeys: String, CodingKey {
        case maxTempC = "maxtemp_c"
        case minTempC = "mintemp_c"
        case avgTempC = "avgtemp_c"
        case maxWindMph = "maxwind_mph"
        case maxWindKph = "maxwind_kph"
        case condition
    }
}

// MARK: - Astro
/// A struct representing astronomical data for the day.
struct Astro: Codable {
    let sunrise: String
    let sunset: String
}
