//
//  APIController.swift
//  PinterestLibrary
//
//  Created by kelvin lee wei sern on 20/07/2019.
//  Copyright © 2019 MindValley. All rights reserved.
//

import Foundation

public enum URLMethod: String {
    case GET
    case POST
    case DELETE
    case PUT
    case PATCH
}

public enum NetworkError: Error {
    case timedOut(String)
    case noInternet(String)
    case cancelled(String)
    case unknown(String)
    case invalidToken(String)
    
    var message: String {
        switch self {
        case .cancelled(let message):
            return message
        case .noInternet(let message):
            return message
        case .unknown(let message):
            return message
        case .invalidToken(let message):
            return message
        case .timedOut(let message):
            return message
        }
    }
}

public struct NetworkService {
    
    public static func fetch<T: Decodable>(from url: URL,
                                           withMethod method: URLMethod? = .GET,
                                           headers: [String: String]? = nil,
                                           completion: @escaping ((Result<T, NetworkError>) -> Void)) {
        
        // URL request configurations
        let urlRequest = NSMutableURLRequest(url: url)
        
        if let method = method {
            urlRequest.httpMethod = method.rawValue
        }
        
        if let headers = headers {
            for header in headers {
                urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        let session = URLSession.shared
        
        let data = session.dataTask(with: urlRequest as URLRequest) { (data, response, error) in
            if let error = error {
                print("There was an error \(error)")
                
                let urlError = error as NSError
                if urlError.code == NSURLErrorTimedOut {
                    completion(.failure(.timedOut("Operation timed out.")))
                } else if urlError.code == NSURLErrorNotConnectedToInternet {
                    completion(.failure(.noInternet("Could not establish connection to the Internet")))
                } else if urlError.code == URLError.cancelled.rawValue {
                    completion(.failure(.cancelled("This operation has been cancelled.")))
                } else {
                    completion(.failure(.unknown("Unknown failure.")))
                }
            } else {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401  {
                    completion(.failure(.invalidToken("Attempting to execute a request with an unauthorized token.")))
                } else {
                    let object = try! JSONDecoder().decode(T.self, from: data!)
                    completion(.success(object))                }
            }
        }
        data.resume()
    }
}
