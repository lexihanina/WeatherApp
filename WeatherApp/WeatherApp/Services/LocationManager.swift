//
//  LocationManager.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 07.12.2021.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject {
    static private var instance = LocationManager()
    var manager  = CLLocationManager()
    var latitude: Double = 0
    var longitude: Double = 0
    var delegate: LocationManagerDelegate?
    var locationsRestrictedOrDenied: Bool = false
    
    private override init() {
        super.init()
        manager.delegate = self
    }
    
    static var shared: LocationManager {
        
        return instance
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        switch status {
            case .notDetermined:
                manager.requestAlwaysAuthorization()
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
            case .restricted, .denied:
                delegate?.showLocationManagerDidFailAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locationCoordinates: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        latitude = locationCoordinates.latitude
        longitude = locationCoordinates.longitude
        delegate?.updateModelWithData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
        delegate?.showLocationDeniedAlert()
    }
}
