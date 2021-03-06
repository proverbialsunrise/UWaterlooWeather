//
//  ViewController.swift
//  UWaterlooWeather
//
//  Created by Daniel Johnson on 4/20/15.
//  Copyright (c) 2015 Daniel Johnson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var temperatureLabel : UILabel?
    @IBOutlet weak var windLabel : UILabel?
    @IBOutlet weak var feelslikeLabel :UILabel?
    @IBOutlet weak var weatherGraphic :UILabel?
    @IBOutlet weak var locationLabel :UILabel?
    
    var weatherObservation : WeatherObservation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Start listening for weather update notifications.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "weatherDataReceived:", name: Constants.Notifications.kWeatherDataAvailable, object: nil)
        //Get new weather Data!
        let weatherGetter = WeatherDataParser (url: NSURL(string: "http://weather.uwaterloo.ca/waterloo_weather_station_data.xml")!)
        weatherGetter.getData();
    }
    
    func weatherDataReceived(notification: NSNotification) {
        //update UI for weather data.
        println("Weather Data Received in View Controller")
        let weatherData = notification.object as! WeatherObservation
        
        updateWeatherUI(weatherData)

        
    }
    
    func updateWeatherUI(weatherData: WeatherObservation) {
        locationLabel!.text = weatherData.dataSource!
        
        temperatureLabel!.text = String(format: "%.0fº", weatherData.temperatureCelcius!)
        
        
        if ((weatherData.windchillCelcius) != nil)
        {
            feelslikeLabel!.text = String(format: "Feels like %.1fº", weatherData.windchillCelcius!)
        } else if ((weatherData.humidexCelcius) != nil) {
            feelslikeLabel!.text = String(format: "Feels like %.1fº", weatherData.humidexCelcius!)
        } else {
            feelslikeLabel!.text = String(format: "Feels like %.1fº", weatherData.temperatureCelcius!)
        }
        
        windLabel!.text = String(format: "%.0f km/h %@", weatherData.windspeedKph!, weatherData.windDirection!)
        
        weatherGraphic!.text = weatherData.weatherConditionCharacter()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

