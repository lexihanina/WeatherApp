//
//  CurrentWeather.swift.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 07.12.2021.
//

import Foundation

struct CurrentWeatherData: Codable {
    let coord: Coord
    let weather: [WeatherArray]
    let base: String
    let main: Main
    let visibility: Int
    let wind: Wind
    let clouds: [String : Int]?
    let rain: [String : Double]?
    let snow: [String : Double]?
    let dt: Int
    let sys: Sys
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct Coord: Codable {
    let lon: Float
    let lat: Float
}

struct WeatherArray: Codable {
    let id: Int
    let description: String
    let icon: String
    let main: String
}

struct Main: Codable {
    let temp: Double
    let feels_like: Double
    let temp_min: Double
    let temp_max: Double
    let pressure: Int
    let humidity: Int
}

struct Wind: Codable {
    let speed: Float
    let deg: Int
    let gust: Float?
}

struct Sys: Codable {
    let type: Int?
    let id: Int?
    let country: String
    let sunrise: Int
    let sunset: Int
}
