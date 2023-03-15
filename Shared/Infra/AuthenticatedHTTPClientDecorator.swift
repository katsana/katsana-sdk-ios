//
//  AuthenticatedHTTPClientDecorator.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class AuthenticatedHTTPClientDecorator: HTTPClient{
    private let decoratee: HTTPClient
    private let tokenService: TokenService
    
    public enum Error: Swift.Error {
        case unauthorized
    }
    
    class EmptyTask: HTTPClientTask{
        func cancel() {}
    }
    
    private final class HTTPClientTaskWrapper: HTTPClientTask {
        private var completion: ((HTTPClient.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (HTTPClient.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: HTTPClient.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public init(decoratee: HTTPClient, tokenService: TokenService) {
        self.decoratee = decoratee
        self.tokenService = tokenService
    }
    
    public func send(_ urlRequest: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = HTTPClientTaskWrapper(completion)
        
        tokenService.getToken { result in
            switch result{
            case let .success(token):
                let signedRequest = self.signedRequest(for: urlRequest, token: token)
                task.wrapped = self.decoratee.send(signedRequest, completion: {theResult in
                    task.complete(with: theResult)
                })
            case let .failure(error):
                task.complete(with: .failure(error))
            }
        }
        return task
    }
    
    public func signedRequest(for request: URLRequest, token: AccessToken) -> URLRequest{
        
        var updatedRequest = request
        updatedRequest.setValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization ")
        return request

    }
    
}
