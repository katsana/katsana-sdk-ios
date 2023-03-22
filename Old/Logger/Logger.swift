//
//  Logger.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 30/01/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol Logger{
    func info(_ text: String)
    func error(_ text: String)
    func verbose(_ text: String)
    func warning(_ text: String)
    func debug(_ text: String)
    
}
