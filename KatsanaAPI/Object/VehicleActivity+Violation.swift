//
//  VehicleActivity+Violation.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 25/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation

extension VehicleActivity{
    
    func violationTitle() -> String{
        var text = ""
        switch activityType {
        case .speed:
            text = "OVERSPEEDING"
        case .time:
            text = "MOVEMENT"
        case .batteryCutoff:
            text = "BATTERY-CUTOFF"
        case .area:
            text = "AREA"
        default:
            ()
        }
        return text
    }
}
