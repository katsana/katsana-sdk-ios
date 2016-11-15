//
//  KMTravelHistory+Extension.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

#if os(iOS)
///Currently, this extension no need to be used because ios <10 cannot use Measurement
extension KMTravelHistory{

    public func averageSpeedStringNew() -> String {
        let speed = self.averageSpeed()
        var speedStr = ""
        if #available(iOS 10.0, *) {
            let formatter = MeasurementFormatter()
            let speedMeasure  = Measurement(value: Double(speed), unit: UnitSpeed.knots)
            speedStr   = formatter.string(from: speedMeasure)
            print(speedStr)
        } else {
            // Fallback on earlier versions
        }
        return speedStr
    }
    
    public func distanceStringNew() -> String {
        let distance = self.distance
        var distanceStr = ""
        if #available(iOS 10.0, *) {
            let formatter = MeasurementFormatter()
            let distanceMeasure  = Measurement(value: Double(distance), unit: UnitLength.meters)
            distanceStr    = formatter.string(from: distanceMeasure)
            
            print(distanceStr)
        } else {
            // Fallback on earlier versions
        }
        return distanceStr
    }
    
    public func durationStringNew() -> String {
        let duration = self.duration
        var durationStr = ""
        if #available(iOS 10.0, *) {
            let formatter = MeasurementFormatter()
            let ddurationMeasure  = Measurement(value: Double(duration), unit: UnitDuration.seconds)
            durationStr    = formatter.string(from: ddurationMeasure)
            
            print(durationStr)
        } else {
            // Fallback on earlier versions
        }
        return durationStr
    }
    
}
#endif
