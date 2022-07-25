//
//  HomeVCExt.swift
//  MeWeather
//
//  Created by Megi Sila on 20.7.22.
//

import UIKit
import Alamofire

extension HomeVC: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let apiKey = "a2b0437bab1e6c84f259746c0914bb08"
        let cityName = searchText
        if searchText.count > 2 {
            AF.request("https://api.openweathermap.org/geo/1.0/direct?q=\(cityName)&limit=1&appid=\(apiKey)", method: .get).responseJSON { (response: DataResponse) in
                switch response.result {
                case .failure:
                    let networkErrorAlert = UIAlertController(title: "Network Error", message: "Something wrong happened", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                        self.dismiss(animated: true)
                    }
                    networkErrorAlert.addAction(okAction)
                    self.present(networkErrorAlert, animated: true, completion: nil)
                case .success(let data):
                    guard let data = data as? [[String: Any]] else {
                        return
                    }
                    
                    if data.isEmpty == false {
                        let weatherItem = data[0]
                        let lat = weatherItem["lat"] as? Double ?? 0.0
                        let lon = weatherItem["lon"] as? Double ?? 0.0
                        self.requestCurrentWeatherData(lat: lat, lon: lon)
                        self.requestHourlyForecast(lat: lat, lon: lon)
                    }
                }
            }
        }
    }
    
    func requestCurrentWeatherData(lat: Double, lon: Double) {
        let apiKey = "a2b0437bab1e6c84f259746c0914bb08"
        AF.request("https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)", method: .get).responseJSON { (response: DataResponse) in
            switch response.result {
            case .failure:
                let networkErrorAlert = UIAlertController(title: "Network Error", message: "Something wrong happened", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                    self.dismiss(animated: true)
                }
                networkErrorAlert.addAction(okAction)
                self.present(networkErrorAlert, animated: true, completion: nil)
            case .success(let data):
                print("Current Weather Data: \(data)")
                guard let data = data as? [String: Any] else {
                    return
                }
                
                guard let sys = data["sys"] as? [String: Any] else {
                    return
                }
                
                guard let main = data["main"] as? [String: Any] else {
                    return
                }
                
                guard let weatherData = data["weather"] as? [[String: Any]] else {
                    return
                }
 
                let cityName = data["name"] as? String ?? "City"
                let countryName = sys["country"] as? String ?? "Country"
                let tempKelvin = main["temp"] as? Double ?? 0.0
                let tempCelcius = tempKelvin - 273.15
                let tempInt = Int(tempCelcius)
                
                if weatherData.isEmpty == false {
                    let weatherItem = weatherData[0]
                    let description = weatherItem["description"] as? String ?? "Description"
                    self.descriptionLabel.text = description.capitalizingFirstLetter()
                    self.descriptionToImage(description: description)
                }
                
                self.cityLabel.text = "\(String(describing: cityName)), \(String(describing: countryName))"
                self.tempLabel.text = "\(tempInt)°"
            }
        }
    }
    
    func requestHourlyForecast(lat: Double, lon: Double) {
        let apiKey = "a2b0437bab1e6c84f259746c0914bb08"
        AF.request("https://pro.openweathermap.org/data/2.5/forecast/hourly?lat=&appid=\(apiKey)", method: .get).responseJSON { (response: DataResponse) in
            switch response.result {
            case .failure:
                let networkErrorAlert = UIAlertController(title: "Network Error", message: "Something wrong happened", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                    self.dismiss(animated: true)
                }
                networkErrorAlert.addAction(okAction)
                self.present(networkErrorAlert, animated: true, completion: nil)
            case .success(let data):
                print("Hourly Forecast Weather Data: \(data)")
                guard let data = data as? [String: Any] else {
                    return
                }
            }
        }
    }
    
    func descriptionToImage(description: String) {
        switch description {
        case "clear sky":
            self.weatherIcon.image = UIImage(systemName: "sun.max.fill")?.withRenderingMode(.alwaysOriginal)
        case "few clouds":
            self.weatherIcon.image = UIImage(systemName: "cloud.sun.fill")?.withRenderingMode(.alwaysOriginal)
        case "overcast clouds":
            self.weatherIcon.image = UIImage(systemName: "cloud.sun.fill")?.withRenderingMode(.alwaysOriginal)
        case "broken clouds":
            self.weatherIcon.image = UIImage(systemName: "cloud.fill")?.withRenderingMode(.alwaysOriginal)
        case "scattered clouds":
            self.weatherIcon.image = UIImage(systemName: "smoke.fill")?.withRenderingMode(.alwaysOriginal)
        case "light rain":
            self.weatherIcon.image = UIImage(systemName: "cloud.hail.fill")?.withRenderingMode(.alwaysOriginal)
        case "heavy rain":
            self.weatherIcon.image = UIImage(systemName: "cloud.heavyrain.fill")?.withRenderingMode(.alwaysOriginal)
        default:
            self.weatherIcon.image = UIImage(systemName: "cloud.fill")?.withRenderingMode(.alwaysOriginal)
        }
    }
}

class DailyWeatherView: UIView {
    var temperature: Int
    var weatherDescription: String

    init(temperature: Int, weatherDescription: String) {
        self.temperature = temperature
        self.weatherDescription = weatherDescription
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemGray5
        layer.cornerRadius = 10
    }
}

extension HomeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else { return }
        profileImage.image = userPickedImage
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = userPickedImage.jpegData(compressionQuality: 0.1) {
            try? jpegData.write(to: imagePath)
        }
        
        dismiss(animated: true) {
            if let imageData = self.profileImage.image?.pngData() {
                DataManager.shared.saveImage(data: imageData)
            }
        }
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}

enum Fonts {
    static let heavy = "Avenir-Heavy"
    static let medium = "Avenir-Medium"
    static let light = "Avenir-Light"
}
