//
//  WeatherDataModel.swift
//  WeatherApp
//
//  Created by Medeu Pazylov on 25.03.2024.
//

import Foundation

struct WeatherDataModel {

  let temp: Double
  let feels_like: Double
  let humidity: Double
  let cloudness: Double
  let weatherMain: String
  let icon: String
  let daylyWeather: [DaylyWeatherDataModel]

  init(
    temp: Double,
    feels_like: Double,
    humidity: Double,
    cloudness: Double,
    weatherMain: String,
    icon: String,
    daylyWeather: [DaylyWeatherDataModel]
  ) {
    self.temp = temp
    self.feels_like = feels_like
    self.humidity = humidity
    self.cloudness = cloudness
    self.weatherMain = weatherMain
    self.icon = icon
    self.daylyWeather = daylyWeather
  }
}

extension WeatherDataModel {

  init(data: Data) throws {
    guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
          let currentData = dict["current"] as? [String: Any],
          let dailyData = dict["daily"] as? [[String: Any]] else {
      throw ParsingError.unsuccesfulSerialization
    }

    guard let temp = currentData["temp"] as? Double,
          let feels_like = currentData["feels_like"] as? Double,
          let humidity = currentData["humidity"] as? Double,
          let cloudness = currentData["clouds"] as? Double,
          let weathers = currentData["weather"] as? [[String: Any]],
          let weather = weathers.first,
          let weatherMain = weather["main"] as? String,
          let weatherIcon = weather["icon"] as? String else {
      throw ParsingError.unsuccesfulSerialization
    }

    var daylyWeather: [DaylyWeatherDataModel] = []
    for data in dailyData {
      guard let tempData = data["temp"] as? [String: Double],
            let dayTemp = tempData["day"],
            let nightTemp = tempData["night"],
            let weathers = currentData["weather"] as? [[String: Any]],
            let weather = weathers.first,
            let weatherMain = weather["main"] as? String,
            let weatherIcon = weather["icon"] as? String 
      else {
        throw ParsingError.unsuccesfulSerialization
      }
      daylyWeather.append(DaylyWeatherDataModel(
        dayTemp: dayTemp,
        nightTemp: nightTemp,
        weatherMain: weatherMain,
        icon: weatherIcon
      ))
    }

    self.init(
      temp: temp,
      feels_like: feels_like,
      humidity: humidity,
      cloudness: cloudness,
      weatherMain: weatherMain,
      icon: weatherIcon,
      daylyWeather: daylyWeather
    )
  }
  
}
