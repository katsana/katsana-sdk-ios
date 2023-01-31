//
//  KMKatsanaAPI+Vehicle.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 13/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation
import Siesta

extension KatsanaAPI {

    /// Request vehicle given vehicleId. currentVehicle variable will be set from vehicle requested
    ///
    /// - parameter vehicleId:  vehicle id
    /// - parameter completion: completion
    public func requestVehicle(vehicleId: String, options: [String]! = nil, completion: @escaping (_ vehicle: KTVehicle?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let cachedVehicle = vehicleWith(vehicleId: vehicleId)
        if (cachedVehicle != nil) {
            currentVehicle = cachedVehicle!
        }
        
        guard authToken != nil else {
            failure(nil)
//            self.log.warning("Auth token is nil")
            return
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
            let vehicle : KTVehicle? = resource.typedContent()
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
                self.log.warning("Getting new instance of KTVehicle because vehicle list still not loaded")
            }else{
                if let vehicle = vehicle{
                    currentVehicle = vehicle
                    completion(vehicle)
                }else{
                    failure(nil)
                }
            }
        }
        
        request?.onSuccess({(entity) in
            handleResource()
        }).onFailure({ (error) in
            failure(error)
            self.error("Error getting vehicle id \(vehicleId), \(error)", identifier: "errorVehicleId", duration: 60*3)
        })
        
        if request == nil { handleResource()}
        
    }
    
    /// Request all vehicles. vehicles variable will be set from the vehicles requested
    ///
    /// - parameter completion: completion
    public func requestAllVehicles(options:[String]! = nil, completion: @escaping (_ vehicles: [KTVehicle]?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        guard authToken != nil else {
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
            let vehicles : [KTVehicle]? = resource.typedContent()
            if let vehicles = vehicles{
                for vehicle in vehicles {
                    if let cachedVehicle = vehicleWith(vehicleId: vehicle.vehicleId){
                        vehicle.reloadVideoRecordingData(with: cachedVehicle)
                    }
                }
            }
            
            self.vehicles = vehicles
            if let vehicles = vehicles {
                self.cache?.cache(vehicles: vehicles, userId: self.currentUser?.userId ?? "0")
                
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
    
    public func requestVehicleLocation(vehicleId: String, completion: @escaping (_ vehicleLocation: VehicleLocation?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
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
    
    public func requestAllVehicleLocations(completion: @escaping (_ vehicles: [KTVehicle]?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
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
    
    public func checkVehicleAvailable(vehicleToken: String, completion: @escaping (_ available: Bool) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "track/availability"
        let resource = API.resource(path);
        
        let data = ["activation": vehicleToken]
        
        resource.request(.post, json: data).onSuccess { (entity) in
            if let content = entity.content as? JSON{
                let valid = content["status"].boolValue
                completion(valid)
            }else{
                completion(false)
            }
        }.onFailure { (error) in
            
            if let content = error.entity?.content as? [String: Any], let valid = content["status"] as? Bool {
                completion(valid)

            }else{
                failure(error)
                self.log.error("Error checking vehicle availability \(error)")
            }
        }
    }
    
    public func registerVehicle(vehicleToken: String, vehicleData: [String: String], userData: [String: String]! = nil, completion: @escaping (_ vehicle: KTVehicle?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "track/register"
        let resource = API.resource(path);
        
        var theData = [String: Any]()
        theData["activation"] = vehicleToken
        theData["vehicle"] = vehicleData
        if let userData = userData{
            theData["user"] = userData
        }

        resource.request(.post, json: theData).onSuccess { (entity) in
            let vehicle : KTVehicle? = resource.typedContent()
            if let vehicle = vehicle{
                self.vehicles?.append(vehicle)
                completion(vehicle)
            }else{
                completion(nil)
            }
            }.onFailure { (error) in
                if let content = error.entity?.content as? [String: Any], let errors = content.first?.value as? [String], let first = errors.first {
                    let error = RequestError(userMessage: first, cause: error)
                    failure(error)
                }else{
                    failure(error)
                }
                self.log.error("Error register vehicle \(String(describing: error.errorDescription))")
        }
    }
    
    public func requestInsurers(completion: @escaping (_ insurers: [KTInsurer]) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let path = "insurers/my"
        let resource = API.resource(path);
        let request = resource.loadIfNeeded()
        
        request?.onSuccess({ (entity) in
            let insurers : [KTInsurer]? = resource.typedContent()
            completion(insurers!)
        }).onFailure({ (error) in
            failure(error)
            self.log.error("Error getting insurers")
        })
        
        if request == nil {
            let insurers : [KTInsurer]? = resource.typedContent()
            completion(insurers!)
        }
    }
    
    // MARK: Logic
    
    public func vehicleWith(vehicleId: String) -> KTVehicle! {
        guard (vehicles != nil) else {
//            self.log.info("No vehicle given vehicle id \(vehicleId)")
            return nil
        }
        
        for vehicle in vehicles{
            if let id = vehicle.vehicleId, id == vehicleId {
                return vehicle
            }
        }
        return nil
    }
    
    ///Get latest cached travel locations from today to previous day count
    public func cachedVehicles(userId : String) -> [KTVehicle]! {
        return self.cache?.vehicles(userId:userId)
    }
    
    public func wipeResources(vehicleId: String){
        API.wipeResources(matching: "vehicles/" + vehicleId)
    }
    
}
