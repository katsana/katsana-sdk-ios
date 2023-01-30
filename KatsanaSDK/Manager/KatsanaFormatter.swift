//
//  Formatter.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 26/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//


@objc public enum DistanceFormat : Int {
    case kilometer
    case miles
}

@objc public enum DisplayFormat : Int {
    case short
    case full
    case hourShort
    case hourOrMinuteOnly
}

public class KatsanaFormatter {
    public static let knotToKMH : Double = 1.852
    public static let knotToMPH : Double = 1.15078
    
    static var distanceFormat : DistanceFormat = .kilometer
    static var displayFormat : DisplayFormat = .short
    static var numberDistanceFormatter : NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    public class func localizedSpeedString(knot: Double) -> String {
        var speed : String!
        switch distanceFormat {
        case .kilometer:
            speed =  String(format:"%.0fkm/h", knot * knotToKMH)
        case .miles:
            speed =  String(format:"%.0fkm/h", knot * knotToMPH)
        }
        return speed
    }
    
    public class func localizedSpeed(knot: Double) -> Double {
        let speed : Double
        switch distanceFormat {
        case .kilometer:
            speed =  knot * knotToKMH
        case .miles:
            speed =  knot * knotToMPH
        }
        return speed
    }
    
    public class func speedStringFrom(knot: Double) -> String {
        return convertKnot(speed: knot, format: distanceFormat)
    }

    public class func speedSuffixString() -> String {
        var speedString = ""
        switch distanceFormat {
        case .kilometer:
            speedString =  "km/h"
        case .miles:
            speedString =  "mp/h"
        }
        return speedString
    }
    
    public class func durationStringFrom(seconds: Double) -> String {
        return convertTime(seconds: seconds, displayFormat: displayFormat)
    }
    
    public class func durationStringUsingFormat(format:DisplayFormat,  duration: Double) -> String {
        return convertTime(seconds: duration, displayFormat: format)
    }
    
    public class func distanceStringFrom(meter: Double, useFraction: Bool = true) -> String {
        var distance = "0 m"
        switch distanceFormat {
        case .kilometer:
            if meter < 1000 {
                distance = String(format: "%.0f m", meter)
            }else{
                numberDistanceFormatter.maximumFractionDigits = 0
                distance = String(format: "%@ km", numberDistanceFormatter.string(from: NSNumber(value: meter/1000.0))!)
            }
        case .miles:
            if useFraction{
                numberDistanceFormatter.maximumFractionDigits = 1
            }else{
                numberDistanceFormatter.maximumFractionDigits = 0
            }
            distance = String(format: "%@ mi", numberDistanceFormatter.string(from: NSNumber(value: meter*0.000621371))!)
        }
        return distance
    }
    
//    public class func distanceStringFromUsing(format:DisplayFormat, meter: Double) -> String {
//        var distance = ""
//        if meter < 1000 {
//            distance = String(format: "%.0f m", meter)
//        }else{
//            switch distanceFormat {
//            case .kilometer:
//                distance = String(format: "%.0f km", meter/1000.0)
//            case .miles:
//                distance = String(format: "%.0f mi", meter*0.000621371)
//            }
//        }
//        return distance
//    }
    
    // MARK: Objective C compatibility
    
    public class func currentDistanceFormat() -> DistanceFormat {
        return distanceFormat
    }
    
    public class func setCurrentDistanceFormat(format:DistanceFormat ) -> Void {
        distanceFormat = format
    }
    
    
    // MARK: Private
    
    class func convertKnot(speed:Double, format:DistanceFormat) -> String {
        var speedString = ""
        switch distanceFormat {
        case .kilometer:
            speedString =  String(format: "%.0f km/h", speed * knotToKMH)
        case .miles:
            speedString =  String(format: "%.0G mp/h", speed * knotToMPH)
        }
        return speedString
    }
    
    class func convertTime(seconds:Double, displayFormat:DisplayFormat) -> String {
        let transformer = TimeTransformer()
        transformer.displayFormat = displayFormat
        if let time = transformer.transformedValue(seconds) as? String{
            return time
        }
        return ""
    }
}
