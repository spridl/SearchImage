//
//  NetworkService.swift
//  UnsplashSeachPhoto
//
//  Created by T on 21.11.2021.
//  Copyright © 2021 Spridl. All rights reserved.
//

import Foundation

class NetworkService {
    
    // построение запроса данных по URL
    func request(searchTerm: String, countPerPage: Int, page: Int, completion: @escaping (Data?, Error?) -> Void)  {
        
        let parameters = self.prepareParameters(searchTerm: searchTerm, countPerPage: countPerPage, page: page)
        let url = self.url(params: parameters)
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = prepareHeader()
        request.httpMethod = "get"
        let task = createDataTask(from: request, completion: completion)
        task.resume()
    }
    
    private func prepareHeader() -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Client-ID 7ce8gSz9TBqm5uFpMFTn3LeuT6enj_z2P5KYqPzQgUQ"
        return headers
    }
    
    private func prepareParameters(searchTerm: String?, countPerPage: Int, page: Int) -> [String: String] {
        var parameters = [String: String]()
        parameters["query"] = searchTerm
        parameters["page"] = String(page)
        parameters["per_page"] = String(countPerPage)
        return parameters
    }
    
    private func url(params: [String: String]) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/search/photos"
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1)}
        return components.url!
    }
    
    private func createDataTask(from request: URLRequest, completion: @escaping (Data? , Error?) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                completion(data, error)
            }
        }
    }
}

