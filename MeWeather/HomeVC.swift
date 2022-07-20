//
//  ViewController.swift
//  MeWeather
//
//  Created by Megi Sila on 20.7.22.
//

import UIKit
import Alamofire

class HomeVC: UIViewController {
    //https://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}
    // MARK: - Profile Section
    let profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.layer.cornerRadius = 45
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
    
    var weatherIcon: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.backgroundColor = .clear
        image.image = UIImage(systemName: "cloud.sun.fill")
        image.layer.cornerRadius = 10
        return image
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupProfileSection()
        setupSearchController()
        setupDashboard()
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
        dashboard.frame = CGRect(x: 10, y: 50 + 110 + 50 + 20, width: view.frame.width - 20, height: 200)
        view.addSubview(dashboard)
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
}
