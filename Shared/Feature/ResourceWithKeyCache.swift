//
//  ResourceWithKeyCache.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol ResourceWithKeyCache {
    associatedtype R
    
    func save(_ resource: R, for key: String) throws
}
