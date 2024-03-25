//
//  ViewController.swift
//  WeatherApp
//
//  Created by Medeu Pazylov on 23.03.2024.
//

import UIKit
import CoreLocation

final class MainViewController: UIViewController{

  private let presenter: MainPresenterProtocol

  init(presenter: MainPresenterProtocol) {
    self.presenter = presenter
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
    setupLayout()
    activityIndicator.startAnimating()
    tableView.delegate = self
    tableView.dataSource = self
  }

  private func setupViews() {
    view.addSubview(backgroundView)
    backgroundView.frame = view.frame
    view.addSubview(locationLabel)
    view.addSubview(temperatureLabel)
    view.addSubview(descriptionLabel)
    view.addSubview(tableView)

    view.addSubview(blurForegroundView)
    blurForegroundView.frame = view.frame
    view.addSubview(activityIndicator)
    activityIndicator.center = view.center
  }

  private func setupLayout() {
    NSLayoutConstraint.activate([
      locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      temperatureLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor),
      temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      descriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor),
      descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32),
      tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32),
      tableView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
    ])
  }


  private let backgroundView: UIImageView = {
    let image = UIImage(named: "clouds")
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFill
    return imageView
  } ()

  private let blurForegroundView: UIVisualEffectView = {
    let blur = UIBlurEffect(style: .regular)
    let view = UIVisualEffectView(effect: blur)
    return view
  } ()

  private let activityIndicator: UIActivityIndicatorView = {
    let activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.color = .gray
    activityIndicator.hidesWhenStopped = true
    return activityIndicator
  } ()

  private let locationLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Astana"
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
    label.layer.shadowColor = UIColor.gray.cgColor
    label.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    label.layer.shadowRadius = 4.0
    label.layer.shadowOpacity = 0.5
    return label
  } ()

  private let temperatureLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .white
    label.text = "8°"
    label.font = UIFont.systemFont(ofSize: 128, weight: .light)
    label.layer.shadowColor = UIColor.gray.cgColor
    label.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    label.layer.shadowRadius = 4.0
    label.layer.shadowOpacity = 0.5
    return label
  } ()

  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Sun"
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
    label.layer.shadowColor = UIColor.gray.cgColor
    label.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    label.layer.shadowRadius = 4.0
    label.layer.shadowOpacity = 0.5
    return label
  } ()

  private let tableView : UITableView = {
    let table = UITableView()
    table.translatesAutoresizingMaskIntoConstraints = false
    table.allowsSelection = false
    table.backgroundColor = .white.withAlphaComponent(0.3)
    table.layer.cornerRadius = 16.0
    table.separatorColor = .white
    return table
  }()

}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return presenter.getDailyWeatherCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let daylyWeather = presenter.getDailyWeather(at: indexPath.row) else {
        return UITableViewCell()
      }
      let cell = UITableViewCell()
      cell.textLabel?.text = "\(Int(daylyWeather.dayTemp))°"
      cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - UITableViewDelegate methods
extension MainViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    64
  }
}


extension MainViewController: MainViewProtocol {
  func updateWeatherData() {
    UIView.animate(withDuration: 1, animations: {
      self.blurForegroundView.isHidden = true
    })
    activityIndicator.stopAnimating()
    presenter.getCityName(completion: { [unowned self] cityName in
      self.locationLabel.text = cityName
    })
    tableView.reloadData()

    guard let weatherData = presenter.getWeatherData() else {
      return
    }
    temperatureLabel.text = "\(Int(weatherData.temp))°"
    descriptionLabel.text = weatherData.weatherMain

  }
  
}

extension UIColor {
  static var weatherBackground = UIColor(red: 32/255, green: 42/255, blue: 68/255, alpha: 1.0)
}

