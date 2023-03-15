//
//  Fleet.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 06/05/2020.
//  Copyright © 2020 pixelated. All rights reserved.
//
import Foundation

public struct Fleet: Codable, Equatable {
    public let fleetId: Int
    public let name: String
    public let deviceCount: Int
    
    public init(fleetId: Int, name: String, deviceCount: Int) {
        self.fleetId = fleetId
        self.name = name
        self.deviceCount = deviceCount
    }
}
