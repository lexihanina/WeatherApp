//
//  RequestBuilder.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 07.12.2021.
//

import Foundation

protocol Builder {
    func base() -> WeatherRequest
    func oneCall() -> WeatherRequest
    func weather() -> WeatherRequest
    func latAndLon() -> WeatherRequest
    func excludeCurrent() -> WeatherRequest
    func excludeHourly() -> WeatherRequest
    func excludeDaily() -> WeatherRequest
    func units() -> WeatherRequest
    func apiKey() -> WeatherRequest
    func build() -> WeatherRequest
}

class WeatherRequest : Builder {
    public var buildedUrl: String = ""
    
    func base() -> WeatherRequest {
        buildedUrl += API.base
        return self
    }
    
    func oneCall() -> WeatherRequest {
        buildedUrl += API.oneCall
        return self
    }
    
    func weather() -> WeatherRequest {
        buildedUrl += API.weather
        return self
    }
    
    func latAndLon() -> WeatherRequest {
        buildedUrl += API.latAndLon
        return self
    }
    
    func excludeCurrent() -> WeatherRequest {
        buildedUrl += API.current.exclude
        return self
    }
    
    func excludeHourly() -> WeatherRequest {
        buildedUrl += API.hourly.exclude
        return self
    }
    
    func excludeDaily() -> WeatherRequest {
        buildedUrl += API.daily.exclude
        return self
    }
    
    func units() -> WeatherRequest {
        buildedUrl += API.units
        return self
    }
    
    func apiKey() -> WeatherRequest {
        buildedUrl += API.apiKey
        return self
    }
    
    func build() -> WeatherRequest {
        return self
    }
}
