//
//  ImageUtils.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

struct ImageUtils {
    static func getImageURL(from path: String?) -> URL? {
        guard let path = path, !path.isEmpty else {
            return nil
        }
        
        return URL(string: ApiConfig.baseImageURL + path)
    }
}
