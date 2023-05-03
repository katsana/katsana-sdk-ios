//
//  Travel+Extension.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 18/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation

///Currently, this extension no need to be used because ios <10 cannot use Measurement
extension KTDayTravel{

    public func averageSpeedStringNew() -> String {
        let speed = self.averageSpeed()
        var speedStr = ""
        let formatter = MeasurementFormatter()
        let speedMeasure  = Measurement(value: Double(speed), unit: UnitSpeed.knots)
        speedStr   = formatter.string(from: speedMeasure)
        return speedStr
    }
    
    public func distanceStringNew() -> String {
        let distance = self.distance
        var distanceStr = ""
        let formatter = MeasurementFormatter()
        let distanceMeasure  = Measurement(value: Double(distance), unit: UnitLength.meters)
        distanceStr    = formatter.string(from: distanceMeasure)
        return distanceStr
    }
    
    public func durationStringNew() -> String {
        let duration = self.duration
        var durationStr = ""
        let formatter = MeasurementFormatter()
        let ddurationMeasure  = Measurement(value: Double(duration), unit: UnitDuration.seconds)
        durationStr    = formatter.string(from: ddurationMeasure)
        return durationStr
    }
    
}
