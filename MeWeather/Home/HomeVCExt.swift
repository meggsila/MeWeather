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
        AF.request("https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)", method: .get).responseJSON { (response: DataResponse) in
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
                
                guard let weatherList = data["list"] as? [[String: Any]] else {
                    return
                }
                
                if weatherList.isEmpty == false {
                    for i in 0..<4 {
                        let weatherItem = weatherList[i]
                        
                        guard let main = weatherItem["main"] as? [String: Any] else {
                            return
                        }
                        
//                        guard let weatherData = data["weather"] as? [[String: Any]] else {
//                            return
//                        }
                        
                        let tempKelvin = main["temp"] as? Double ?? 0.0
                        let tempCelcius = tempKelvin - 273.15
                        let tempInt = Int(tempCelcius)
                        
                        let tempFeelsLikeKelvin = main["feels_like"] as? Double ?? 0.0
                        let tempFeelsLikeCelcius = tempFeelsLikeKelvin - 273.15
                        let tempFeelsLikeInt = Int(tempFeelsLikeCelcius)
                        
                        let tempMaxKelvin = main["temp_max"] as? Double ?? 0.0
                        let tempMaxCelcius = tempMaxKelvin - 273.15
                        let tempMaxInt = Int(tempMaxCelcius)
                        
                        let tempMinKelvin = main["temp_min"] as? Double ?? 0.0
                        let tempMinCelcius = tempMinKelvin - 273.15
                        let tempMinInt = Int(tempMinCelcius)
                        
                        print("temp in celcius is \(tempInt), feels like \(tempFeelsLikeInt), temp max \(tempMaxInt), min \(tempMinInt)")
                        
                        self.dailyWeatherViewsArray[i].tempLabel.text = "\(tempInt)°"
                        self.dailyWeatherViewsArray[i].dataLabel.text = "Feels like \(tempFeelsLikeInt)°, Max: \(tempMaxInt)°, Min: \(tempMinInt)°"

                        
//                        if weatherData.isEmpty == false {
//                            let item = weatherData[0]
//                            let description = item["description"] as? String ?? "Description"
//                        }
                    }
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
    var dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .label
        label.font = UIFont(name: Fonts.heavy , size: 15)
        label.textAlignment = .center
        label.text = "Day"
        return label
    }()
    
    var weatherIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .clear
        image.image = UIImage(systemName: "cloud.sun.fill")?.withRenderingMode(.alwaysOriginal)
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
        label.textAlignment = .center
        label.text = "21°"
        return label
    }()
    
    var dataLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .secondaryLabel
        label.font = UIFont(name: Fonts.medium , size: 12)
        label.textAlignment = .center
        label.text = "Feels like 27°, Max: 30°, Min: 17°"
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
        addSubview(dayLabel)
        addSubview(weatherIcon)
        addSubview(tempLabel)
        addSubview(dataLabel)
        
        NSLayoutConstraint.activate([
            dayLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            dayLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            dayLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            dayLabel.heightAnchor.constraint(equalToConstant: 15),
            
            weatherIcon.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
            weatherIcon.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
            weatherIcon.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 10),
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
