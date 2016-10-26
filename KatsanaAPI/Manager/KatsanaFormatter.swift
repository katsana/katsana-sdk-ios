//
//  Formatter.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import UIKit

@objc public enum DistanceFormat : Int {
    case kilometer
    case miles
}

class KatsanaFormatter: NSObject {
    static let knotToKMH : Double = 1.852
    static let knotToMPH : Double = 1.15078
    
    static var preferredDistanceFormat : DistanceFormat = .kilometer
    
    public class func speedStringFrom(knot: Double) -> String {
        return convertKnot(speed: knot, format: preferredDistanceFormat)
    }
    
    class func convertKnot(speed:Double, format:DistanceFormat) -> String {
        var speedString = ""
        switch preferredDistanceFormat {
        case .kilometer:
            speedString =  String(format: "%.0f km/h", speed * knotToKMH)
        case .miles:
            speedString =  String(format: "%.0f mp/h", speed * knotToMPH)
        }
        return speedString
    }
}
