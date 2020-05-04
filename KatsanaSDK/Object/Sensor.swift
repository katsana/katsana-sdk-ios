//
//  Sensor.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 30/04/2020.
//  Copyright © 2020 pixelated. All rights reserved.
//


@objc public enum SensorType: Int{
    case arm
    case door
    case other
}

@objcMembers
open class Sensor: NSObject {
    
    
    var input: Int = -1
    var name = ""
    var sensorType: SensorType = .other
    var event: String!
    var deviceType: String!
    
    
}

//"event" : "in-active",
//"value" : false,
//"input" : 3,
//"name" : "Arm",
//"sensor" : "Arm",
//"type" : "NC"
