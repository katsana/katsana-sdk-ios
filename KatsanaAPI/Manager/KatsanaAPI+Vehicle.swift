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
    public func requestVehicle(vehicleId: String, completion: @escaping (_ vehicle: KMVehicle?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let vehicle = vehicleWith(vehicleId: vehicleId)
        if (vehicle != nil) {
            currentVehicle = vehicle!;
        }
        
        let path = "vehicles/" + vehicleId
        let resource = API.resource(path);
        resource.loadIfNeeded()?.onSuccess({ [weak self] (entity) in
            let vehicle : KMVehicle? = resource.typedContent()
            self?.currentVehicle = vehicle;
            completion(vehicle)
        }).onFailure({ (error) in
            failure(error)
        })
    }
    
    /// Request all vehicles. vehicles variable will be set from the vehicles requested
    ///
    /// - parameter completion: completion
    public func requestAllVehicles(completion: @escaping (_ vehicles: [KMVehicle]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let path = "vehicles"
        let resource = API.resource(path);
        resource.loadIfNeeded()?.onSuccess({ [weak self] (entity) in
            let vehicles : [KMVehicle]? = resource.typedContent()
            self?.vehicles = vehicles
            completion(vehicles)
            }).onFailure({ (error) in
                failure(error)
            })
    }
    
    public func requestVehicleLocation(vehicleId: String, completion: @escaping (_ vehicleLocation: KMVehicleLocation?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let path = "vehicles/" + vehicleId + "/location"
        let resource = API.resource(path);
        resource.loadIfNeeded()?.onSuccess({ (entity) in
            let location : KMVehicleLocation? = resource.typedContent()
            completion(location)
            }).onFailure({ (error) in
                failure(error)
            })
    }
    
    public func requestAllVehicleLocations(completion: @escaping (_ vehicles: [KMVehicle]?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
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
    
    public func vehicleWith(vehicleId: String) -> KMVehicle! {
        guard (vehicles != nil) else {
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
