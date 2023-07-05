//
//  HTTPLoginService.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class HTTPLoginService: LoginService{
    let baseURL: URL
    let credential: Credential
    let httpClient: HTTPClient
    
    public init(baseURL: URL, credential: Credential, httpClient: HTTPClient) {
        self.credential = credential
        self.baseURL = baseURL
        self.httpClient = httpClient
    }
    
    public func login(email: String, password: String, completion: @escaping (Result<AccessToken, Swift.Error>) -> Void) {
        httpClient.send(loginRequest()) {result in
            switch result{
            case .success((let data, let response)):
                do{
                    let token = try LoginMapper.map(data, from: response)
                    completion(.success(token))
                }
                catch{
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func loginRequest() -> URLRequest{
        let url = LoginEndpoint.get.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? credential.data()
        return request
    }
    
}