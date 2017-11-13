//
//  WeatherVC.swift
//  Weather
//
//  Created by Aman Bhullar on 2017-11-09.
//  Copyright © 2017 Aman Bhullar. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class WeatherVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, MapViewControllerDelegate {
    func addItemViewControllerDidComplete(_ controller: MapViewController, item: WeatherDTO) {
        navigationController?.popViewController(animated: true)
        print ("CallBack: \(item.address)")
        locationAuthStatus(weatherDTO: item)
    }
    
   
    
   
    

    @IBOutlet weak var locationLabel: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentWeatherImage: UIImageView!
    @IBOutlet weak var currentWeatherTypeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var currentWeather: CurrentWeather!
    var forecast: Forecast!
    var forecasts = [Forecast]()
    
    var FORECAST_URL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let mainController: CollectionViewController = CollectionViewController(nibName: "CollectionViewController", bundle: nil)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
                
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        
        currentLocation = locationManager.location
        print ("Here")
        let weatherDTO = WeatherDTO()
        weatherDTO.latitude = currentLocation.coordinate.latitude
        weatherDTO.longitude = currentLocation.coordinate.longitude
        currentWeather = CurrentWeather(latitude: weatherDTO.latitude, longitude: weatherDTO.longitude)
        locationAuthStatus(weatherDTO: weatherDTO)
        
        
    }
    
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func currentLocationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            currentLocation = locationManager.location;                     Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            
            currentWeather = CurrentWeather(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            forecasts.removeAll()
            changeForcastURL(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
            
            
            currentWeather.downloadWeatherDetails {
                self.downloadForecastData {
                    self.updateMainUI()
                }
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            currentLocation = locationManager.location
            let weatherDTO = WeatherDTO()
            weatherDTO.latitude = currentLocation.coordinate.latitude
            weatherDTO.longitude = currentLocation.coordinate.longitude
            changeForcastURL(latitude: weatherDTO.latitude, longitude: weatherDTO.longitude)
            locationAuthStatus(weatherDTO: weatherDTO)
        }
    }
    func locationAuthStatus(weatherDTO : WeatherDTO) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
//            currentLocation = locationManager.location
            Location.sharedInstance.latitude = weatherDTO.latitude
            Location.sharedInstance.longitude = weatherDTO.longitude
//            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
//            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            
            currentWeather = CurrentWeather(latitude: weatherDTO.latitude, longitude: weatherDTO.longitude)
              forecasts.removeAll()
            changeForcastURL(latitude: weatherDTO.latitude, longitude: weatherDTO.longitude)
            
          
            currentWeather.downloadWeatherDetails {
                self.downloadForecastData {
                    self.updateMainUI()
                }
            }
        } else {
            locationManager.requestWhenInUseAuthorization()
            currentLocation = locationManager.location
            let weatherDTO = WeatherDTO()
            weatherDTO.latitude = currentLocation.coordinate.latitude
            weatherDTO.longitude = currentLocation.coordinate.longitude
            changeForcastURL(latitude: weatherDTO.latitude, longitude: weatherDTO.longitude)
            locationAuthStatus(weatherDTO: weatherDTO)
        }
    }
    
    func changeForcastURL (latitude: Double, longitude: Double){
        FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(latitude)&lon=\(longitude)&cnt=10&mode=json&appid=42a1771a0b787bf12e734ada0cfc80cb"
    }
    
    func downloadForecastData(completed: @escaping DownloadComplete) {
        //Downloading forecast weather data for TableView
        Alamofire.request(FORECAST_URL).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                
                if let list = dict["list"] as? [Dictionary<String, AnyObject>] {
                    
                    for obj in list {
                        let forecast = Forecast(weatherDict: obj)
                        self.forecasts.append(forecast)
                        print(obj)
                    }
                    self.forecasts.remove(at: 0)
                    self.tableView.reloadData()
                }
            }
            completed()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as? WeatherCell {
            
            let forecast = forecasts[indexPath.row]
            cell.configureCell(forecast: forecast)
            return cell
        } else {
            return WeatherCell()
        }
    }
    
    func updateMainUI() {
        dateLabel.text = currentWeather.date
        currentTempLabel.text = "\(currentWeather.currentTemp)"
        currentWeatherTypeLabel.text = currentWeather.weatherType
        locationLabel.setTitle(currentWeather.cityName, for: .normal)
        currentWeatherImage.image = UIImage(named: currentWeather.weatherType)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMap" {
            let controller = segue.destination as! MapViewController
            
            controller.delegate = self
            var weatherDTO = WeatherDTO()
            weatherDTO.address = currentWeather.cityName
            
            controller.weatherDTO = weatherDTO
            
        }
    }
    
}

