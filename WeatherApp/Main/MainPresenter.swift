//
//  MainPresenter.swift
//  WeatherApp
//
//  Created by Medeu Pazylov on 23.03.2024.
//

import Foundation
import CoreLocation

protocol MainViewProtocol: NSObject {
  func updateWeatherData()
}

protocol MainPresenterProtocol {
  func getWeatherData() -> WeatherDataModel?
  func getDailyWeather(at index: Int) -> DaylyWeatherDataModel?
  func getDailyWeatherCount() -> Int
  func getCityName(completion: @escaping (String?) -> Void)
}

final class MainPresenter: NSObject, MainPresenterProtocol {
  weak var mainView: MainViewProtocol?

  private var model = MainModel()
  private let networking = WeatherNetworkingService()
  private let locationManager: CLLocationManager

  override init() {
    self.locationManager = CLLocationManager()
    super.init()
    locationManager.delegate = self
  }

  func getWeatherData() -> WeatherDataModel? {
    return model.weatherData
  }

  func getDailyWeatherCount() -> Int {
    guard let daylyWeather = model.weatherData?.daylyWeather else {
      return 0
    }
    return daylyWeather.count
  }

  func getDailyWeather(at index: Int) -> DaylyWeatherDataModel? {
    guard let daylyWeather = model.weatherData?.daylyWeather else {
      return nil
    }
    return daylyWeather[index]
  }

  func getCityName(completion: @escaping (String?) -> Void) {
    guard let location = model.userLocation else {
      completion(nil)
      return
    }
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
      guard error == nil else {
        print("Reverse geocoding error: \(error!.localizedDescription)")
        completion(nil)
        return
      }

      guard let placemark = placemarks?.first else {
        print("No placemarks found")
        completion(nil)
        return
      }

      if let city = placemark.locality {
        completion(city)
      } else {
        print("City name not found")
        completion(nil)
      }
    }
  }

  func requestLocationAndLoadData() {
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }

  private func loadWeatherData() {
    guard let location = model.userLocation?.coordinate else {
      return
    }
    networking.fetchWeatherData(
      latitude: location.latitude,
      longitude: location.longitude
    ) { [weak self] weatherDataModel in
      guard let self else {return}
      DispatchQueue.main.async {
        self.model.weatherData = weatherDataModel
        self.mainView?.updateWeatherData()
        print(weatherDataModel)
      }
    }
  }

}

extension MainPresenter: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if let location = locations.last {
      model.userLocation = location
      loadWeatherData()
    }
  }
}
