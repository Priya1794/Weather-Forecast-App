//
//  CoreDataService.swift
//  WeatherForecastingApp
//
//  Created by Priya Mehndiratta on 01/10/24.
//


import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
    func saveWeather(_ weatherResponse: WeatherResponse, for city: String)
}

class CoreDataService: CoreDataServiceProtocol {
    
    private let context = PersistenceController.shared.container.viewContext
    
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        self.fetchCoreDataWeather(for: city) { result in
            print (" results are ", result)
            switch result {
            case .success(let weatherResponse):
                completion(.success(weatherResponse))
            case .failure(let error):
                // Handle the error case
                completion(.failure(error))
                
            }
        }
    }
    
    private func fetchCoreDataWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        // First, attempt to fetch from Core Data
        let fetchRequest: NSFetchRequest<WeatherModel> = WeatherModel.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "city == %@", city)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            // If cached data exists, map it to WeatherResponse
            if let weatherCache = results.first {
                print(results)
                //                let cachedWeather = WeatherResponse(
                let location =  Location(
                    name: weatherCache.location?.name ?? "",
                    region: weatherCache.location?.region ?? "",
                    country: weatherCache.location?.country ?? "",
                    lat: weatherCache.location?.lat ?? 0,
                    lon: weatherCache.location?.long ?? 0
                )
                
                let current =  CurrentWeather(
                    tempC: weatherCache.current!.tempC,
                    tempF: weatherCache.current!.tempF,
                    isDay: Int(weatherCache.current!.isDay),
                    condition: WeatherCondition(
                        text: (weatherCache.current?.condition?.text)!,
                        icon: (weatherCache.current!.condition?.icon!)!,
                        code: Int((weatherCache.current?.condition?.code)!)
                    ),
                    windMph: weatherCache.current!.windMph,
                    windKph: weatherCache.current!.windKph,
                    humidity: Int(weatherCache.current!.humidity)
                )
                
                // Fetch and map the forecast data
                var forecastDays: [ForecastDay] = []
                if let forecastEntity = weatherCache.forecast {
                    let forecastDaysEntities = forecastEntity.forecastDays?.allObjects as? [ForecastDayModel]
                    
                    for forecastDayEntity in forecastDaysEntities ?? [] {
                        
                        // Map DayModel
                        let day = Day(
                            maxTempC: forecastDayEntity.day?.maxTempC ?? 0,
                            minTempC: forecastDayEntity.day?.minTempC ?? 0,
                            avgTempC: forecastDayEntity.day?.avgTempC ?? 0,
                            maxWindMph: forecastDayEntity.day?.maxWindMph ?? 0,
                            maxWindKph: forecastDayEntity.day?.maxWindKph ?? 0,
                            condition: WeatherCondition(
                                text: (forecastDayEntity.day?.condition?.text)!,
                                icon: (forecastDayEntity.day?.condition?.icon!)!,
                                code: Int((forecastDayEntity.day?.condition?.code)!)
                            )
                        )
                        
                        // Map AstroModel
                        let astro = Astro(
                            sunrise: forecastDayEntity.astro?.sunrise ?? "",
                            sunset: forecastDayEntity.astro?.sunset ?? ""
                        )
                        
                        // Map ForecastDay
                        let forecastDay = ForecastDay(
                            date: forecastDayEntity.date ?? "",
                            day: day,
                            astro: astro
                        )
                        
                        forecastDays.append(forecastDay)
                    }
                }
                
                // Create the Forecast object
                let forecast = Forecast(forecastday: forecastDays)
                
                let weatherResposnse = WeatherResponse(location: location, current: current, forecast: forecast)
                //                )
                completion(.success(weatherResposnse))
                return
            } 
            
        } catch {
            completion(.failure(error))
            return
        }
    }
    
    func saveWeather(_ weatherResponse: WeatherResponse, for city: String) {
        
        // Create a Location object
        let locationEntity = LocationModel(context: context)
        locationEntity.name = weatherResponse.location.name
        locationEntity.region = weatherResponse.location.region
        locationEntity.country = weatherResponse.location.country
        locationEntity.lat = weatherResponse.location.lat
        locationEntity.long = weatherResponse.location.lon
        
        
        // Create CurrentWeather object
        let currentWeatherEntity = CurrentWeatherModel(context: context)
        currentWeatherEntity.tempC = weatherResponse.current.tempC
        currentWeatherEntity.tempF = weatherResponse.current.tempF
        currentWeatherEntity.isDay = Int16(weatherResponse.current.isDay)
        currentWeatherEntity.humidity = Int16(weatherResponse.current.humidity)
        currentWeatherEntity.windKph = Double(Int16(weatherResponse.current.windKph))
        
        // Create WeatherCondition object
        let weatherConditionEntity = WeatherConditionModel(context: context)
        weatherConditionEntity.text = weatherResponse.current.condition.text
        weatherConditionEntity.icon = weatherResponse.current.condition.icon
        weatherConditionEntity.code = Int16(weatherResponse.current.condition.code)
        
        // Assign the WeatherCondition to CurrentWeather
        currentWeatherEntity.condition = weatherConditionEntity
        
        // Create Forecast object
        let forecastEntity = ForecastModel(context: context)
        
        // Loop through forecast days
        if let forecastDays = weatherResponse.forecast?.forecastday {
            for forecastDay in forecastDays {
                let forecastDayEntity = ForecastDayModel(context: context)
                forecastDayEntity.date = forecastDay.date
                
                let weatherConditionEntity = WeatherConditionModel(context: context)
                weatherConditionEntity.text = forecastDay.day.condition.text
                weatherConditionEntity.icon = forecastDay.day.condition.icon
                weatherConditionEntity.code = Int16(forecastDay.day.condition.code)
                
                // Create Day object
                let dayEntity = DayModel(context: context)
                dayEntity.maxTempC = forecastDay.day.maxTempC
                dayEntity.minTempC = forecastDay.day.minTempC
                dayEntity.avgTempC = forecastDay.day.avgTempC
                dayEntity.maxWindMph = forecastDay.day.maxWindMph
                dayEntity.maxWindKph = forecastDay.day.maxWindKph
                dayEntity.condition = weatherConditionEntity
                
                // Create Astro object
                let astroEntity = AstroModel(context: context)
                astroEntity.sunrise = forecastDay.astro.sunrise
                astroEntity.sunset = forecastDay.astro.sunset
                
                // Assign relationships
                forecastDayEntity.day = dayEntity
                forecastDayEntity.astro = astroEntity
                
                // Add forecast day to forecast
                forecastEntity.addToForecastDays(forecastDayEntity)
            }
            
            let weatherEntity = WeatherModel(context: context)
            weatherEntity.current = currentWeatherEntity
            weatherEntity.location = locationEntity
            weatherEntity.forecast = forecastEntity
            weatherEntity.city = city
        }
        
        // Save context
        do {
            try context.save()
        } catch {
            print("Failed to save weather response: \(error)")
        }
    }
    
}
