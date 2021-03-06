//
//  PersistenceManager.swift
//  GithubFollowers
//
//  Created by andry on 28/05/2020.
//  Copyright © 2020 andry tafa. All rights reserved.
//

import Foundation

enum PersistenceActionType {
    case add, remove
}

enum PersistenceManager {
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let favourites = "favourites"
    }
    
    // MARK: - updateWith
    static func updateWith(favourite: Follower, actionType: PersistenceActionType, completed: @escaping (GFError?) -> Void) {
        retrieveFavourites { result in
            switch result {
            case .success(let favourites):
                var retrievedFavourites = favourites
                switch actionType {
                case .add:
                    // making sure it's not in favourites alread
                    guard !retrievedFavourites.contains(favourite) else {
                        completed(.alreadyInFavourites)
                        return
                    }
                    retrievedFavourites.append(favourite)
                case .remove:
                    retrievedFavourites.removeAll { $0.login == favourite.login }
                }
                completed(save(favourites: retrievedFavourites))
            case .failure(let error):
                completed(error)
            }
        }
    }
    
    static func retrieveFavourites(completed: @escaping (Result<[Follower], GFError>) -> Void) {
        guard let favouritesData = defaults.object(forKey: Keys.favourites) as? Data else {
            completed(.success([]))
            
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let favourites = try decoder.decode([Follower].self, from: favouritesData)
            completed(.success(favourites))
        } catch {
            completed(.failure(.unableToFavourite))
        }
    }
    
    static func save(favourites: [Follower]) -> GFError? {
        do {
            let encoder = JSONEncoder()
            let encodedFavourites = try encoder.encode(favourites)
            
            defaults.set(encodedFavourites, forKey: Keys.favourites)
            
            return nil
        } catch {
            return .unableToFavourite
        }
    }
}
