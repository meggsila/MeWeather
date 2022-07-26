//
//  Extensions.swift
//  MeWeather
//
//  Created by Megi Sila on 26.7.22.
//

import Foundation

enum Fonts {
    static let heavy = "Avenir-Heavy"
    static let medium = "Avenir-Medium"
    static let light = "Avenir-Light"
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
