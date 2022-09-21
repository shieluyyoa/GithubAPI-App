//
//  NetworkManager.swift
//  GithubFollowers
//
//  Created by Oscar Lui on 30/7/2022.
//


import UIKit
 
class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://api.github.com/users/"
    let cache = NSCache<NSString, UIImage>()
    
    private var baseGitHubURL: URLComponents {
            var urlComponents = URLComponents()
            urlComponents.scheme = "https"
            urlComponents.host = "api.github.com"
            return urlComponents
        }
    
    
    private init() {}
    
    func getFollowers(for username: String, page: Int) async throws -> [Follower] {
        guard let url = gitHubURL(with: "/users/\(username)/followers",query: ["per_page":"100","page":"\(page)"]) else {
            throw GFError.invalidUsername
        }
        
        
        do {
            return try await sendGHRequest(to: url, modelType: [Follower].self)
        } catch {
            throw error
        }
        
        
        
//        sendGHRequest(to: url, modelType: [Follower].self) { result in
//            switch result {
//            case .success(let followers):
//                completion(.success(followers))
//
//            case .failure(let error):
//                completion(.failure(error))
//
//            }
//        }
    }
    
    func getUserInfo(for username: String) async throws -> User {
        guard let url = gitHubURL(with: "/users/\(username)") else {
            throw GFError.invalidUsername
        }
        
            do {
                return try await sendGHRequest(to: url, modelType: User.self)
            } catch {
                throw error
            }
            
        }
        
       
//
//        sendGHRequest(to: url, modelType: User.self) { result in
//            switch result {
//            case .success(let user):
//                completion(.success(user))
//
//            case .failure(let error):
//                completion(.failure(error))
//
//            }
//        }
    
    
    private func gitHubURL(with path: String, query:[String:String]? = nil) -> URL? {
        var urlComponents = baseGitHubURL
        urlComponents.path = path
        
        if let query = query {
            var queryItem = [URLQueryItem]()
            
            for (key,value) in query {
                queryItem.append(URLQueryItem(name: key, value: value))
            }
            
            urlComponents.queryItems = queryItem
        }
        
        return urlComponents.url
    }
    
    
    private func sendGHRequest<T: Codable>(to url:URL, modelType: T.Type) async throws -> T {
        
        let (data,response) = try await URLSession.shared.data(from: url)
        
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GFError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            let model = try decoder.decode(modelType, from: data)
            return model
        } catch {
            throw GFError.invalidData
        }
    }
    
    func downloadImage(from urlString:String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        if let image = cache.object(forKey: cacheKey) {
            completion(image)
            return
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let strongSelf = self ,
                error == nil,
                let response = response as? HTTPURLResponse,
                let data = data,
                response.statusCode == 200,
                let image = UIImage(data: data)
            else {
                completion(nil)
                return
            }
            
            strongSelf.cache.setObject(image, forKey: cacheKey)
            
            completion(image)
            
        }
        
        task.resume()
    }
        
    
}

