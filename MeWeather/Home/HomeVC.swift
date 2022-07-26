//
//  ViewController.swift
//  MeWeather
//
//  Created by Megi Sila on 20.7.22.
//

import UIKit
import Alamofire

class HomeVC: UIViewController {
    // MARK: - Profile Section
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.layer.cornerRadius = 55
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .systemGray5
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    let uploadImageButton : UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search for country..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = true
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .systemBackground
        return searchBar
    }()
    
    var dashboard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.layer.cornerRadius = 10
        return view
    }()
    
    var todayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .label
        label.font = UIFont(name: Fonts.heavy , size: 17)
        label.textAlignment = .left
        label.text = "Today"
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
    
    var cityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .secondaryLabel
        label.font = UIFont(name: Fonts.medium , size: 17)
        label.textAlignment = .left
        label.text = "Paris, FR"
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .secondaryLabel
        label.font = UIFont(name: Fonts.medium , size: 17)
        label.textAlignment = .right
        return label
    }()
    
    var tempLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .label
        label.textAlignment = .right
        label.font = UIFont(name: Fonts.medium , size: 70)
        label.backgroundColor = .clear
        label.text = "23°"
        return label
    }()
    
    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.font = UIFont(name: Fonts.medium , size: 17)
        label.text = "Partially cloudy"
        return label
    }()
    
    var dailyWeatherLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.textColor = .label
        label.font = UIFont(name: Fonts.heavy , size: 17)
        label.textAlignment = .left
        label.text = "Daily Forecast"
        return label
    }()
    
    var dailyWeatherStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .clear
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.distribution = .fillEqually
        return stack
    }()
    
    var dailyWeatherViewsArray = [DailyWeatherView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupProfileSection()
        setupSearchController()
        setupDashboard()
        setupDailyForecastViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        dateLabel.text = localDate()
    }
    
    private func setupProfileSection() {
        view.addSubview(profileImage)
        
        view.addSubview(uploadImageButton)
        uploadImageButton.addTarget(self, action: #selector(uploadImage), for: .touchUpInside)

        NSLayoutConstraint.activate([
            profileImage.widthAnchor.constraint(equalToConstant: 110),
            profileImage.heightAnchor.constraint(equalToConstant: 110),
            profileImage.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            profileImage.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -5),
            
            uploadImageButton.widthAnchor.constraint(equalToConstant: 110),
            uploadImageButton.heightAnchor.constraint(equalToConstant: 110),
            uploadImageButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            uploadImageButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -5)
        ])
        
        let arr1 = DataManager.shared.fetchImage()
        if arr1.count == 1 {
            profileImage.image = UIImage(data: arr1[0].profilePic!)
        } else if arr1.count > 1 {
            profileImage.image = UIImage(data: arr1[arr1.count - 1].profilePic!)
        } else {
            ///FALLBACK
        }
    }
    
    private func setupSearchController() {
        searchBar.frame = CGRect(x: 0, y: 50 + 110 + 10, width: view.frame.width, height: 50)
        searchBar.delegate = self
        view.addSubview(searchBar)
    }
    
    private func setupDashboard() {
        view.addSubview(dashboard)
        view.addSubview(todayLabel)
        view.addSubview(weatherIcon)
        view.addSubview(cityLabel)
        view.addSubview(dateLabel)
        view.addSubview(tempLabel)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            dashboard.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            dashboard.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            dashboard.heightAnchor.constraint(equalToConstant: 210),
            dashboard.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 20),
            
            todayLabel.leftAnchor.constraint(equalTo: dashboard.leftAnchor, constant: 10),
            todayLabel.heightAnchor.constraint(equalToConstant: 20),
            todayLabel.widthAnchor.constraint(equalToConstant: 210 - 2 * ( 20 + 10 + 10)),
            todayLabel.topAnchor.constraint(equalTo: dashboard.topAnchor, constant: 10),
            
            weatherIcon.leftAnchor.constraint(equalTo: dashboard.leftAnchor, constant: 10),
            weatherIcon.heightAnchor.constraint(equalToConstant: 210 - 2 * ( 20 + 10 + 10)),
            weatherIcon.widthAnchor.constraint(equalToConstant: 210 - 2 * ( 20 + 10 + 10)),
            weatherIcon.topAnchor.constraint(equalTo: todayLabel.bottomAnchor, constant: 10),
            
            cityLabel.bottomAnchor.constraint(equalTo: dashboard.bottomAnchor, constant: -10),
            cityLabel.leftAnchor.constraint(equalTo: dashboard.leftAnchor, constant: 10),
            cityLabel.heightAnchor.constraint(equalToConstant: 20),
            cityLabel.widthAnchor.constraint(equalToConstant: 210 - 2 * ( 20 + 10 + 10)),
            
            dateLabel.rightAnchor.constraint(equalTo: dashboard.rightAnchor, constant: -10),
            dateLabel.heightAnchor.constraint(equalToConstant: 20),
            dateLabel.widthAnchor.constraint(equalToConstant: 210 - 2 * ( 20 + 10 + 10)),
            dateLabel.topAnchor.constraint(equalTo: dashboard.topAnchor, constant: 10),
            
            tempLabel.leftAnchor.constraint(equalTo: weatherIcon.rightAnchor, constant: 10),
            tempLabel.rightAnchor.constraint(equalTo: dashboard.rightAnchor, constant: -10),
            tempLabel.heightAnchor.constraint(equalToConstant: 210 - 2 * ( 20 + 10 + 10)),
            tempLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            
            descriptionLabel.bottomAnchor.constraint(equalTo: dashboard.bottomAnchor, constant: -10),
            descriptionLabel.leftAnchor.constraint(equalTo: weatherIcon.rightAnchor, constant: 10),
            descriptionLabel.rightAnchor.constraint(equalTo: dashboard.rightAnchor, constant: -10),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    
    private func setupDailyForecastViews() {
        view.addSubview(dailyWeatherLabel)
        view.addSubview(dailyWeatherStack)
        
        NSLayoutConstraint.activate([
            dailyWeatherLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            dailyWeatherLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            dailyWeatherLabel.heightAnchor.constraint(equalToConstant: 17),
            dailyWeatherLabel.topAnchor.constraint(equalTo: dashboard.bottomAnchor, constant: 20),
            
            dailyWeatherStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            dailyWeatherStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            dailyWeatherStack.heightAnchor.constraint(equalToConstant: 210),
            dailyWeatherStack.topAnchor.constraint(equalTo: dailyWeatherLabel.bottomAnchor, constant: 20)
        ])
        
        let day1View = DailyWeatherView()
        let day2View = DailyWeatherView()
        let day3View = DailyWeatherView()
        let day4View = DailyWeatherView()
        
        dailyWeatherViewsArray.append(day1View)
        dailyWeatherViewsArray.append(day2View)
        dailyWeatherViewsArray.append(day3View)
        dailyWeatherViewsArray.append(day4View)

        dailyWeatherStack.addArrangedSubview(day1View)
        dailyWeatherStack.addArrangedSubview(day2View)
        dailyWeatherStack.addArrangedSubview(day3View)
        dailyWeatherStack.addArrangedSubview(day4View)

        NSLayoutConstraint.activate([
            day1View.heightAnchor.constraint(equalToConstant: 210),
            day2View.heightAnchor.constraint(equalToConstant: 210),
            day3View.heightAnchor.constraint(equalToConstant: 210),
            day4View.heightAnchor.constraint(equalToConstant: 210)
        ])
    }
    
    @objc
    func uploadImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func localDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM"
        let yearString = dateFormatter.string(from: date)
        return yearString
    }
}
