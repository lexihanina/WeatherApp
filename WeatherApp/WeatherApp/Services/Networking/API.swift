//
//  Networking.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 07.12.2021.
//

import Foundation

fileprivate let key = "cb4c5f3da87378859df2edd4271ea335"

enum API {
    case current
    case daily
    case hourly
    
    static var base: String {
        return "https://api.openweathermap.org/data/2.5"
    }
    
    static var oneCall: String {
        return "/onecall?"
    }
    
    static var weather: String {
        return "/weather?"
    }
    
    static var latAndLon: String {
        return "lat=\(LocationManager.shared.latitude)&lon=\(LocationManager.shared.longitude)"
    }
    
    static var units: String {
        return "&units=metric"
    }
    
    static var apiKey: String {
        return "&appid=\(key)"
    }
    
    var exclude: String {
        switch self {
        case .current:
            return "&exclude=minutely,hourly,daily,alerts"
        case .daily:
            return "&exclude=current,minutely,hourly,alerts"
        case .hourly:
            return "&exclude=current,minutely,daily,alerts"
        }
    }
}
