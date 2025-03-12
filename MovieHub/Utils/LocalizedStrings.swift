//
//  Localized.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

enum LocalizedStrings {
    case addToBookmarks
    case birthDate
    case birthPlace
    case birthPlaceAndDate
    case bookmarks
    case budget
    case cast
    case deathDate
    case errorMessage
    case ok
    case originalTitle
    case popular
    case productionCompany
    case recommendations
    case removeFromBookmarks
    case revenue
    case search
    case searchByMovie
    case tryAgain
    
    var localized: String {
        switch self {
            case .addToBookmarks:
                return "addToBookmarks".localized()
            case .birthDate:
                return "birthDate".localized()
            case .birthPlace:
                return "birthPlace".localized()
            case .birthPlaceAndDate:
                return "birthPlaceAndDate".localized()
            case .bookmarks:
                return "bookmarks".localized()
            case .budget:
                return "budget".localized()
            case .cast:
                return "cast".localized()
            case .deathDate:
                return "deathDate".localized()
            case .errorMessage:
                return "errorMessage".localized()
            case .ok:
                return "ok".localized()
            case .originalTitle:
                return "originalTitle".localized()
            case .popular:
                return "popular".localized()
            case .productionCompany:
                return "productionCompany".localized()
            case .recommendations:
                return "recommendations".localized()
            case .removeFromBookmarks:
                return "removeFromBookmarks".localized()
            case .revenue:
                return "revenue".localized()
            case .search:
                return "search".localized()
            case .searchByMovie:
                return "searchByMovie".localized()
            case .tryAgain:
                return "tryAgain".localized()
        }
    }
}
