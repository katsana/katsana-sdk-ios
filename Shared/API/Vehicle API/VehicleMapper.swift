//
//  VehicleMapper.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 16/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class VehiclesMapper{
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> [KTVehicle] {
        do{
            let json = try JSON(data: data)
            return mapJSON(json)
        }
        catch{
            throw Error.invalidData
        }
    }
    
    public static func mapJSON(_ json: JSON) -> [KTVehicle] {
        let arr = json["devices"].arrayValue
        let vehicles = arr.map(VehicleMapper.mapJSON)
        return vehicles
    }
}

public class VehicleMapper{
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> KTVehicle {
        do{
            let json = try JSON(data: data)
            let dicto = json["device"]
            return mapJSON(dicto)
        }
        catch{
            throw Error.invalidData
        }
    }
    
    public static func mapJSON(_ dicto: JSON) -> KTVehicle {
        
        let userId = dicto["user_id"].int
        let vehicleId = dicto["id"].intValue
        let imei = dicto["imei"].stringValue
        
        var fleetIds = [Int]()
        if let fleets = dicto["fleets"].array{
            for fleet in fleets{
                if let id = fleet.int{
                    fleetIds.append(id)
                }
            }
        }
        let features = dicto["features"].arrayObject as? [String]
        let websocketSupported = dicto["meta"]["websocket"].boolValue
        
        
        let vehicle = KTVehicle(vehicleId: vehicleId, userId: userId, imei: imei, fleetIds: fleetIds, features: features, websocketSupported: websocketSupported)

        vehicle.driver = dicto["live_status"]["driver"].string
        vehicle.mode = dicto["mode"].stringValue
        vehicle.timezone = dicto["timezone"].stringValue
        vehicle.todayMaxSpeed = dicto["today_max_speed"].floatValue
        vehicle.imageURL = dicto["avatar"].stringValue
        vehicle.thumbImageURL = dicto["marker"].stringValue
        vehicle.odometer = dicto["odometer"].doubleValue
        vehicle.earliestTravelDate = dicto["earliest_date"].dateWithoutTime
        
        if let val = dicto["sensors"]["temperature"]["value"].float{
            let status = dicto["sensors"]["temperature"]["status"].stringValue
            let temperature = TemperatureSensor(value: val, status: status)
            vehicle.temperatureSensor = temperature
        }
        if let val = dicto["sensors"]["fuel"]["capacity"].float{
            let litreText = dicto["sensors"]["fuel"]["litre"].stringValue
            var litre: Float = 0
            if let litreFloat = Float(litreText){
                litre = litreFloat
            }
            let fuelPercentage = dicto["sensors"]["fuel"]["percentage"].floatValue
            let status = dicto["sensors"]["fuel"]["status"].string
            
            let fuel = FuelSensor(litre: litre, percentage: fuelPercentage, capacity: val, status: status)
            vehicle.fuelSensor = fuel
        }
        
        
        if let sensors = dicto["sensors"]["others"].array{
            var theSensors = [Sensor]()
            for sensor in sensors{
                let event = sensor["event"].stringValue
                let input = sensor["input"].intValue
                let name = sensor["name"].stringValue
                var aSensorType = SensorType.other
                let sensorType = sensor["sensor"].stringValue
                if sensorType.lowercased() == "arm"{
                    aSensorType = .arm
                }else if sensorType.lowercased() == "door"{
                    aSensorType = .door
                }
                let deviceType = sensor["type"].stringValue
                
                let aSensor = Sensor(input: input, name: name, sensorType: aSensorType, event: event, deviceType: deviceType)
                theSensors.append(aSensor)
            }
            vehicle.sensors = theSensors
        }
        
        vehicle.vehicleNumber = dicto["vehicle_number"].stringValue
        if vehicle.vehicleNumber == "" {
            vehicle.vehicleNumber = dicto["license_plate"].stringValue
        }
        vehicle.vehicleDescription = dicto["description"].stringValue
        vehicle.manufacturer = dicto["manufacturer"].stringValue
        vehicle.model = dicto["model"].stringValue
        vehicle.insuredExpiry = dicto["insured"]["expiry"].date
        vehicle.insuredBy = dicto["insured"]["by"].stringValue
        
        vehicle.subscriptionEnd = dicto["ends_at"].date
        vehicle.current = ObjectJSONTransformer.VehicleLocationObject(json: dicto["current"])
        
        return vehicle
    }
}
