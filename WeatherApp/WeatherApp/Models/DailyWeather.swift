//
//  DailyWeather.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 07.12.2021.
//

import Foundation

struct DailyWeatherData: Codable {
    let daily: [DailyWeather]
    let lat: Float
    let lon: Float
    let timezone: String
    let timezone_offset: Int
}

struct DailyWeather: Codable {
    let dt: Double
    let sunrise: Int
    let sunset: Int
    let moonrise: Int
    let moonset: Int
    let moon_phase: Float
    let temp: Temp
    let feels_like: FeelsLike
    let pressure: Int
    let humidity: Int
    let dew_point: Double
    let wind_speed: Float
    let wind_deg: Int
    let wind_gust: Float
    let rain: Double?
    let weather: [WeatherArrayForDaily]
    let clouds: Int
    let pop: Float
    let uvi: Double
}

struct Temp: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct FeelsLike: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct WeatherArrayForDaily: Codable {
    let id: Int
    let description: String
    let icon: String
    let main: String
}
