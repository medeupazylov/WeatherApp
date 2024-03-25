//
//  MainModel.swift
//  WeatherApp
//
//  Created by Medeu Pazylov on 23.03.2024.
//

import Foundation
import CoreLocation

struct MainModel {
  var userLocation: CLLocation?
  var weatherData: WeatherDataModel?

  mutating func updateWeatherData(_ data: WeatherDataModel) {
    self.weatherData = data
  }

  mutating func updateUserLocation(_ location: CLLocation) {
    self.userLocation = location
  }
}
