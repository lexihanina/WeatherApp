//
//  Helpers.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 20.10.22.
//

import Foundation

public enum DayTime {
    case day
    case night
}

public func getDayTimeFrom(sunset: Date, sunrise: Date) -> DayTime {
    let dayTime: DayTime
    let currentTime = Date()
    
    if !(currentTime < sunset && currentTime > sunrise) {
        dayTime = .night
    } else {
        dayTime = .day
    }
  
    return dayTime
}

public func getAnimationNameForWeather(conditionsID: Int) -> String {
    var jsonName: String
    
    switch conditionsID {
        case 200...202, 210...212, 221, 230...232:
            jsonName = "thunderstorm"
        case 313, 314, 321, 502...504, 520...522, 531:
            jsonName = "rainfall"
        case 300...302, 310...312, 500, 501:
            jsonName = "rain"
        case 511, 611, 612, 615, 616:
            jsonName = "snowandrain"
        case 600...602:
            jsonName = "snow"
        case 620...622:
            jsonName = "blizzard"
        case 711, 721, 741:
            jsonName = "fog"
        case 800:
            jsonName = "clear"
        case 801...803:
            jsonName = "cloudsandsun"
        case 701, 804:
            jsonName = "clouds"
        default:
            jsonName = "default"
    }
    
    return jsonName
}
