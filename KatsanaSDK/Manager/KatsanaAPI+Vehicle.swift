//
//  KMKatsanaAPI+Vehicle.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation

extension KatsanaAPI {

    /// Request vehicle given vehicleId. currentVehicle variable will be set from vehicle requested
    ///
    /// - parameter vehicleId:  vehicle id
    /// - parameter completion: completion
    public func requestVehicle(vehicleId: String, options: [String]! = nil, completion: @escaping (_ vehicle: Vehicle?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let cachedVehicle = vehicleWith(vehicleId: vehicleId)
        if (cachedVehicle != nil) {
            currentVehicle = cachedVehicle!
        }
        
        let path = "vehicles/" + vehicleId
        var resource = API.resource(path)
        
        //Check for options
        if let options = options {
            let text = options.joined(separator: ",")
            resource = resource.withParam("includes", text)
        }else if let options = defaultRequestVehicleOptions{
            let text = options.joined(separator: ",")
            resource = resource.withParam("includes", text)
        }
        
        let request = resource.loadIfNeeded()
        
        func handleResource() -> Void {
            let vehicle : Vehicle? = resource.typedContent()
            if cachedVehicle != nil, let vehicle = vehicle {
                cachedVehicle?.reload(with: vehicle)
                currentVehicle = cachedVehicle!
                if self.vehicleWith(vehicleId: vehicleId) == nil {
                    if self.vehicles == nil{
                        self.vehicles = [currentVehicle]
                    }else{
                        self.vehicles.append(currentVehicle)
                    }
                }
                
                completion(cachedVehicle)
                self.log.warning("Getting new instance of Vehicle because vehicle list still not loaded")
            }else{
                currentVehicle = vehicle!;
                completion(vehicle)
            }
        }
        
        request?.onSuccess({(entity) in
            handleResource()
        }).onFailure({ (error) in
            failure(error)
            self.log.error("Error getting vehicle id \(vehicleId), \(error)")
        })
        
        if request == nil { handleResource()}
        
    }
    
    /// Request all vehicles. vehicles variable will be set from the vehicles requested
    ///
    /// - parameter completion: completion
    public func requestAllVehicles(options:[String]! = nil, completion: @escaping (_ vehicles: [Vehicle]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        guard self.currentUser != nil else {
            failure(nil)
            return
        }
        
        let path = "vehicles"
        var resource = API.resource(path)
        
        //Check for options
        if let options = options {
            let text = options.joined(separator: ",")
            resource = resource.withParam("includes", text)
        }else if let options = defaultRequestVehicleOptions{
            let text = options.joined(separator: ",")
            resource = resource.withParam("includes", text)
        }
        let request = resource.loadIfNeeded()
        
        func handleResource() -> Void {
            let vehicles : [Vehicle]? = resource.typedContent()
            self.vehicles = vehicles
            if let vehicles = vehicles {
                CacheManager.shared.cache(vehicles: vehicles)
                
                let vehicleIds = vehicles.map({$0.vehicleId!})
                let combined = vehicleIds.joined(separator: ", ")
                self.log.info("Got vehicle id's \(combined)")
            }
            completion(vehicles)
        }
        
        request?.onSuccess({ (entity) in
            handleResource()
            }).onFailure({ (error) in
                failure(error)
                self.log.error("Error getting all vehicle list \(error)")
            })
        
        if request == nil {
            handleResource()
        }
    }
    
    public func requestVehicleLocation(vehicleId: String, completion: @escaping (_ vehicleLocation: VehicleLocation?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let path = "vehicles/" + vehicleId + "/location"
        let resource = API.resource(path);
        let request = resource.loadIfNeeded()
        let vehicle = vehicleWith(vehicleId: vehicleId)
        
        request?.onSuccess({ (entity) in
            let location : VehicleLocation? = resource.typedContent()
            vehicle?.current = location
            completion(location)
            }).onFailure({ (error) in
                failure(error)
                self.log.error("Error getting vehicle location vehicle id \(vehicleId), \(error)")
            })
        
        if request == nil {
            let location : VehicleLocation? = resource.typedContent()
            vehicle?.current = location
            completion(location)
        }
    }
    
    public func requestAllVehicleLocations(completion: @escaping (_ vehicles: [Vehicle]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        guard vehicles != nil else{
            return
        }
        
        for vehicle in vehicles {
            let vehicleId = vehicle.vehicleId
            var count = 0
            requestVehicleLocation(vehicleId: vehicleId!, completion: { (vehicleLocation) in
                vehicle.current = vehicleLocation
                count += 1
                
                if count == self.vehicles.count{
                    completion(self.vehicles)
                }
            })
        }
    }
    
    // MARK: Logic
    
    public func vehicleWith(vehicleId: String) -> Vehicle! {
        guard (vehicles != nil) else {
            self.log.warning("No vehicle given vehicle id \(vehicleId)")
            return nil
        }
        
        for vehicle in vehicles{
            if vehicle.vehicleId == vehicleId {
                return vehicle
            }
        }
        return nil
    }
    
}
