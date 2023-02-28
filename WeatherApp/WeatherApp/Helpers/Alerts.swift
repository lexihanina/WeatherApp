//
//  Alerts.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 08.12.2021.
//

import Foundation
import UIKit

struct Alert {
    
    static func locationDeniedAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Can't detect your location",
                                      message: "Allow to determine your location and try again.",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.cancel,
                                      handler: nil))
        return alert
    }
    
    static func locationManagerDidFailAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Can't determine your location",
                                      message: "The GPS and other location services aren't responding.",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel,
                                      handler: nil))
        return alert
    }

    static func networkManagerDidFailAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Something went wrong",
                                      message: "Check your internet connection and try again.",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.cancel,
                                      handler: nil))
        return alert
    }
    
    static func customAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.cancel,
                                      handler: nil))
        return alert
    }
    
    static func alert() -> UIAlertController {
        let alert = UIAlertController(title: "Oops!",
                                      message: "Something wrong...",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.cancel,
                                      handler: nil))
        return alert
    }
}

