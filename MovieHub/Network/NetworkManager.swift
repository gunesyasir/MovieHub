//
//  NetworkManager.swift
//  MovieHub
//
//  Created by Yasir Gunes on 10.03.2025.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func sendRequest<T: Decodable>(to path: ApiEndpoint, add queryItemList: [URLQueryItem] = [], completionHandler: @escaping (Result<T, Error>) -> Void) {
        
        guard let url = URL(string: ApiConfig.baseURL + path.url) else { return }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        var queryItemArray: [URLQueryItem] = queryItemList
        
        queryItemArray.append(contentsOf: [
            URLQueryItem(name: API_KEY, value: ApiConfig.apiKey),
            URLQueryItem(name: LANGUAGE, value: AppConfig.appLanguage),
          ])

        components.queryItems = components.queryItems.map { $0 + queryItemArray } ?? queryItemArray
        
        let urlRequest = URLRequest(url: components.url!)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            self.handleDataTaskResponse(data: data, response: response, error: error, completionHandler: completionHandler)
        }
        
        task.resume()
    }
    
    private func handleDataTaskResponse<T: Decodable>(data: Data?, response: URLResponse?, error: Error?, completionHandler: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.main.async {
            
            if error != nil {
                completionHandler(.failure(NetworkError.transportationError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(NetworkError.requestFailed))
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            guard (200...299).contains(statusCode) else {
                completionHandler(.failure(NetworkError.requestFailed))
                return
            }
            
            guard let data = data, let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                completionHandler(.failure(NetworkError.dataConversionFailure))
                return
            }
            
            completionHandler(.success(decodedData))
        }
    }
    
    
}
