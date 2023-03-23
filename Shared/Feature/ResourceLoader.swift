//
//  ResourceLoader.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol ResourceLoader{
    associatedtype Resource
    typealias Result = Swift.Result<Resource, Swift.Error>
    
    func load(completion: @escaping (Result) -> Void)
}
