//
//  KatsanaAPITests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import Combine
@testable import KatsanaSDK

class KatsanaAPI{
    let baseURL: URL
    let credential: Credential
    let httpClient: HTTPClient
    let tokenService: TokenService
    var loginService: LoginService
    
    var isAuthenticated = false
    
    private var cancellable: Cancellable?
    
    init(baseURL: URL, credential: Credential, httpClient: HTTPClient, tokenService: TokenService) {
        self.baseURL = baseURL
        self.credential = credential
        self.httpClient = httpClient
        self.tokenService = tokenService
        loginService = HTTPLoginService(baseURL: baseURL, credential: credential, httpClient: httpClient)
    }
    
    func login(email: String, password: String, completion: @escaping (AccessTokenResult) -> Void){
        loginService.login(email: email, password: password) {[weak self] result in
            switch result{
            case .success(let token):
                self?.isAuthenticated = true
            case .failure(let error):
                self?.isAuthenticated = false
            }
            completion(result)
        }
    }
    
    private func makeLoginPublisher(username: String, password: String, credential: Credential) -> AnyPublisher<AccessToken, Error>{
        let url = LoginEndpoint.get.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? credential.data()
        return httpClient
            .getPublisher(urlRequest: request)
            .tryMap(LoginMapper.map)
//            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}

final class KatsanaAPITests: XCTestCase {
    
    func test_init_isNotAuthenticated() {
        let (sut, _) = makeSUT()
        XCTAssertFalse(sut.isAuthenticated)
    }
    
    func test_login_changeToAuthenticatedWhenSuccess() {
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.login(email: "test", password: "1212") { result in
            if let _ = try? result.get(){
                //Do nothing
            }else{
                XCTFail("Expected to success")
            }
            exp.fulfill()
        }
        client.complete(withStatusCode: 200, data: loginData())
        wait(for: [exp], timeout: 1.0)
        XCTAssertTrue(sut.isAuthenticated)
    }
    
    func test_login_doesNotAuthenticateWhenFailure() {
        let tokenStub = TokenServiceStub(stub: .failure(anyNSError()))
        let (sut, client) = makeSUT(tokenService: tokenStub)
        
        let exp = expectation(description: "Wait for load completion")
        sut.login(email: "test", password: "wrongPass") { result in
            if let _ = try? result.get(){
                XCTFail("Expected to fail")
            }
            exp.fulfill()
        }
        client.complete(with: anyNSError())
        wait(for: [exp], timeout: 1.0)
        XCTAssertFalse(sut.isAuthenticated)
    }
    
    // MARK: Helper
    
    func makeSUT(tokenService: TokenService? = nil) -> (KatsanaAPI, HTTPClientSpy){
        let theTokenService = tokenService ?? TokenServiceStub(stub: .success(AccessToken(token: "any")))
        let credential = Credential(clientId: "", clientSecret: "", scope: "", grantType: "")
        let client = HTTPClientSpy()

        let sut = KatsanaAPI(baseURL: anyURL(), credential: credential, httpClient: client, tokenService: theTokenService)
        return (sut, client)
    }
    
    func loginData() -> Data{
        let text = """
{"token_type":"Bearer","expires_in":31622400,"access_token":"aTokenString","refresh_token":"aRefreshTokenString"}
"""
        return Data(text.utf8)
    }
    
}
