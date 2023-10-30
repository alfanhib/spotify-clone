//
//  AuthManager.swift
//  Spotify
//
//  Created by Alfan on 24/10/23.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    private var refreshingToken = false
    
    struct Constants {
        static let base = "https://accounts.spotify.com/authorize?"
        static let ClientID = "c7718974da7547aa9db16aede229b721"
        static let ClientSecret = "57902b388a4e427fb9afd896200c2aa5"
        static let tokenAPIUrl = "https://accounts.spotify.com/api/token"
        static let redirectUri = "https://www.alfanhib.com/"
        static let scope = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-public%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    struct KeyCookies {
        static let AccessToken = "access_token"
        static let RefreshToken = "refresh_token"
        static let ExpiredDate = "expired_date"
    }
    
    private init() {}
    
    public var signInURL: URL? {
        let string = "\(Constants.base)response_type=code&client_id=\(Constants.ClientID)&scope=\(Constants.scope)&redirect_uri=\(Constants.redirectUri)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: KeyCookies.AccessToken)
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: KeyCookies.RefreshToken)
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: KeyCookies.ExpiredDate) as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expiredDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMinutes: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMinutes) > expiredDate
    }
    
    public func exchangeCodeForToken(
        code: String,
        completion: @escaping (Bool) -> (Void)
    ){
        guard let url = URL(string: Constants.tokenAPIUrl) else {
            return
        }
        
        var component = URLComponents()
        component.queryItems =  [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectUri)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.httpBody = component.query?.data(using: .utf8)
        
        let basicToken = Constants.ClientID+":"+Constants.ClientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            completion(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            
            self?.refreshingToken = false
            
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print("ERROR \(error.localizedDescription)")
                completion(false)
            }
        }
        
        task.resume()
    }
    
    private var onRefreshBlocks =  [((String) -> Void)]()
    
    public func withValidToken(completion: @escaping (String) -> Void){
        
        guard !refreshingToken else {
            onRefreshBlocks.append(completion)
            return
        }
        
        if shouldRefreshToken {
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        } else if let token = accessToken {
             completion(token)
        }
    }
    
    public func refreshIfNeeded(completion: ((Bool) -> Void)?) {
        
        guard !refreshingToken else {
            return
        }
        
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        guard let url = URL(string: Constants.tokenAPIUrl) else {
            return
        }
        
        refreshingToken = true
        
        var component = URLComponents()
        component.queryItems =  [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.httpBody = component.query?.data(using: .utf8)
        
        let basicToken = Constants.ClientID+":"+Constants.ClientSecret
        let data = basicToken.data(using: .utf8)
        
        guard let base64String = data?.base64EncodedString() else {
            completion?(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshBlocks.forEach{
                    $0(result.access_token)
                }
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result: result)
                completion?(true)
            } catch {
                print("ERROR \(error.localizedDescription)")
                completion?(false)
            }
        }
        
        task.resume()
        
    }
    
    private func cacheToken(result: AuthResponse) {
        UserDefaults.standard.setValue(result.access_token, forKey: KeyCookies.AccessToken)
        if let refreshToken = result.refresh_token {
            UserDefaults.standard.setValue(refreshToken, forKey: KeyCookies.RefreshToken)
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: KeyCookies.ExpiredDate)
    }
}
