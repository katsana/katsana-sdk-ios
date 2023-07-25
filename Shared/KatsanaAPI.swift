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
    public var tokenService: TokenService & TokenCache
    var username: String?
    
    public var onAuthenticated: ((Bool) -> ())?
    
    public lazy var httpClient: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    public lazy var loginService: LoginService = {
        let loginService = HTTPLoginService(baseURL: baseURL, credential: credential, httpClient: httpClient)
        return MainQueueDispatchDecorator(loginService)
    }()
    public lazy var publisherFactory: APIPublisherFactory = {
        let storeManager = ResourceStoreManager(delegate: self)
        let factory = APIPublisherFactory(baseURL: baseURL, baseStoreURL: localStoreURL, client: authenticatedClient(), storeManager: storeManager)
        return factory
    }()
    
    public var isAuthenticated: Bool{
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
                self?.onAuthenticated?(true)
            case .failure:
                ()
            }
            completion(result)
        }
    }
    
    public func logout(){
        username = nil
        tokenService.delete()
        onAuthenticated?(false)

    }
    
    // MARK:
    
    public func makeStore<Resource, S>(_ type: Resource.Type) -> KatsanaSDK.AnyResourceStore<Resource> where Resource : Decodable, Resource : Encodable, Resource : Equatable, S : KatsanaSDK.AnyResourceStore<Resource> {
        let classname = String(describing: Resource.self)
        let url = publisherFactory.baseStoreURL.appendingPathComponent(classname + ".store")
        let store = CodableResourceStore<Resource>(storeURL: url)
        let anyStore = AnyResourceStore(store)
        return anyStore
    }
    
    // MARK: Helper
    
    public func authenticatedClient() -> HTTPClient{
        return AuthenticatedHTTPClientDecorator(decoratee: httpClient, tokenService: tokenService)
    }
}


