//
//  WeatherForNextDaysTableViewCell.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 08.01.2022.
//

import UIKit

class WeatherForNextDaysTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var dateLable: UILabel!
    @IBOutlet private weak var minDayTempLable: UILabel!
    @IBOutlet private weak var weatherConditionsImage: UIImageView!
    @IBOutlet private weak var maxDayTempLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func updateUI(date: String, minTemp: String, maxTemp: String, image: String) {
        DispatchQueue.main.async {
            self.dateLable.text = date
            self.minDayTempLable.text = minTemp
            self.weatherConditionsImage.image = UIImage(named: image)
            self.maxDayTempLable.text = maxTemp
        }
    }
}

