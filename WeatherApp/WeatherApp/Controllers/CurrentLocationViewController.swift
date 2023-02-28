//
//  ViewController.swift
//  WeatherApp
//
//  Created by Lexi Hanina on 07.12.2021.
//

import UIKit
import CoreLocation
import Lottie

enum CurrentModel {
    case currentModel
    case dailyModel
    case hourlyModel
}

protocol LocationManagerDelegate {
    func updateModelWithData()
    func showLocationManagerDidFailAlert()
    func showLocationDeniedAlert()
}

class CurrentLocationViewController: UIViewController {
    
    @IBOutlet private weak var scrollViewHight: NSLayoutConstraint!
    @IBOutlet private weak var weatherNowView: UIView!
    @IBOutlet private weak var cityNameLable: UILabel!
    @IBOutlet private weak var weatherConditionsLable: UILabel!
    @IBOutlet private weak var temperatureLable: UILabel!
    @IBOutlet private weak var minAndMaxTemperatureLable: UILabel!
    @IBOutlet private weak var weatherFullDescriptionLabel: UILabel!
    @IBOutlet private weak var sunriseTimeLable: UILabel!
    @IBOutlet private weak var sunsetTimeLable: UILabel!
    @IBOutlet private weak var weatherForNextHoursCollectionView: UICollectionView!
    @IBOutlet private weak var noInternetView: UIView!
    @IBOutlet private weak var noInternetLabel: UILabel!
    @IBOutlet private weak var backgroundImage: UIImageView!
    @IBOutlet private weak var viewWhenLoading: UIImageView!
    @IBOutlet weak var temperatureToCityConstraint: NSLayoutConstraint!
    @IBOutlet weak var moreButtonOutlet: UIButton!
    
    private let encoder: JSONEncoder = JSONEncoder()
    private let decoder: JSONDecoder = JSONDecoder()
    private let defaults: UserDefaults = UserDefaults.standard
    private let defaultsCurrentWeatherKey: String = "currentWeatherData"
    private let defaultsDailyWeatherKey: String = "dailyWeatherData"
    private let defaultsHourlyWeatherKey: String = "hourlyWeatherData"
    private let dateFormater: DateFormatter = DateFormatter()
    private let currentTimezone: Int = TimeZone.current.secondsFromGMT()
    private let cellID: String = "WeatherForNextHoursCell"
    private let littleMinBackroundImage: String = "littlemin"
    private let bigMinBackroundImage: String = "bigmin"
    private let defaultBackroundImage: String = "default"
    private let nightDark: String = "night_dark"
    private var nightDarkView: UIImageView = UIImageView()
    private var currentWeatherResult: CurrentWeatherData?
    private var savedCurrentWeatherResult: CurrentWeatherData?
    private var dailyWeatherResult: DailyWeatherData?
    private var savedDailyWeatherResult: DailyWeatherData?
    private var hourlyWeatherResult: HourlyWeatherData?
    private var savedHourlyWeatherResult: HourlyWeatherData?
    private var tempValue: Int = 0
    private var minTempValue: String = "unknown"
    private var maxTempValue: String = "unknown"
    private var sunrise: String = "unknown"
    private var sunset: String = "unknown"
    private var windSpeedNowValue: String = "unknown"
    private var feelsLikeNowValue: String = "unknown"
    private var pressureNowValue: String = "unknown"
    private var humidityNowValue: String = "unknown"
    private var timezoneOffsetValue: Int = 0
    private var weatherConditionsValue: String = "unknown"
    private var cityNameValue: String = "Unknown"
    private var hour: String = "unknown"
    private var sunsetDate: Date = Date()
    private var sunriseDate: Date = Date()
    private var weatherAnimationView: AnimationView = AnimationView()
    private var loadingAnimationView: AnimationView = AnimationView()
    private var loadingImageName: String = "loading"
    private var night: Bool = false
    private var weatherConditionsIDValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LocationManager.shared.manager.requestWhenInUseAuthorization()
        LocationManager.shared.delegate = self
        self.weatherForNextHoursCollectionView.register(UINib(nibName: self.cellID,
                                                              bundle: nil),
                                                        forCellWithReuseIdentifier: self.cellID)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppWillResignActive(notification:)),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWhenLoading.image = backgroundImage.image
        viewWhenLoading.isHidden = false
        viewWhenLoading.alpha = 1
        
        loadingAnimationView.frame = CGRect(x: ((view.frame.width / 2) - 50),
                                            y: ((view.frame.height / 2) - 50),
                                            width: 100,
                                            height: 100)
        loadingAnimationView.animation = Animation.named(loadingImageName)
        loadingAnimationView.contentMode = .scaleAspectFill
        loadingAnimationView.loopMode = .loop
        viewWhenLoading.addSubview(loadingAnimationView)
        loadingAnimationView.play()
        
        changeConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if night {
            return .lightContent
        } else {
            return .darkContent
        }
    }
    
    @IBAction func weatherForNextDaysButton(_ sender: Any) {
        showWeatherForNextDaysController(controller: WeatherForNextDaysViewController())
    }
    
    @IBAction func updateAll(_ sender: Any) {
        update()
    }
    
    @IBAction func moreButton(_ sender: Any) {
        let controller = MoreAboutWeatherTodayViewController()
        showWeatherForNextDaysController(controller: controller)
        
        if !NetworkManager.shared.networkFaild {
            controller.updateUIWith(data: hourlyWeatherResult)
        } else {
            controller.updateUIWith(data: savedHourlyWeatherResult)
        }
    }
    
    @objc func handleAppWillResignActive(notification: Notification) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleAppWillEnterForeground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc func handleAppWillEnterForeground(notification: Notification) {
        update()
    }
    
    @objc func showWeatherForNextDaysController(controller: PresentationSomeView) {
        let slideVC = controller as! UIViewController
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    private func update() {
        LocationManager.shared.manager.requestLocation()
        
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [UIView.AnimationOptions.curveEaseOut],
                       animations: {
            self.nightDarkView.removeFromSuperview()
            self.weatherAnimationView.removeFromSuperview()
            self.viewWhenLoading.isHidden = false
            self.loadingAnimationView.play()
            self.noInternetView.alpha = 0;
            self.noInternetLabel.alpha = 0
        }, completion: { _ in
            self.viewWhenLoading.alpha = 1
            self.noInternetView.isHidden = true
            self.noInternetLabel.isHidden = true
        })
    }
    
    private func showAlertIfNetworkFaild() {
        DispatchQueue.main.async {
            if NetworkManager.shared.networkFaild {
                let alert = Alert.networkManagerDidFailAlert()
                self.present(alert, animated: true, completion: nil)
                
                UIView.animate(withDuration: 1,
                               delay: 0,
                               options: [UIView.AnimationOptions.curveEaseIn],
                               animations: {
                    self.noInternetView.alpha = 1;
                    self.noInternetLabel.alpha = 1
                }, completion: { _ in
                    self.noInternetView.isHidden = false
                    self.noInternetLabel.isHidden = false
                })
                
                if let savedCurrentWeather = self.defaults.object(forKey: self.defaultsCurrentWeatherKey) as? Data {
                    if let savedCurrentWeatherDecoded = try? self.decoder.decode(CurrentWeatherData.self, from: savedCurrentWeather) {
                        self.savedCurrentWeatherResult = savedCurrentWeatherDecoded
                        self.updateData(forModel: .currentModel)
                    }
                }
                
                if let savedDailyWeather = self.defaults.object(forKey: self.defaultsDailyWeatherKey) as? Data {
                    if let savedDailyWeatherDecoded = try? self.decoder.decode(DailyWeatherData.self, from: savedDailyWeather) {
                        self.savedDailyWeatherResult = savedDailyWeatherDecoded
                        self.updateData(forModel: .dailyModel)
                    }
                }
                
                if let savedHourlyWeather = self.defaults.object(forKey: self.defaultsHourlyWeatherKey) as? Data {
                    if let savedHourlyWeatherDecoded = try? self.decoder.decode(HourlyWeatherData.self, from: savedHourlyWeather) {
                        self.savedHourlyWeatherResult = savedHourlyWeatherDecoded
                        self.updateData(forModel: .hourlyModel)
                    }
                }
            } else {
                let alert = Alert.alert()
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func updateData(forModel: CurrentModel) {
        self.dateFormater.dateFormat = "HH:mm"
        
        switch forModel {
        case .currentModel:
            if let timezoneOffset = currentWeatherResult?.timezone {
                timezoneOffsetValue = timezoneOffset
                dateFormater.timeZone = NSTimeZone(forSecondsFromGMT: timezoneOffsetValue) as TimeZone
            } else {
                timezoneOffsetValue = savedCurrentWeatherResult?.timezone ?? 0
            }
            
            if let weatherConditions = currentWeatherResult?.weather[0].description {
                weatherConditionsValue = weatherConditions
            } else {
                weatherConditionsValue = savedCurrentWeatherResult?.weather[0].description ?? "unknown"
            }
            
            if let weatherConditionsID = currentWeatherResult?.weather[0].id {
                weatherConditionsIDValue = weatherConditionsID
            } else {
                weatherConditionsIDValue = savedCurrentWeatherResult?.weather[0].id ?? 0
            }
            
            if let cityName = currentWeatherResult?.name {
                cityNameValue = cityName
            } else {
                cityNameValue = savedCurrentWeatherResult?.name ?? "Unknown"
            }
            
            if let temperature =  currentWeatherResult?.main.temp {
                tempValue = Int(temperature)
            } else {
                if let temperature = savedCurrentWeatherResult?.main.temp {
                    tempValue = Int(temperature)
                }
            }
            if let windSpeedNow = currentWeatherResult?.wind.speed{
                windSpeedNowValue = String(windSpeedNow)
            } else {
                if let windSpeedNow = savedCurrentWeatherResult?.wind.speed {
                    windSpeedNowValue = String(windSpeedNow)
                }
            }
            
            if let feelsLikeNow = currentWeatherResult?.main.feels_like{
                feelsLikeNowValue = String(Int(feelsLikeNow))
            } else {
                if let feelsLikeNow = savedCurrentWeatherResult?.main.feels_like {
                    feelsLikeNowValue = String(Int(feelsLikeNow))
                }
            }
            
            if let humidityNow = currentWeatherResult?.main.humidity {
                humidityNowValue = String(Int(humidityNow))
            } else {
                if let humidityNow = savedCurrentWeatherResult?.main.humidity {
                    humidityNowValue = String(Int(humidityNow))
                }
            }
            updateUIForCurrentWeatherWithData()
            
        case .dailyModel:
            if let minTemp = dailyWeatherResult?.daily[0].temp.min {
                minTempValue = String(Int(minTemp))
            } else {
                if let minTemp = savedDailyWeatherResult?.daily[0].temp.min {
                    minTempValue = String(Int(minTemp))
                }
            }
            
            if let maxTemp = dailyWeatherResult?.daily[0].temp.max{
                maxTempValue = String(Int(maxTemp))
            } else {
                if let maxTemp = savedDailyWeatherResult?.daily[0].temp.max {
                    maxTempValue = String(Int(maxTemp))
                }
            }
            
            if let sunriseInt = dailyWeatherResult?.daily[0].sunrise{
                let sunriseDate = (Date(timeIntervalSince1970: Double(sunriseInt)))
                self.sunriseDate = sunriseDate
                sunrise = dateFormater.string(from: sunriseDate)
            } else {
                if let sunriseInt = savedDailyWeatherResult?.daily[0].sunrise {
                    let sunriseDate = (Date(timeIntervalSince1970: Double(sunriseInt)))
                    self.sunriseDate = sunriseDate
                    sunrise = dateFormater.string(from: sunriseDate)
                }
            }
            
            if let sunsetInt = dailyWeatherResult?.daily[0].sunset{
                let sunsetDate = (Date(timeIntervalSince1970: Double(sunsetInt)))
                self.sunsetDate = sunsetDate
                sunset = dateFormater.string(from: sunsetDate)
            } else {
                if let sunsetInt = savedDailyWeatherResult?.daily[0].sunrise {
                    let sunsetDate = (Date(timeIntervalSince1970: Double(sunsetInt)))
                    self.sunsetDate = sunsetDate
                    sunrise = dateFormater.string(from: sunsetDate)
                }
            }
            addAnimation()
            updateUIForDailyWeatherWithData()
            
        case .hourlyModel:
            updateUIForHourlyWeatherWithData()
        }
    }
    
    private func updateUIForCurrentWeatherWithData() {
        DispatchQueue.main.async {
            switch self.tempValue {
            case -10...0:
                self.backgroundImage.image = UIImage(named: self.littleMinBackroundImage)
            case ...(-10):
                self.backgroundImage.image = UIImage(named: self.bigMinBackroundImage)
            default:
                self.backgroundImage.image = UIImage(named: self.defaultBackroundImage)
            }
            
            self.weatherConditionsLable.text = self.weatherConditionsValue
            self.temperatureLable.text = String(self.tempValue) + "℃"
            self.cityNameLable.text = self.cityNameValue
            self.weatherFullDescriptionLabel.text = """
 Weather now:
 
 Feels like: \(self.feelsLikeNowValue)℃
 Wind speed: \(self.windSpeedNowValue) km/hr.
 """
            UIView.animate(withDuration: 1,
                           delay: 0,
                           options: [UIView.AnimationOptions.curveEaseOut],
                           animations: {
                self.viewWhenLoading.alpha = 0
            }, completion: { _ in
                self.viewWhenLoading.isHidden = true
                self.loadingAnimationView.stop()
                self.weatherAnimationView.play()
            })
        }
    }
    
    private func updateUIForDailyWeatherWithData() {
        DispatchQueue.main.async {
            self.minAndMaxTemperatureLable.text = "min: \(self.minTempValue), max: \(self.maxTempValue)"
            self.sunriseTimeLable.text = self.sunrise
            self.sunsetTimeLable.text = self.sunset
        }
    }
    
    private func updateUIForHourlyWeatherWithData() {
        DispatchQueue.main.async {
            self.weatherForNextHoursCollectionView.reloadData()
        }
    }
    
    private func setWeatherAnimation(with name: String, andFrame frame: CGRect) -> AnimationView {
        DispatchQueue.main.async {
            self.weatherAnimationView.frame = frame
            self.weatherAnimationView.animation = Animation.named(name)
            self.weatherAnimationView.contentMode = .scaleAspectFill
            self.weatherAnimationView.loopMode = .loop
        }
        
        return weatherAnimationView
    }
    
    private func addNightBackround() {
        DispatchQueue.main.async {
            self.nightDarkView = UIImageView(frame: self.view.bounds)
            self.nightDarkView.image = UIImage(named: self.nightDark)
            self.nightDarkView.layer.opacity = 0.8
            self.backgroundImage.addSubview(self.nightDarkView)
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }

    private func addAnimation() {
        var weatherAnimationNamed = getAnimationNameForWeather(conditionsID: weatherConditionsIDValue)

        let dayTime = getDayTimeFrom(sunset: sunsetDate, sunrise: sunriseDate)
        
        if dayTime == .day {
            night = false
        }
        
        if dayTime == .night {
            weatherAnimationNamed = "night" + weatherAnimationNamed
            if weatherAnimationNamed == "nightclear" || weatherAnimationNamed == "nightcloudsandsun" {
                addNightBackround()
            }
            self.night = true
        }
        
        DispatchQueue.main.async {
            self.setNeedsStatusBarAppearanceUpdate()
            self.weatherAnimationView = self.setWeatherAnimation(with: weatherAnimationNamed,
                                                                 andFrame: self.view.bounds)
            self.backgroundImage.addSubview(self.weatherAnimationView)
            if self.night && weatherAnimationNamed != "nightclear" && weatherAnimationNamed != "nightcloudsandsun" {
                self.addNightBackround()
            }
        }
    }
}

extension CurrentLocationViewController: LocationManagerDelegate {
    
    func showLocationManagerDidFailAlert() {
        let alert = Alert.locationManagerDidFailAlert()
        present(alert, animated: true, completion: nil)
    }
    
    func showLocationDeniedAlert() {
        let alert = Alert.locationDeniedAlert()
        present(alert, animated: true, completion: nil)
    }
    
    func updateModelWithData() {
        NetworkManager.shared.downloadCurrentWeatherData { currentWeatherData in
            if let encoded = try? self.encoder.encode(currentWeatherData) {
                self.defaults.set(encoded, forKey: self.defaultsCurrentWeatherKey)
            }
            
            if let currentWeatherLoadedData = self.defaults.object(forKey: self.defaultsCurrentWeatherKey) as? Data {
                if let currentWeatherResultDecoded = try? self.decoder.decode(CurrentWeatherData.self, from: currentWeatherLoadedData) {
                    self.currentWeatherResult = currentWeatherResultDecoded
                    self.updateData(forModel: .currentModel)
                }
            }
        } onError: { error in
            self.showAlertIfNetworkFaild()
        }
        
        NetworkManager.shared.downloadDailyWeatherData { dailyWeatherData in
            if let encoded = try? self.encoder.encode(dailyWeatherData) {
                self.defaults.set(encoded, forKey: self.defaultsDailyWeatherKey)
            }
            
            if let dailyWeatherLoadedData = self.defaults.object(forKey: self.defaultsDailyWeatherKey) as? Data {
                if let dailyWeatherResultDecoded = try? self.decoder.decode(DailyWeatherData.self, from: dailyWeatherLoadedData) {
                    self.dailyWeatherResult = dailyWeatherResultDecoded
                    self.updateData(forModel: .dailyModel)
                }
            }
            
        } onError: { error in
            self.showAlertIfNetworkFaild()
        }
        
        NetworkManager.shared.downloadHourlyWeatherData { hourlylyWeatherData in
            if let encoded = try? self.encoder.encode(hourlylyWeatherData) {
                self.defaults.set(encoded, forKey: self.defaultsHourlyWeatherKey)
            }
            
            if let hourlyWeatherLoadedData = self.defaults.object(forKey: self.defaultsHourlyWeatherKey) as? Data {
                if let hourlyWeatherResultDecoded = try? self.decoder.decode(HourlyWeatherData.self, from: hourlyWeatherLoadedData) {
                    self.hourlyWeatherResult = hourlyWeatherResultDecoded
                    self.updateData(forModel: .hourlyModel)
                }
            }
            
        } onError: { error in
            print(error)
            self.showAlertIfNetworkFaild()
        }
    }
}

extension CurrentLocationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let numberOfItems = hourlyWeatherResult?.hourly.count {
            
            return numberOfItems / 2
        } else {
            if let numberOfSavedItems = savedHourlyWeatherResult?.hourly.count {
                
                return numberOfSavedItems / 2
            } else {
                
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.dateFormater.dateFormat = "HH"
        let temp = hourlyWeatherResult?.hourly[indexPath.row].temp ?? savedHourlyWeatherResult?.hourly[indexPath.row].temp ?? 0
        let image = hourlyWeatherResult?.hourly[indexPath.row].weather[0].icon ?? savedHourlyWeatherResult?.hourly[indexPath.row].weather[0].icon
        
        if let hourInt = hourlyWeatherResult?.hourly[indexPath.row].dt {
            dateFormater.timeZone = NSTimeZone(forSecondsFromGMT: timezoneOffsetValue) as TimeZone
            let hourValue = Date(timeIntervalSince1970: Double(hourInt))
            hour = self.dateFormater.string(from: hourValue)
        } else {
            if let hourInt = savedHourlyWeatherResult?.hourly[indexPath.row].dt {
                dateFormater.timeZone = NSTimeZone(forSecondsFromGMT: timezoneOffsetValue) as TimeZone
                let hourValue = Date(timeIntervalSince1970: Double(hourInt))
                hour = self.dateFormater.string(from: hourValue)
            }
        }
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? WeatherForNextHoursCell {
            cell.updateCellWithData(temp: temp, imageNamed: image, forHour: hour)
            
            return cell
        } else {
            let cell = WeatherForNextHoursCell()
            cell.updateCellWithData(temp: 0, imageNamed: nil, forHour: "unknown")
            
            return cell
        }
    }
}

extension CurrentLocationViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension CurrentLocationViewController {
    func changeConstraints() {
        let viewSize = view.frame.size.height
        
        switch viewSize {
            case 568:
                scrollViewHight.constant = 380
                temperatureToCityConstraint.constant = 20
            case 667:
                scrollViewHight.constant = 380
                temperatureToCityConstraint.constant = 20
            case 847:
                scrollViewHight.constant = 380
            case 736:
                scrollViewHight.constant = 380
            case 812:
                scrollViewHight.constant = 416
            case 896:
                scrollViewHight.constant = 500
            case 844:
                scrollViewHight.constant = 454
            case 852:
                scrollViewHight.constant = 460
            default: //926, 932
                scrollViewHight.constant = 530
        }
    }
}
