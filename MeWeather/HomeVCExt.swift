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
                case .success:
                    guard let data = response.data else { return }
                    do {
                        let decoder = JSONDecoder()
                        let geoResponse = try decoder.decode(GeoData.self, from: data)
                        if geoResponse.isEmpty == false {
                            let geoItem = geoResponse[0]
                            let lat = geoItem.lat
                            let lon = geoItem.lon
                            self.requestWeatherData(lat: lat, lon: lon)
                        }
                    } catch {
                        let networkErrorAlert = UIAlertController(title: "Network Error", message: "Something wrong happened", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default) { [self] (action) in
                            self.dismiss(animated: true)
                        }
                        networkErrorAlert.addAction(okAction)
                        self.present(networkErrorAlert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func requestWeatherData(lat: Double, lon: Double) {
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
                print("Weather Data: \(data)")
                guard let data = data as? [String: Any] else {
                    return
                }
                
                guard let sys = data["sys"] as? [String: Any] else {
                    return
                }
                
                guard let main = data["main"] as? [String: Any] else {
                    return
                }
                
                let cityName = data["name"] as? String ?? "City"
                let countryName = sys["country"] as? String ?? "Country"
                let tempKelvin = main["temp"] as? Double ?? 0.0
                let tempCelcius = tempKelvin - 273.15
                let tempInt = Int(tempCelcius)
                
                DispatchQueue.main.async {
                    self.cityLabel.text = "\(String(describing: cityName)), \(String(describing: countryName))"
                    self.tempLabel.text = "\(tempInt)°"
                    
//                    switch description {
//                    case .clearSky:
//                        print("test")
//                    case .fewClouds:
//                        print("test")
//                    case .overcastClouds:
//                        print("test")
//                    case .brokenClouds:
//                        print("test")
//                    case .scatteredClouds:
//                        print("test")
//                    case .lightRain:
//                        print("test")
//                    default:
//                        print("test")
//                    }
                }
            }
        }
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

struct GeoElement: Codable {
    let name: String
    let localNames: [String: String]?
    let lat, lon: Double
    let country: String
    let state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}

typealias GeoData = [GeoElement]

enum WeatherDescription: String {
    case clearSky = "clear sky"
    case fewClouds = "few clouds"
    case overcastClouds = "overcast clouds"
    case brokenClouds = "broken clouds"
    case scatteredClouds = "scattered clouds"
    case lightRain = "light rain"
}
