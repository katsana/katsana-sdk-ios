//
//  ResourceWithKeyLoader.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol ResourceWithKeyLoader {
    associatedtype RL
    
    func loadResource(from key: String) throws -> RL
}
