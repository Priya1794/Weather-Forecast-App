//
//  CoreDataServiceTests.swift
//  WeatherForecastingAppTests
//
//  Created by Priya Mehndiratta on 03/10/24.
//

import XCTest
import CoreData
@testable import WeatherForecastingApp

/// A test suite for the `CoreDataService` to validate its functionality.
class CoreDataServiceTests: XCTestCase {
    
    var coreDataService: CoreDataService!
    var mockContext: NSManagedObjectContext!
    
    // MARK: - Setup and Teardown
    override func setUp() {
        super.setUp()
        
        // Create an in-memory persistent store for testing
        let container = NSPersistentContainer(name: "WeatherForecastingApp")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { (_, error) in
            XCTAssertNil(error)
        }
        
        mockContext = container.viewContext
        coreDataService = CoreDataService(context: mockContext)
    }
    
    override func tearDown() {
        coreDataService = nil
        mockContext = nil
        super.tearDown()
    }
    
    // MARK: - Tests

    /// Tests fetching weather data for a specific city.
    func testFetchWeatherReturnsWeatherResponse() {
        // Arrange
        let weatherModel = WeatherModel(context: mockContext)
        weatherModel.city = "London"
        
        // Set up mock location
        let location = LocationModel(context: mockContext)
        location.name = "London"
        location.region = "England"
        location.country = "United Kingdom"
        location.lat = 51.5074
        location.long = -0.1278
        
        weatherModel.location = location
        
        // Set up mock current weather
        let currentWeather = CurrentWeatherModel(context: mockContext)
        currentWeather.tempC = 15.0
        currentWeather.tempF = 59.0
        currentWeather.isDay = 1
        currentWeather.humidity = 75
        currentWeather.windKph = 10.0
        currentWeather.windMph = 6.2
        
        // Set up mock weather condition
        let condition = WeatherConditionModel(context: mockContext)
        condition.text = "Partly Cloudy"
        condition.icon = "//cdn.weatherapi.com/weather/64x64/day/116.png"
        condition.code = 1003
        
        currentWeather.condition = condition
        weatherModel.current = currentWeather
        
        // Set up mock forecast
        let forecastEntity = ForecastModel(context: mockContext)
        let forecastDay = ForecastDayModel(context: mockContext)
        forecastDay.date = "2024-10-01"
        
        let day = DayModel(context: mockContext)
        day.maxTempC = 20.0
        day.minTempC = 10.0
        day.avgTempC = 15.0
        day.maxWindMph = 12.0
        day.maxWindKph = 19.0
        day.condition = condition // Reusing condition

        let astro = AstroModel(context: mockContext)
        astro.sunrise = "06:00"
        astro.sunset = "18:00"

        forecastDay.day = day
        forecastDay.astro = astro
        forecastEntity.addToForecastDays(forecastDay)
        weatherModel.forecast = forecastEntity
        
        // Save mock weather model
        try? mockContext.save()

        let expectation = self.expectation(description: "Fetch Weather")

        // Act
        coreDataService.fetchWeather(for: "London") { result in
            switch result {
            case .success(let weatherResponse):
                // Assert
                XCTAssertNotNil(weatherResponse)
                XCTAssertEqual(weatherResponse.location.name, "London")
                XCTAssertEqual(weatherResponse.location.region, "England")
                XCTAssertEqual(weatherResponse.location.country, "United Kingdom")
                XCTAssertEqual(weatherResponse.current.tempC, 15.0)
                XCTAssertEqual(weatherResponse.current.tempF, 59.0)
                XCTAssertEqual(weatherResponse.current.isDay, 1)
                XCTAssertEqual(weatherResponse.current.humidity, 75)
                XCTAssertEqual(weatherResponse.forecast?.forecastday.count, 1)
                
                // Assert forecast details
                let firstForecastDay = weatherResponse.forecast?.forecastday[0]
                XCTAssertEqual(firstForecastDay?.date, "2024-10-01")
                XCTAssertEqual(firstForecastDay?.day.maxTempC, 20.0)
                XCTAssertEqual(firstForecastDay?.day.minTempC, 10.0)
                XCTAssertEqual(firstForecastDay?.day.avgTempC, 15.0)
                XCTAssertEqual(firstForecastDay?.day.maxWindMph, 12.0)
                XCTAssertEqual(firstForecastDay?.day.maxWindKph, 19.0)
                XCTAssertEqual(firstForecastDay?.astro.sunrise, "06:00")
                XCTAssertEqual(firstForecastDay?.astro.sunset, "18:00")
                
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success but got error: \(error)")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    /// Tests if saving weather data correctly stores it in Core Data.
    func testSaveWeatherStoresDataInCoreData() {
        // Arrange
        let weatherResponse = WeatherResponse(
            location: Location(name: "London", region: "England", country: "UK", lat: 51.5074, lon: -0.1278),
            current: CurrentWeather(tempC: 20, tempF: 68, isDay: 1, condition: WeatherCondition(text: "Sunny", icon: "sunny.png", code: 1000),
            windMph: 10, windKph: 16, humidity: 50),
            forecast: Forecast(forecastday: [
                ForecastDay(date: "2024-10-01", day: Day(maxTempC: 22, minTempC: 15, avgTempC: 18, maxWindMph: 15, maxWindKph: 24, condition: WeatherCondition(text: "Sunny", icon: "sunny.png", code: 1000)),
                astro: Astro(sunrise: "06:00", sunset: "18:00"))
            ])
        )
        
        // Act
        coreDataService.saveWeather(weatherResponse, for: "London")
        
        // Assert
        let fetchRequest: NSFetchRequest<WeatherModel> = WeatherModel.fetchRequest()
        let results = try? mockContext.fetch(fetchRequest)
        
        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.city, "London")
    }
    
    /// Tests validation of a valid weather response.
    func testValidateWeatherResponseReturnsTrueForValidResponse() {
        // Arrange
        let validResponse = WeatherResponse(
            location: Location(name: "London", region: "England", country: "UK", lat: 51.5074, lon: -0.1278),
            current: CurrentWeather(tempC: 20, tempF: 68, isDay: 1, condition: WeatherCondition(text: "Sunny", icon: "sunny.png", code: 1000),
            windMph: 10, windKph: 16, humidity: 50),
            forecast: Forecast(forecastday: [
                ForecastDay(date: "2024-10-01", day: Day(maxTempC: 22, minTempC: 15, avgTempC: 18, maxWindMph: 15, maxWindKph: 24, condition: WeatherCondition(text: "Sunny", icon: "sunny.png", code: 1000)),
                astro: Astro(sunrise: "06:00", sunset: "18:00"))
            ])
        )
        
        // Act
        let isValid = coreDataService.validateWeatherResponse(validResponse)
        
        // Assert
        XCTAssertTrue(isValid)
    }
    
    /// Tests validation of an invalid weather response.
    func testValidateWeatherResponseReturnsFalseForInvalidResponse() {
        // Arrange
        let invalidResponse = WeatherResponse(
            location: Location(name: "", region: "", country: "UK", lat: 51.5074, lon: -0.1278),
            current: CurrentWeather(tempC: 0, tempF: 0, isDay: 1, condition: WeatherCondition(text: "", icon: "", code: 0),
            windMph: 10, windKph: 16, humidity: 50),
            forecast: Forecast(forecastday: [])
        )
        
        // Act
        let isValid = coreDataService.validateWeatherResponse(invalidResponse)
        
        // Assert
        XCTAssertFalse(isValid)
    }
}
