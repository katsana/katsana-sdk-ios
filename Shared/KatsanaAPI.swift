//
//  KatsanaAPI.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class KatsanaAPI: ResourceStoreManagerDelegate, LoginService{
    let baseURL: URL
    let localStoreURL: URL
    
    let credential: Credential
    var tokenService: TokenService & TokenCache
    var username: String?
    
    lazy var httpClient: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    lazy var loginService: LoginService = {
        let loginService = HTTPLoginService(baseURL: baseURL, credential: credential, httpClient: httpClient)
        return MainQueueDispatchDecorator(loginService)
    }()
    public lazy var publisherFactory: APIPublisherFactory = {
        let authClient = AuthenticatedHTTPClientDecorator(decoratee: httpClient, tokenService: tokenService, username: {[weak self] in self?.username
        })
        let storeManager = ResourceStoreManager(delegate: self)
        let factory = APIPublisherFactory(baseURL: baseURL, baseStoreURL: localStoreURL, client: authClient, storeManager: storeManager)
        return factory
    }()
    
    public var isAuthenticated: Bool{
        guard let username else {return false}
        return tokenService.getToken() != nil
    }
        
    public init(baseURL: URL, baseStoreURL: URL, credential: Credential) {
        self.baseURL = baseURL
        self.localStoreURL = baseStoreURL
        self.credential = credential
        self.tokenService = KeychainTokenService()
    }
    
    public func login(email: String, password: String, completion: @escaping (AccessTokenResult) -> Void){
        username = email
        loginService.login(email: email, password: password) {[weak self] result in
            switch result{
            case .success(let token):
                self?.tokenService.save(token: token)
            case .failure:
                ()
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
