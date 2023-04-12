//
//  KTTripSummary.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 12/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class KTTripSummary: Codable, Equatable {
    public let date: Date
    public let distance: CGFloat
    public let duration: CGFloat
    public let idleDuration: CGFloat
    public let maxSpeed: CGFloat
    public let tripCount: Int
    public let violationCount: Int
    public let score: CGFloat
    
    init(date: Date, distance: CGFloat, duration: CGFloat, idleDuration: CGFloat, maxSpeed: CGFloat, tripCount: Int, violationCount: Int, score: CGFloat) {
        self.date = date
        self.distance = distance
        self.duration = duration
        self.idleDuration = idleDuration
        self.maxSpeed = maxSpeed
        self.tripCount = tripCount
        self.violationCount = violationCount
        self.score = score
    }
    
    public static func == (lhs: KTTripSummary, rhs: KTTripSummary) -> Bool {
        return (lhs.date == rhs.date && lhs.distance == rhs.distance && lhs.duration == rhs.duration)
    }
}
