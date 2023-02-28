//
//  MoreAboutWeatherTodayViewController.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 08.01.2022.
//

import UIKit

class MoreAboutWeatherTodayViewController: UIViewController, PresentationSomeView {
    
    @IBOutlet private weak var pressureLabel: UILabel!
    @IBOutlet private weak var rainLabel: UILabel!
    @IBOutlet private weak var cloudsLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var windSpeedLabel: UILabel!
    @IBOutlet private weak var uvIndexLabel: UILabel!
    
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    func updateUIWith(data: HourlyWeatherData?) {
        if let pressure = data?.hourly[0].pressure {
            pressureLabel.text = String(pressure) + " hPa"
        } else {
            pressureLabel.text = "unknown"
        }
        
        if let rain = data?.hourly[0].rain?["1h"] {
            rainLabel.text = String(format: "%.2f", rain) + " mm"
        } else {
            rainLabel.text = "0 %"
        }
        
        if let clouds = data?.hourly[0].clouds {
            cloudsLabel.text = String(clouds) + " %"
        } else {
            cloudsLabel.text = "unknown"
        }
        
        if let humidity = data?.hourly[0].humidity {
            humidityLabel.text = String(humidity) + " %"
        } else {
            humidityLabel.text = "unknown"
        }
        
        if let windSpeed = data?.hourly[0].wind_speed {
            windSpeedLabel.text = String(windSpeed) + " km/h"
        } else {
            windSpeedLabel.text = "unknown"
        }
        
        if let uvIndex = data?.hourly[0].uvi {
            uvIndexLabel.text = String(uvIndex)
        } else {
            uvIndexLabel.text = "unknown"
        }
        
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        guard translation.y >= 0 else { return }

        view.frame.origin = CGPoint(x: 0,
                                    y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}
