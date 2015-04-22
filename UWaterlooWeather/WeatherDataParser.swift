//
//  WeatherDataXMLParser.swift
//  UWaterlooWeather
//
//  Created by Daniel Johnson on 4/20/15.
//  Copyright (c) 2015 Daniel Johnson. All rights reserved.
//

import Foundation
import SWXMLHash


class WeatherDataParser : NSObject {
    
    let sourceURL: NSURL
    
    override init() {
        self.sourceURL = NSURL(string: "http://weather.uwaterloo.ca/waterloo_weather_station_data.xml")!
        super.init()
    }
    
    init(url: NSURL) {
        sourceURL = url;
    }
    
    func getData() {
        let task = NSURLSession.sharedSession().dataTaskWithURL(sourceURL) {(data, response, error) in
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
            let xmlData = SWXMLHash.parse(data);
            //println(xmlData)
            let weatherData = WeatherObservation(xmlData:xmlData);
            println("Weather Data available")
            dispatch_async(dispatch_get_main_queue(),{
                //Post a notification that new weather data is now available on the main thread.
                println("Weather Data notification posted")
                let weatherNotification = NSNotification(name: Constants.Notifications.kWeatherDataAvailable, object: weatherData)
                NSNotificationCenter.defaultCenter().postNotification(weatherNotification)
            });
        }
        
        task.resume()
        
    }
}





class WeatherObservation {
    var dataSource: String?
    var dataSourceURL: NSURL?
    var locationName: String?
    var latitude: String?
    var longitude: String?
    var elevation: String?
    var observationMonthName: String?
    var observationMonthNumber: Int?
    var observationDay: Int?
    var observationYear: Int?
    var observationHour: Int?
    var observationMinute: Int?
    var temperatureCelcius: Float?
    var humidexCelcius: Float?
    var windchillCelcius: Float?
    var temperature24HrMax: Float?
    var temperature24HrMin: Float?
    var precipitation15Min_mm: Float?
    var precipitation1Hr_mm: Float?
    var precipitation24Hr_mm: Float?
    var relativeHumidityPercent: Float?
    var dewpointCelcius: Float?
    var windspeedKph: Float?
    var windDirection: String?
    var windDirectionDegrees: Int?
    var pressureKpa: Float?
    var pressureTrend: String?
    var shortwaveRadiationWpM2: Float?
    
    init () {
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute, fromDate:currentDate)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        observationMonthName = dateFormatter.stringFromDate(currentDate)
        observationYear = components.year
        observationMonthNumber = components.month
        observationDay = components.day
        observationHour = components.hour
        observationMinute = components.minute
    }
    
    init (xmlData: XMLIndexer) {
        println(xmlData)
        let currentObs = xmlData["current_observation"]
        dataSource = currentObs["credit"].element!.text!.trim()
        let urlString = currentObs["credit_URL"].element!.text!.trim()
        dataSourceURL = NSURL(string:urlString!)
        locationName = currentObs["location"].element!.text!.trim()
        latitude = currentObs["latitude"].element!.text!.trim()
        longitude = currentObs["longitude"].element!.text!.trim()
        elevation = currentObs["elevation"].element!.text!.trim()
        observationMonthName = currentObs["observation_month_text"].element!.text!.trim()
        observationMonthNumber = currentObs["observation_month_number"].element!.text!.trimAndToInt()
        observationDay = currentObs["observation_day"].element!.text!.trimAndToInt()
        observationYear = currentObs["observation_year"].element!.text!.trimAndToInt()
        observationHour = currentObs["observation_hour"].element!.text!.trimAndToInt()
        observationMinute = currentObs["observation_minute"].element!.text!.trimAndToInt()
        temperatureCelcius = currentObs["temperature_current_C"].element!.text!.trimAndToFloat()
        humidexCelcius = currentObs["humidex_C"].element!.text!.trimAndToFloat()
        windchillCelcius = currentObs["windchill_C"].element!.text!.trimAndToFloat()
        temperature24HrMax = currentObs["temperature_24hrmax_C"].element!.text!.trimAndToFloat()
        temperature24HrMin = currentObs["temperature_24hrmin_C"].element!.text!.trimAndToFloat()
        precipitation15Min_mm = currentObs["precipitation_15minutes_mm"].element!.text!.trimAndToFloat()
        precipitation1Hr_mm = currentObs["precipitation_1hr_mm"].element!.text!.trimAndToFloat()
        precipitation24Hr_mm = currentObs["precipitation_24hr_mm"].element!.text!.trimAndToFloat()
        relativeHumidityPercent = currentObs["relative_humidity_percent"].element!.text!.trimAndToFloat()
        dewpointCelcius = currentObs["dew_point_C"].element!.text!.trimAndToFloat()
        windspeedKph = currentObs["wind_speed_kph"].element!.text!.trimAndToFloat()
        windDirection = currentObs["wind_direction"].element!.text!.trim()
        windDirectionDegrees = currentObs["wind_direction_degrees"].element!.text!.trimAndToInt()
        pressureKpa = currentObs["pressure_kpa"].element!.text!.trimAndToFloat()
        pressureTrend = currentObs["pressure_trend"].element!.text!.trim()
        shortwaveRadiationWpM2 = currentObs["incoming_shortwave_radiation_WM2"].element!.text!.trimAndToFloat()
       
    }
}