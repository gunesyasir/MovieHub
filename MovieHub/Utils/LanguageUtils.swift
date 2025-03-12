//
//  LanguageUtils.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

struct LanguageUtils {
    static func getLocalizedLanguageName(fromCode code: String) -> String? {
        let locale = Locale.current
        return locale.localizedString(forLanguageCode: code)
    }
}
