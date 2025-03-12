//
//  Int.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

extension Int {
    func toCurrencyString(locale: Locale = Locale(identifier: "en_US"), currencyCode: String = "USD") -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = locale
        numberFormatter.currencyCode = currencyCode
        return numberFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
