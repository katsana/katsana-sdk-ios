//
//  KatsanaServicesTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class KatsanaServices{
    let client: URLSessionHTTPClient
    
    init(session: URLSession = URLSession(configuration: .ephemeral)) {
        self.client = URLSessionHTTPClient(session: session)
    }
    
    
}

final class KatsanaServicesTests: XCTestCase {

    func test() throws {
        
    }

}
