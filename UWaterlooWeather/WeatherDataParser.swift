//
//  WeatherObservation
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
            
            //Download weather condition data from the OpenWeatherMap API.
            if weatherData != nil {
                println("UW Weather Data acquired")
                let weatherCondTask = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string:"http://api.openweathermap.org/data/2.5/weather?id=6176823&mode=xml&APPID=03346813fdb0dc3c37b3c96518f067f3")!) {(data, response, error) in
                    
                    let xmlData = SWXMLHash.parse(data)
                    
                    weatherData!.weatherConditionCode = xmlData["current"]["weather"].element?.attributes["number"]?.trimAndToInt()
                    
                    dispatch_async(dispatch_get_main_queue(),{
                        //Post a notification that new weather data is now available on the main thread.
                        println("Weather Data notification posted")
                        let weatherNotification = NSNotification(name: Constants.Notifications.kWeatherDataAvailable, object: weatherData)
                        NSNotificationCenter.defaultCenter().postNotification(weatherNotification)
                    
                    })
                }
                weatherCondTask.resume()
            } else {
                println("UW Weather Data failed to acquire")
                //Post Notification
                
                //Try again?
                               
            }
        }
        
        task.resume()
        
    }
}





class WeatherObservation : NSObject {
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
    // This piece of information does not come from the UW Weather Station XML
    // We will either get it from another source, or infer it.
    var weatherConditionCode: Int?
    
    override init () {
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
        super.init()
    }
    
    init? (xmlData: XMLIndexer) {
        super.init()
        if (xmlData.children.count != 0) {
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
        } else {
            println("Weather Data initialization failed")
            return nil
        }
    }
    
/*    func inferWeatherCondition() -> String {
        //How can we determine the current weather from the information in the UW Weather API?
        //1. If there has been precipitation in the last 15 minutes, assume it is still precipitating. 
        
        if self.precipitation15Min_mm > 0.0 {
            //It is either raining or snowing. 
            if self.temperatureCelcius > 1.5 {
                return "rain"
            } else if self.temperatureCelcius < -1.5 {
                return "snow"
            } else {
                return "snow/rain"
            }
        }
        
        return "N/A"
    }*/
    
    func weatherConditionCharacter() -> String {
        
        let characterMap = [
            "sunrise" : "A",
            "sunshine" : "B",
            "eclipse" : "D",
            "windy" : "F",
            "foggy" : "M",
            "cloudy" : "Y",
            "partly cloudy" : "H",
            "thunderstorm" : "P",
            "light snow" : "V",
            "snow" : "W",
            "light rain" : "Q",
            "rain" : "R",
            "hail" : "X",
            "N/A" : ")"
        ]
        
        //Weather condition codes are found http://openweathermap.org/weather-conditions
        
        if (weatherConditionCode != nil) {
            
            if weatherConditionCode >= 200 && weatherConditionCode <= 232 {
                return characterMap["thunderstorm"]!
            } else if weatherConditionCode >= 300 && weatherConditionCode <= 321 {
                return characterMap["light rain"]!
            } else if weatherConditionCode >= 500 && weatherConditionCode <= 531 {
                return characterMap["rain"]!
            } else if weatherConditionCode >= 600 && weatherConditionCode <= 622 {
                return characterMap["snow"]!
            } else if weatherConditionCode >= 800 && weatherConditionCode <= 801 {
                return characterMap["sunshine"]!
            } else if weatherConditionCode >= 802 && weatherConditionCode <= 803 {
                return characterMap["partly cloudy"]!
            } else if weatherConditionCode == 804 {
                return characterMap["cloudy"]!
            }
            
        }
        return characterMap["N/A"]!
    }
    
}