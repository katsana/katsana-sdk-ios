//
//  Sensor.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 30/04/2020.
//  Copyright © 2020 pixelated. All rights reserved.
//


public enum SensorType: Codable{
    case arm
    case door
    case other
}

open class Sensor: Codable {
    open var input: Int = -1
    open var name = ""
    open var sensorType: SensorType = .other
    open var event: String?
    open var deviceType: String?
    
    public func title() -> String {
        switch sensorType {
        case .arm:
            return "arm"
        case .door:
            return "door"
        default:
            return ""
        }
    }
    
}

//"event" : "in-active",
//"value" : false,
//"input" : 3,
//"name" : "Arm",
//"sensor" : "Arm",
//"type" : "NC"
