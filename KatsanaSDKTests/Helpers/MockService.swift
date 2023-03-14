//
//  MockService.swift
//  KatsanaSDKmacOSTests
//
//  Created by Wan Ahmad Lutfi on 30/01/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import URLMock
@testable import Siesta

class MockService{
    class func service() -> Service{
        UMKMockURLProtocol.reset()
        let testConfig = URLSessionConfiguration.ephemeral
        testConfig.protocolClasses = [UMKMockURLProtocol.self]
        
        
        return Service(baseURL: "https://api.katsana.com/", useDefaultTransformers: true, networking: testConfig)
    }
    
    class func mockResponse(path: String, expectedResponse: Any){
        UMKMockURLProtocol.expectMockHTTPGetRequest(with: URL(string: "https://api.katsana.com/\(path)")!, responseStatusCode: 200, responseJSON: expectedResponse)
    }
}
