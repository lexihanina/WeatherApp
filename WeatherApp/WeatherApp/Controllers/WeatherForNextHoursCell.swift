//
//  weatherForNextHoursCollectionViewController.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 10.12.2021.
//

import UIKit

class WeatherForNextHoursCell: UICollectionViewCell {
    
    @IBOutlet private weak var hourLabelInWeatherForNextHours: UILabel!
    @IBOutlet private weak var weatherImageInWeatherForNextHours: UIImageView!
    @IBOutlet private weak var tempInWeatherForNextHours: UILabel!
    
    func updateCellWithData(temp: Double, imageNamed image: String?, forHour hour: String) {
        hourLabelInWeatherForNextHours.text = hour + "h"
        tempInWeatherForNextHours.text = String(Int(temp)) + "℃"
        weatherImageInWeatherForNextHours.image = UIImage(named: image ?? "default")
    }
}
