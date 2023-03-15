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
    
    public enum Error: Swift.Error {
        case unauthorized
    }
    
    class EmptyTask: HTTPClientTask{
        func cancel() {}
    }
    
    init(decoratee: HTTPClient) {
        self.decoratee = decoratee
    }
    
    func sign(_ accessToken: AccessToken){
        self.token = accessToken
    }
    
    func send(_ urlRequest: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        do{
            let signedRequest = try self.signedRequest(for: urlRequest)
            return decoratee.send(signedRequest, completion: completion)
        }
        catch{
            completion(.failure(error))
            return EmptyTask()
        }
    }
    
    func signedRequest(for request: URLRequest) throws -> URLRequest{
        guard let token else {
            throw Error.unauthorized
        }
        
        var updatedRequest = request
        updatedRequest.setValue("Bearer \(token.token)", forHTTPHeaderField: "Authorization ")
        return request

    }
    
}

final class AuthenticatedHTTPClientDecoratorTests: XCTestCase {
    
    func test_sendRequest_withNoTokenReturnEmptyRequest(){
        let client = HTTPClientSpy()
        let unsignedRequest = testRequest()
        
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client)
        _ = sut.send(unsignedRequest, completion: {_ in})
        
        XCTAssertEqual(client.requests, [])
    }
    
    func test_sendRequest_withTokenReturnRequest(){
        let client = HTTPClientSpy()
        let request = testRequest()
        
        let sut = AuthenticatedHTTPClientDecorator(decoratee: client)
        sut.sign(AccessToken(token: "anyToken"))
        let signedRequest = try? sut.signedRequest(for: request)
        
        _ = sut.send(request, completion: {_ in})
        
        XCTAssertEqual(client.requests, [signedRequest])
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
