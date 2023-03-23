//
//  ResourceCache.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol ResourceCache {
    associatedtype SaveResource
    typealias SaveResult = Result<Void, Error>

    func save(_ resource: SaveResource, completion: @escaping (SaveResult) -> Void)
}
