//
//  KatsanaAPI.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class KatsanaAPI{
    let baseURL: URL
    let publisherFactory: APIPublisherFactory
    
    let credential: Credential
    let httpClient: HTTPClient
    
    let tokenService: KeychainTokenService
    var loginService: HTTPLoginService
    
    var isAuthenticated = false
        
    public init(baseURL: URL, baseStoreURL: URL, credential: Credential, httpClient: HTTPClient, storeManager: ResourceStoreManager) {
        self.baseURL = baseURL
        self.credential = credential
        self.httpClient = httpClient
        self.tokenService = KeychainTokenService()
        
        publisherFactory = APIPublisherFactory(baseURL: baseURL, baseStoreURL: baseStoreURL, client: AuthenticatedHTTPClientDecorator(decoratee: httpClient, tokenService: tokenService), storeManager: storeManager)
        loginService = HTTPLoginService(baseURL: baseURL, credential: credential, httpClient: httpClient)
    }
    
    public func login(email: String, password: String, completion: @escaping (AccessTokenResult) -> Void){
        loginService.login(email: email, password: password) {[weak self] result in
            switch result{
            case .success(let token):
                self?.tokenService.token = token
                self?.isAuthenticated = true
            case .failure:
                self?.isAuthenticated = false
            }
            completion(result)
        }
    }
}
