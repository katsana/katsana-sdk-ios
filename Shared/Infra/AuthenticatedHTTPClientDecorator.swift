//
//  AuthenticatedHTTPClientDecorator.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public struct AccessToken{
    public let token: String
    
    public init(token: String) {
        self.token = token
    }
}

public class AuthenticatedHTTPClientDecorator: HTTPClient{
    private let decoratee: HTTPClient
    private var token: AccessToken?
    
    public enum Error: Swift.Error {
        case unauthorized
    }
    
    class EmptyTask: HTTPClientTask{
        func cancel() {}
    }
    
    public init(decoratee: HTTPClient) {
        self.decoratee = decoratee
    }
    
    public func sign(_ accessToken: AccessToken){
        self.token = accessToken
    }
    
    public func send(_ urlRequest: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        do{
            let signedRequest = try self.signedRequest(for: urlRequest)
            return decoratee.send(signedRequest, completion: completion)
        }
        catch{
            completion(.failure(error))
            return EmptyTask()
        }
    }
    
    public func signedRequest(for request: URLRequest) throws -> URLRequest{
        guard let token else {
            throw Error.unauthorized
        }
        
        var updatedRequest = request
        updatedRequest.setValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization ")
        return request

    }
    
}
