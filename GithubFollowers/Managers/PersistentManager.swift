//
//  PersistentManager.swift
//  GithubFollowers
//
//  Created by Oscar Lui on 26/8/2022.
//

import Foundation

enum PersistenActionType {
    case add, remove
}

enum PersistentManager {
    
    static private let defaults = UserDefaults.standard

    enum Keys {
        static let favourites = "favourites"
    }
    
    static func updateFavouriteData(favourite: Follower, actionType: PersistenActionType, completion:(GFError?) -> Void)  {
        retrieveFavourites { result in
            switch result {
            case .success(var favourites):
                
                switch actionType {
                case .add:
                    guard !favourites.contains(favourite) else {
                        completion(.duplicateFavourite)
                        return
                    }
                    
                    favourites.append(favourite)
                    completion(nil)
                    
                case .remove:
                    favourites.removeAll { $0.login == favourite.login }
               
                }
                
                completion(save(favourites: favourites))
                
                
                
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    static func retrieveFavourites(completion: (Result<[Follower],GFError>) -> Void) {
        guard let favouriteData = defaults.object(forKey: Keys.favourites) as? Data else {
            return completion(.success([]))
        }
        
        do {
            let decoder = JSONDecoder()
            let favourite = try decoder.decode([Follower].self, from: favouriteData)
            return completion(.success(favourite))
        } catch {
            return completion(.failure(.unableToFavourite))
        }
    }
    
    
    static func save(favourites: [Follower]) -> GFError? {
        do {
            let encoder = JSONEncoder()
            let favourite = try encoder.encode(favourites)
            defaults.set(favourite, forKey: Keys.favourites)
            return nil
        } catch {
            return .unableToFavourite
        }
    }
        
}
