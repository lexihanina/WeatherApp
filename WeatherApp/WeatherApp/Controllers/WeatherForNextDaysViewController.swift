//
//  WeatherForNextDaysViewController.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 08.01.2022.
//

import UIKit

class WeatherForNextDaysViewController: UIViewController, PresentationSomeView {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private let decoder = JSONDecoder()
    private let defaults = UserDefaults.standard
    private let defaultsKey = "dailyWeatherData"
    private let dateFormater = DateFormatter()
    private let cellID = "WeatherForNextDaysTableViewCell"
    
    private var hasSetPointOrigin = false
    private var pointOrigin: CGPoint?
    private var weatherForNextDaysResult: DailyWeatherData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: cellID,
                                 bundle: nil),
                           forCellReuseIdentifier: cellID)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        if let weatherForNextDaysData = self.defaults.object(forKey: defaultsKey) as? Data {
            if let weatherForNextDaysDataDecoded = try? self.decoder.decode(DailyWeatherData.self, from: weatherForNextDaysData) {
                self.weatherForNextDaysResult = weatherForNextDaysDataDecoded
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        guard translation.y >= 0 else { return }
        
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
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

extension WeatherForNextDaysViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.row + 1
        var date = "unknown"
        var minDayTemp = "unknown"
        var weatherConditions = "defaultConditions"
        var maxDayTemp = "unknown"
        dateFormater.locale = Locale(identifier: "en_US_POSIX")
        dateFormater.dateFormat = "EEEE"
        
        if let dateResult = weatherForNextDaysResult?.daily[index].dt {
            let dateValue = Date(timeIntervalSince1970: Double(dateResult))
            date = dateFormater.string(from: dateValue)
        }
        
        if let minTemp = weatherForNextDaysResult?.daily[index].temp.min {
            minDayTemp = String(Int(minTemp)) + "℃"
        }
        
        if let maxTemp = weatherForNextDaysResult?.daily[index].temp.max {
            maxDayTemp = String(Int(maxTemp)) + "℃"
        }
        
        if let image = weatherForNextDaysResult?.daily[index].weather[0].icon {
            weatherConditions = image
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? WeatherForNextDaysTableViewCell
        
        if let cell = cell {
            cell.updateUI(date: date, minTemp: minDayTemp, maxTemp: maxDayTemp, image: weatherConditions)
            
            return cell
        } else {
            let cell = WeatherForNextDaysTableViewCell()
            
            return cell
        }
    }
}
