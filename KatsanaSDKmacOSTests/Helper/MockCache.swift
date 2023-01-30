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
    var writeToDisk = false
    
    init(writeToDisk: Bool = false) {
        self.writeToDisk = writeToDisk
    }
    
    override func cacheDataFilename() -> String {
        return "mockCacheData.dat"
    }
    
    override func cacheAddressDataFilename() -> String {
        return "mockCacheAddress.dat"
    }
    
    override func cacheTravelsDataFilename() -> String {
        return "mockTravel.dat"
    }
    
    override func cacheActivitiesDataFilename() -> String {
        return "mockCacheActivities.dat"
    }
    
    override func cacheLiveShareFilename() -> String {
        return "mockCacheLiveShare.dat"
    }
    
    
    func loadCachedUser() -> KTUser!{
        if let data = loadCachedData(){
            if let user = data[NSStringFromClass(KTUser.self)] as? KTUser{
                return user
            }
        }
        return nil
    }
    
    // MARK: Save
    
    override func autoSave(forceSave: Bool = false) {
        if writeToDisk{
            super.autoSave(forceSave: true)
        }
    }
    
}
