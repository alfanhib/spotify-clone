//
//  APICaller.swift
//  Spotify
//
//  Created by Alfan on 24/10/23.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case FailedToGetData
    }
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void){
        createRequest(
            with: URL(string: Constants.baseURL + "/me"),
            type: .GET
        ) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, err in
                guard let data = data, err == nil else {
                    completion(.failure(APIError.FailedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    completion(.success(result))
                } catch {
                    print("ERR : \(String(describing: error))")
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
    
    public func getNewReleases(completion: @escaping((Result <NewReleasesModel, Error>) -> Void)){
        createRequest(with: URL(string: Constants.baseURL + "/browse/new-releases"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FailedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(NewReleasesModel.self, from: data)
                    print("isi result \(result)")
                    completion(.success(result))
                } catch {
                    print("ERR: \(String(describing: error))")
                    completion(.failure(error))
                }
                
            }
            
            task.resume()
        }
    }
    
    public func getFeaturedPlaylist(completion: @escaping((Result<FeaturedPlaylistsModel, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseURL + "/browse/featured-playlists?limit=1"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FailedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(FeaturedPlaylistsModel.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(APIError.FailedToGetData))
                    
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendationPlaylist(genres: Set<String>, completion: @escaping((Result<RecommendationModel, Error>) -> Void)) {
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.baseURL + "/recommendations?seed_genres=\(seeds)?limit=1"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FailedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendationModel.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(APIError.FailedToGetData))
                }
            }
            task.resume()
        }
    }
    
    public func getRecommendationGenre(completion: @escaping((Result<RecommendationGenres, Error>) -> Void)) {
        createRequest(with: URL(string: Constants.baseURL + "/recommendations/available-genre-seeds"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.FailedToGetData))
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(RecommendationGenres.self, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(APIError.FailedToGetData))
                }
            }
            
            task.resume()
        }
    }
    
    // MARK: - Private
    enum MethodType: String{
        case GET
        case POST
    }
    
    private func createRequest(
        with url: URL?,
        type: MethodType,
        completion: @escaping (URLRequest) -> Void
    ) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            
            var request = URLRequest(url: apiURL)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            completion(request)
        }
        
    }
}
