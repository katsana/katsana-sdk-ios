//
//  Sensor.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 30/04/2020.
//  Copyright © 2020 pixelated. All rights reserved.
//


public enum SensorType: Codable, Equatable{
    case arm
    case door
    case other
}

public class Sensor: Codable {
    public let input: Int
    public let name: String
    public let sensorType: SensorType
    public let event: String
    public let deviceType: String
    
    init(input: Int, name: String, sensorType: SensorType, event: String, deviceType: String) {
        self.input = input
        self.name = name
        self.sensorType = sensorType
        self.event = event
        self.deviceType = deviceType
    }
    
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
