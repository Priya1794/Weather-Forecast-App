import Foundation

// MARK: - WeatherResponse
struct WeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
    let forecast:Forecast?
}

// MARK: - Location
struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
}

// MARK: - CurrentWeather
struct CurrentWeather: Codable {
    let tempC: Double  // Temperature in Celsius
    let tempF: Double  // Temperature in Fahrenheit
    let isDay: Int
    let condition: WeatherCondition
    let windMph: Double
    let windKph: Double
    let humidity: Int
    
    // Coding keys to map JSON keys to properties
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
struct WeatherCondition: Codable {
    let text: String
    let icon: String
    let code: Int
}

// MARK: - Forecast
struct Forecast: Codable {
    let forecastday: [ForecastDay]
}

// MARK: - ForecastDay
struct ForecastDay: Codable {
    let date: String
    let day: Day
    let astro: Astro
}

// MARK: - Day
struct Day: Codable {
    let maxTempC: Double
    let minTempC: Double
    let avgTempC: Double
    let maxWindMph: Double
    let maxWindKph: Double
    let condition: WeatherCondition

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
struct Astro: Codable {
    let sunrise: String
    let sunset: String
}
