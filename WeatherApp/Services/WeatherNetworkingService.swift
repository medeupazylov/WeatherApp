//
//  NetworkingService.swift
//  WeatherApp
//
//  Created by Medeu Pazylov on 23.03.2024.
//

import Foundation

final class WeatherNetworkingService {

  func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping(WeatherDataModel?) -> Void) {
    guard let url = addParametersToURL(
      baseURL: weatherBaseURL,
      parameters: [
        "lat" : "\(latitude)",
        "lon" : "\(longitude)",
        "exclude" : exlude,
        "appid" : appid,
        "units" : "metric"
      ]
    ) else { return }

    print(url.absoluteString)

    let session = URLSession(configuration: .default)
    let task = session.dataTask(with: url) { data, response, error in
      if let error = error {
        completion(nil)
        return
      }
      guard let data = data else {
        completion(nil)
        return
      }
      let model = try? WeatherDataModel(data: data)
      completion(model)
    }
    task.resume()
  }

  private func addParametersToURL(baseURL: String, parameters: [String: String]) -> URL? {
      guard var urlComponents = URLComponents(string: baseURL) else {
          print("ERROR: Invalid base URL")
          return nil
      }
      let queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
      urlComponents.queryItems = queryItems
      guard let url = urlComponents.url else {
          print("ERROR: Invalid URL after adding parameters")
          return nil
      }
      return url
  }
}

private let weatherBaseURL = "https://api.openweathermap.org/data/3.0/onecall"
private let iconBaseURL = "https://openweathermap.org/img/wn/"
private let exlude = "minutely,hourly"
private let appid = "d7459cd4e01d3bf39641ae0dd8b1a6ba"
