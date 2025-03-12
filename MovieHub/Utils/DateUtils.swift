//
//  DateUtils.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

struct DateUtils {
    static func convertToMonthAndYearFormat(from dateString: String?) -> String {
        guard let date = dateString, !date.isEmpty else {
            return ""
        }
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: date) {
            dateFormatter.dateFormat = "MMMM yyyy"
            dateFormatter.locale = Locale.current
            
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        }
        
        return date
    }
}
