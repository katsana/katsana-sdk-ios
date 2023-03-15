//
//  AuthenticatedHTTPClientDecorator.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

struct AccessToken{
    let token: String
}

class AuthenticatedHTTPClientDecorator: HTTPClient{
    let decoratee: HTTPClient
    var token: AccessToken?
    
    init(decoratee: HTTPClient) {
        self.decoratee = decoratee
    }
    
    func sign(_ accessToken: AccessToken){
        self.token = accessToken
    }
    
    func send(_ urlRequest: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        
        return Task()
    }
    
    private func signedRequest(for request: URLRequest) -> URLRequest{
        return request
    }
    
    class Task: HTTPClientTask{
        func cancel() {
            
        }
    }
    
    
}

final class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    
    func test(){
        let client = HTTPClientSpy()
        
        let signedRequest = URLRequest(url: anyURL())
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client)
        
//        sut.send(<#T##URLRequest#>, completion: <#T##(Result<(Data, HTTPURLResponse), Error>) -> Void#>)
        
//        XCTAssertEqual(client.requests, [signedRequest])
    }
    
    // MARK: Helpers
    
    func testRequest() -> URLRequest{
        return URLRequest(url: URL(string: "/test")!)
    }
    
//    private struct TestRequest{
//        var baseURL: URL { anyURL()}
//        var path: String { "/test"}
//    }
}
