//
//  HourlyWeather.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 07.12.2021.
//

import Foundation

struct HourlyWeatherData: Codable {
        let hourly: [HourlyWeather]
        let lat: Float
        let lon: Float
        let timezone: String
        let timezone_offset: Int
    }

    struct HourlyWeather: Codable {
        let dt: Double
        let temp: Double
        let feels_like: Double
        let pressure: Int
        let humidity: Int
        let dew_point: Double
        let visibility: Int
        let wind_speed: Float
        let wind_deg: Int
        let wind_gust: Float
        let rain: [String: Double]?
        let weather: [WeatherArrayForHourly]
        let clouds: Int
        let pop: Float
        let uvi: Double
    }

    struct WeatherArrayForHourly: Codable {
        let id: Int
        let description: String
        let icon: String
        let main: String
    }
