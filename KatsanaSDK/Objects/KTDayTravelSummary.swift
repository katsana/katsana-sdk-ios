//
//  KTDayTravelSummary.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 03/05/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public struct KTDayTravelSummary: Codable, Equatable {
    
    public let date : Date
    public let distance : Double
    public let duration : Double
    public let idleDuration : Double
    public let maxSpeed : Double
    public let tripCount : Int
    public let violationCount: Int
    public let score: Double
    
}
