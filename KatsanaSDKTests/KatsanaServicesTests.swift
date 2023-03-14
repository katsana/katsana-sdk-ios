//
//  KatsanaServicesTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class KatsanaServices: UserService{
    let baseURL: URL
    let client: HTTPClient
    let userLoader: RemoteLoader<KTUser>
    
    init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
        userLoader = RemoteLoader(url: baseURL, client: client, mapper: UserMapper.map)
    }
    
    func getUserProfile(completion: Result<KatsanaSDK.KTUser, Error>) {
        
    }
    
    
}

final class KatsanaServicesTests: XCTestCase {

    func test() throws {
        
    }

}

//class KatsanaServicesSpy: KatsanaServices{
//    let client: URLSessionHTTPClient
//    
//    init(session: URLSession = URLSession(configuration: .ephemeral)) {
//        self.client = URLSessionHTTPClient(session: session)
//    }
//    
//    func getUserProfile(completion: Result<KTUser, Error>) {
//        
//    }
//    
//}
