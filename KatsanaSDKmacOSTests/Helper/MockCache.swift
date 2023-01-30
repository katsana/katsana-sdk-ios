//
//  MockCache.swift
//  KatsanaSDKmacOSTests
//
//  Created by Wan Ahmad Lutfi on 30/01/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
@testable import KatsanaSDK

class MockCache: KTCacheManager{
    override func cacheDataFilename() -> String {
        return "mockCacheData.dat"
    }
}
