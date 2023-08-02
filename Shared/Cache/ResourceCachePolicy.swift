//
//  ResourceCachePolicy.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public final class ResourceCachePolicy {

    private let calendar = Calendar(identifier: .gregorian)

    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    private let maxCacheAgeInSeconds: () -> Int
    
    public init(maxCacheAgeInSeconds: @escaping () -> Int){
        self.maxCacheAgeInSeconds = maxCacheAgeInSeconds
    }

    func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .second, value: maxCacheAgeInSeconds(), to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
    
    public static var defaultPolicy: ResourceCachePolicy{
        ResourceCachePolicy(maxCacheAgeInSeconds: {maxCacheAgeInDays*24*60*60})
    }
    
    public static var infinity: ResourceCachePolicy{
        ResourceCachePolicy(maxCacheAgeInSeconds: {100000*24*60*60})
    }
}
