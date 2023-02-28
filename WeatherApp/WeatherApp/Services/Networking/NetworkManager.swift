//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 07.12.2021.
//

import Foundation
import CoreLocation

class NetworkManager {
    static private let instance = NetworkManager()
    var networkFaild: Bool = false

    static var shared: NetworkManager {
        return instance
    }
    
    private init() {}
    
    func downloadCurrentWeatherData(onSuccess: @escaping(CurrentWeatherData) -> Void,
                                    onError: @escaping(String) -> Void)  {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let urlBuilder = WeatherRequest()
            .base()
            .weather()
            .latAndLon()
            .units()
            .apiKey()
            .build()
        
        guard let url = URL(string: urlBuilder.buildedUrl) else {
            networkFaild = true
            
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                self.networkFaild = true
                onError(error.localizedDescription)
                
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                self.networkFaild = true
                onError("Invalid data or response")
                
                return
            }
            
            do {
                if response.statusCode == 200 {
                    let item = try decoder.decode(CurrentWeatherData.self, from: data)
                    onSuccess(item)
                } else {
                    self.networkFaild = true
                    onError("Response wasn't 200. It was: \(response.statusCode)")
                }
            } catch {
                self.networkFaild = true
                onError(error.localizedDescription)
            }
        }.resume()
    }
    
    func downloadDailyWeatherData(onSuccess: @escaping(DailyWeatherData) -> Void,
                                  onError: @escaping(String) -> Void)  {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let urlBuilder = WeatherRequest()
            .base()
            .oneCall()
            .latAndLon()
            .excludeDaily()
            .units()
            .apiKey()
            .build()

        guard let url = URL(string: urlBuilder.buildedUrl) else {
            networkFaild = true
            
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                self.networkFaild = true
                onError(error.localizedDescription)
                
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                self.networkFaild = true
                onError("Invalid data or response")
                
                return
            }
            
            do {
                if response.statusCode == 200 {
                    let item = try decoder.decode(DailyWeatherData.self, from: data)
                    onSuccess(item)
                } else {
                    self.networkFaild = true
                    onError("Response wasn't 200. It was: \(response.statusCode)")
                }
            } catch {
                self.networkFaild = true
               onError(error.localizedDescription)
            }
        }.resume()
    }
    
    func downloadHourlyWeatherData(onSuccess: @escaping(HourlyWeatherData) -> Void,
                                   onError: @escaping(String) -> Void)  {
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let urlBuilder = WeatherRequest()
            .base()
            .oneCall()
            .latAndLon()
            .excludeHourly()
            .units()
            .apiKey()
            .build()

        guard let url = URL(string: urlBuilder.buildedUrl) else {
            networkFaild = true
            
            return
        }
        
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                onError(error.localizedDescription)
                self.networkFaild = true
                
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                onError("Invalid data or response")
                self.networkFaild = true
                
                return
            }
            
            do {
                if response.statusCode == 200 {
                    let item = try decoder.decode(HourlyWeatherData.self, from: data)
                    onSuccess(item)
                } else {
                    self.networkFaild = true
                    onError("Response wasn't 200. It was: \(response.statusCode)")
                }
            } catch {
                self.networkFaild = true
                onError(error.localizedDescription)
            }
        }.resume()
    }
}
