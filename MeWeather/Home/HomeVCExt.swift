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
            DispatchQueue.main.async {
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
                            let locationData = data[0]
                            let lat = locationData["lat"] as? Double ?? 0.0
                            let lon = locationData["lon"] as? Double ?? 0.0
                            self.requestCurrentWeatherData(lat: lat, lon: lon)
                            self.requestHourlyForecast(lat: lat, lon: lon)
                        }
                    }
                }
            }
        }
    }
    
    func requestCurrentWeatherData(lat: Double, lon: Double) {
        let apiKey = "a2b0437bab1e6c84f259746c0914bb08"
        DispatchQueue.main.async {
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
                    guard let data = data as? [String: Any] else {
                        return
                    }
                    
                    guard let sys = data["sys"] as? [String: Any] else {
                        return
                    }
                    
                    guard let main = data["main"] as? [String: Any] else {
                        return
                    }
                    
                    guard let weather = data["weather"] as? [[String: Any]] else {
                        return
                    }
                    
                    let cityName = data["name"] as? String ?? "City"
                    let countryName = sys["country"] as? String ?? "Country"
                    let tempKelvin = main["temp"] as? Double ?? 0.0
                    let tempInt = Int(tempKelvin - 273.15)
                    
                    self.noDataLabel.isHidden = true
                    if weather.isEmpty == false {
                        let weatherItem = weather[0]
                        let description = weatherItem["description"] as? String ?? "Description"
                        self.descriptionLabel.text = description.capitalizingFirstLetter()
                        self.descriptionToImage(description: description, imagevIew: self.weatherIcon, time: "")
                    }
                    
                    self.cityLabel.text = "\(String(describing: cityName)), \(String(describing: countryName))"
                    self.tempLabel.text = "\(tempInt)°"
                }
            }
        }
    }
    
    func requestHourlyForecast(lat: Double, lon: Double) {
        let apiKey = "a2b0437bab1e6c84f259746c0914bb08"
        DispatchQueue.main.async {
            AF.request("https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&cnt=4&appid=\(apiKey)", method: .get).responseJSON { (response: DataResponse) in
                switch response.result {
                case .failure:
                    let networkErrorAlert = UIAlertController(title: "Network Error", message: "Something wrong happened", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                        self.dismiss(animated: true)
                    }
                    networkErrorAlert.addAction(okAction)
                    self.present(networkErrorAlert, animated: true, completion: nil)
                case .success(let data):
                    guard let data = data as? [String: Any] else {
                        return
                    }
                    
                    guard let weatherList = data["list"] as? [[String: Any]] else {
                        return
                    }
                    
                    if weatherList.isEmpty == false {
                        for i in 0..<weatherList.count {
                            let weatherItem = weatherList[i]
                            
                            guard let main = weatherItem["main"] as? [String: Any] else {
                                return
                            }
                            
                            guard let weatherData = weatherItem["weather"] as? [[String: Any]] else {
                                return
                            }
                            self.hourlyWeatherViewsArray[i].noDataLabel.isHidden = true
                            
                            let dateText = weatherItem["dt_txt"] as? String ?? ""
                            let start = dateText.index(dateText.startIndex, offsetBy: 11)
                            let end = dateText.index(dateText.endIndex, offsetBy: -3)
                            let range = start..<end
                            let formattedTime = dateText[range]
                            
                            if weatherData.isEmpty == false {
                                let item = weatherData[0]
                                let description = item["description"] as? String ?? "Description"
                                self.descriptionToImage(description: description, imagevIew: self.hourlyWeatherViewsArray[i].weatherIcon, time: String(formattedTime))
                            }
                            
                            let tempKelvin = main["temp"] as? Double ?? 0.0
                            let tempInt = Int(tempKelvin - 273.15)
                            
                            let tempFeelsLikeKelvin = main["feels_like"] as? Double ?? 0.0
                            let tempFeelsLikeInt = Int(tempFeelsLikeKelvin - 273.15)
                            
                            self.hourlyWeatherViewsArray[i].timeLabel.text = String(formattedTime)
                            self.hourlyWeatherViewsArray[i].dataLabel.text = "Feels like \(tempFeelsLikeInt)°"
                            self.hourlyWeatherViewsArray[i].tempLabel.text = "\(tempInt)°"
                        }
                    }
                }
            }
        }
    }
    
    func descriptionToImage(description: String, imagevIew: UIImageView, time: String) {
        switch description {
        case "clear sky":
            if time == "21:00" || time == "00:00" {
                imagevIew.image = UIImage(systemName: "moon.stars.fill")?.withRenderingMode(.alwaysOriginal)
            } else {
                imagevIew.image = UIImage(systemName: "sun.max.fill")?.withRenderingMode(.alwaysOriginal)
            }
        case "few clouds":
            if time == "21:00" || time == "00:00" {
                imagevIew.image = UIImage(systemName: "cloud.moon.fill")?.withRenderingMode(.alwaysOriginal)
            } else {
                imagevIew.image = UIImage(systemName: "cloud.sun.fill")?.withRenderingMode(.alwaysOriginal)
            }
        case "overcast clouds":
            if time == "21:00" || time == "00:00" {
                imagevIew.image = UIImage(systemName: "cloud.moon.fill")?.withRenderingMode(.alwaysOriginal)
            } else {
                imagevIew.image = UIImage(systemName: "cloud.sun.fill")?.withRenderingMode(.alwaysOriginal)
            }
        case "broken clouds":
            imagevIew.image = UIImage(systemName: "cloud.fill")?.withRenderingMode(.alwaysOriginal)
        case "scattered clouds":
            imagevIew.image = UIImage(systemName: "smoke.fill")?.withRenderingMode(.alwaysOriginal)
        case "light rain":
            if time == "21:00" || time == "00:00" {
                imagevIew.image = UIImage(systemName: "cloud.moon.rain.fill")?.withRenderingMode(.alwaysOriginal)
            } else {
                imagevIew.image = UIImage(systemName: "cloud.hail.fill")?.withRenderingMode(.alwaysOriginal)
            }
        case "heavy rain":
            if time == "21:00" || time == "00:00" {
                imagevIew.image = UIImage(systemName: "cloud.moon.bolt.fill")?.withRenderingMode(.alwaysOriginal)
            } else {
                imagevIew.image = UIImage(systemName: "cloud.heavyrain.fill")?.withRenderingMode(.alwaysOriginal)
            }
        default:
            imagevIew.image = UIImage(systemName: "cloud.fill")?.withRenderingMode(.alwaysOriginal)
        }
    }
}

class HourlyWeatherView: UIView {
    var noDataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .secondaryLabel
        label.font = UIFont(name: Fonts.medium , size: 12)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textAlignment = .center
        label.text = "No data"
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .label
        label.font = UIFont(name: Fonts.heavy , size: 15)
        label.textAlignment = .center
        label.text = ""
        return label
    }()
    
    var weatherIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .clear
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 10
        return image
    }()
    
    var tempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .label
        label.font = UIFont(name: Fonts.heavy , size: 40)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    var dataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .secondaryLabel
        label.font = UIFont(name: Fonts.medium , size: 12)
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        return label
    }()
    
    
    init() {
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
        addSubview(noDataLabel)
        addSubview(timeLabel)
        addSubview(weatherIcon)
        addSubview(tempLabel)
        addSubview(dataLabel)
        
        NSLayoutConstraint.activate([
            noDataLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            noDataLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            noDataLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            noDataLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            noDataLabel.widthAnchor.constraint(equalToConstant: 35),
            
            timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            timeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            timeLabel.heightAnchor.constraint(equalToConstant: 15),
            
            weatherIcon.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            weatherIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            weatherIcon.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
            weatherIcon.heightAnchor.constraint(equalToConstant: 50),
            
            tempLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            tempLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            tempLabel.topAnchor.constraint(equalTo: weatherIcon.bottomAnchor, constant: 10),
            tempLabel.heightAnchor.constraint(equalToConstant: 40),
            
            dataLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            dataLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            dataLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 10),
            dataLabel.heightAnchor.constraint(equalToConstant: 40),
        ])
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
