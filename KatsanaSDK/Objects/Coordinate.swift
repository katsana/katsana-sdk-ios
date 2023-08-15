//
//  Coordinate.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public struct Coordinate: Equatable{
    static private let epsilon = 0.005
    
    public let latitude: Double
    public let longitude: Double
    
    public init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool{
        if fabs(lhs.latitude - rhs.latitude) < Coordinate.epsilon && fabs(lhs.longitude - rhs.longitude) < Coordinate.epsilon {
            return true
        }
        return false
    }
    
    public func stringRepresentation() -> String{
        return String(format: "(%.4f, %.4f)", latitude, longitude)
    }
}
