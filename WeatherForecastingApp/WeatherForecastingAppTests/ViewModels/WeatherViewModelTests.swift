//
//  WeatherViewModelTests.swift
//  WeatherForecastingAppTests
//
//  Created by Priya Mehndiratta on 03/10/24.
//

import XCTest
@testable import WeatherForecastingApp

/// A test suite for the `WeatherViewModel to validate its functionality.
final class WeatherViewModelTests: XCTestCase {
    
    // MARK: - Properties
    var viewModel: WeatherViewModel!
    var mockCoreDataService: MockCoreDataService!
    var mockWeatherService: MockWeatherService!
    
    // MARK: - Lifecycle
    override func setUp() {
        super.setUp()
        // Initialize mocks and ViewModel
        mockCoreDataService = MockCoreDataService()
        mockWeatherService = MockWeatherService()
        viewModel = WeatherViewModel(coreDataService: mockCoreDataService, weatherService: mockWeatherService)
    }
    
    override func tearDown() {
        // Reset
        viewModel = nil
        mockCoreDataService = nil
        mockWeatherService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    /// Test that the ViewModel initializes correctly with its dependencies.
    func testViewModelInitialization() {
        // Test that the ViewModel initializes with the CoreDataService
        XCTAssertNotNil(viewModel)
        XCTAssertNotNil(viewModel.coreDataService)
        XCTAssertNotNil(viewModel.weatherService)
    }
    
    /// Test the successful fetch of weather data from Core Data.
    func testFetchWeatherFromCoreDataSuccess() {
        // Arrange: Create an expectation for the asynchronous operation
        let expectation = self.expectation(description: "Weather fetch from Core Data should succeed")
        
        // Mock success response from Core Data with proper structure
        let mockWeather = WeatherResponse(
            location: Location(name: "New York", region: "NY", country: "USA", lat: 40.7128, lon: -74.0060),
            current: CurrentWeather(
                tempC: 25.0,
                tempF: 77.0,
                isDay: 1,
                condition: WeatherCondition(text: "Sunny", icon: "//cdn.weatherapi.com/weather/64x64/day/113.png", code: 1000),
                windMph: 10.0,
                windKph: 16.1,
                humidity: 50
            ),
            forecast: nil
        )
        
        mockCoreDataService.fetchWeatherResult = .success(mockWeather)
        
        // Act: Fetch weather
        viewModel.fetchWeather(for: "New York")
        
        // Assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Small delay to allow async operation to complete
            XCTAssertEqual(self.viewModel.weather?.current.tempC, 25.0)
            XCTAssertNil(self.viewModel.errorMessage)
            expectation.fulfill()
        }
        
        // Wait for the async call to complete
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    /// Test the behavior when Core Data fetch fails and API fetch succeeds.
    func testFetchWeatherFromCoreDataFailureFetchFromAPISuccess() {
        
        // Arrange: Create an expectation for the asynchronous operation
        let expectation = self.expectation(description: "Weather fetch from API should succeed after Core Data failure")
        
        // Simulate Core Data failure
        mockCoreDataService.fetchWeatherResult = .failure(NSError(domain: "", code: 404, userInfo: nil))
        
        // Mock API Weather Response
        let mockAPIWeather = WeatherResponse(
            location: Location(name: "New York", region: "NY", country: "USA", lat: 40.7128, lon: -74.0060),
            current: CurrentWeather(
                tempC: 30.0,
                tempF: 86.0,
                isDay: 1,
                condition: WeatherCondition(text: "Cloudy", icon: "//cdn.weatherapi.com/weather/64x64/day/116.png", code: 1003),
                windMph: 5.0,
                windKph: 8.0,
                humidity: 60
            ),
            forecast: nil
        )
        
        mockWeatherService.fetchWeatherResult = .success(mockAPIWeather)
        
        // Act: Fetch weather
        viewModel.fetchWeather(for: "New York")
        
        // Assert: Wait for the asynchronous operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Ensure the weather is fetched from the API and saved to Core Data
            XCTAssertEqual(self.viewModel.weather?.current.tempC, 30.0)
            XCTAssertNil(self.viewModel.errorMessage)
            XCTAssertTrue(self.mockCoreDataService.saveWeatherCalled)
            
            // Fulfill the expectation
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled, with a timeout of 1 second
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    /// Test the behavior when both Core Data and API fetches fail.
    func testFetchWeatherFromCoreDataAndAPIFailure() {
        // Arrange: Create an expectation for the asynchronous operation
        let expectation = self.expectation(description: "Weather fetch should fail from both Core Data and API")
        // Simulate both Core Data and API failures
        mockCoreDataService.fetchWeatherResult = .failure(NSError(domain: "", code: 404, userInfo: nil))
        mockWeatherService.fetchWeatherResult = .failure(NSError(domain: "", code: 500, userInfo: nil))
        
        // Act: Fetch weather
        viewModel.fetchWeather(for: "New York")
        
        // Assert: Wait for the asynchronous operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Ensure no weather data is set and the correct error message is generated
            XCTAssertNil(self.viewModel.weather)
            XCTAssertEqual(self.viewModel.errorMessage, "Failed to fetch weather: The operation couldn’t be completed. ( error 500.)")
            
            // Fulfill the expectation
            expectation.fulfill()
        }
        
        // Wait for the expectation to be fulfilled, with a timeout of 1 second
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
}
