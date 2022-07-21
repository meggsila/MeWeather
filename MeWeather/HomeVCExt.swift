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
                    print("failure: \(response)")
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
                    } catch let error {
                        print(error)
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
                print("failure: \(response)")
            case .success(let data):
                print("data is \(data)")
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
                let temp = main["temp"] as? Double ?? 0.0
                let tempInt = Int(temp)
                let tempCelcius = (tempInt - 32) * 5 / 9
                
                DispatchQueue.main.async {
                    self.cityLabel.text = "\(String(describing: cityName)), \(String(describing: countryName))"
                    self.tempLabel.text = "\(tempCelcius)°"
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
