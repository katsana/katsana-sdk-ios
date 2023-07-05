//
//  KatsanaAPI.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class KatsanaAPI: ResourceStoreManagerDelegate{
    let baseURL: URL
    let localStoreURL: URL
    
    let credential: Credential
    var tokenService = KeychainTokenService()
    lazy var httpClient: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    lazy var loginService: HTTPLoginService = {
        let loginService = HTTPLoginService(baseURL: baseURL, credential: credential, httpClient: httpClient)
        return loginService
    }()
    lazy var publisherFactory: APIPublisherFactory = {
        let authClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, tokenService: tokenService)
        let storeManager = ResourceStoreManager(delegate: self)
        let factory = APIPublisherFactory(baseURL: baseURL, baseStoreURL: localStoreURL, client: authClient, storeManager: storeManager)
        return factory
    }()
    
    var isAuthenticated = false
        
    public init(baseURL: URL, baseStoreURL: URL, credential: Credential) {
        self.baseURL = baseURL
        self.localStoreURL = baseStoreURL
        self.credential = credential
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
    
    // MARK:
    
    public func makeStore<Resource, S>(_ type: Resource.Type) -> KatsanaSDK.AnyResourceStore<Resource> where Resource : Decodable, Resource : Encodable, Resource : Equatable, S : KatsanaSDK.AnyResourceStore<Resource> {
        let classname = String(describing: Resource.self)
        let url = publisherFactory.baseStoreURL.appendingPathComponent(classname + ".store")
        let store = CodableResourceStore<Resource>(storeURL: url)
        let anyStore = AnyResourceStore(store)
        return anyStore
    }
}
