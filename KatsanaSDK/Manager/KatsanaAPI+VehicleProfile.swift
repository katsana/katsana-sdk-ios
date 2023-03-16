//
//  KatsanaAPI+VehicleProfile.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 17/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation
import Siesta

#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

extension KatsanaAPI {

    /// Save vehicle profile data
    ///
    /// 
    public func saveVehicleProfile(vehicleId: String, data: [String: Any], completion: @escaping (_ vehicle: KTVehicle?) -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in }) -> Void {
        let vehicle = vehicleWith(vehicleId: vehicleId)
        guard vehicle != nil else {
            return
        }

        let path = "vehicles/" + vehicleId
        let resource = self.API.resource(path)

        resource.request(.patch, json: data).onSuccess { entity in
            var insuranceExpiryChanged = false
            for (key, value) in data{
                if let value = value as? String{
                    if key == "license_plate"{
                        vehicle?.vehicleNumber = value
                    }
                    else if key == "description"{
                        vehicle?.vehicleDescription = value
                    }
                    else if key == "manufacturer"{
                        vehicle?.manufacturer = value
                    }
                    else if key == "model"{
                        vehicle?.model = value
                    }
                    else if key == "insured_by"{
                        vehicle?.insuredBy = value
                    }
                    else if key == "insured_expiry"{
                        if let insuredExpiry = vehicle?.insuredExpiry {
                            let dateStr = KTVehicle.dateFormatter.string(from: insuredExpiry)
                            if dateStr != value{
                                insuranceExpiryChanged = true
                            }
                        }
                        let date = KTVehicle.dateFormatter.date(from: value)
                        vehicle?.insuredExpiry = date
                    }
                }
            }

            if let vehicle = vehicle, let idx = self.vehicles.firstIndex(of: vehicle){
                self.vehicles[idx] = vehicle
            }
            if insuranceExpiryChanged{
                NotificationCenter.default.post(name: KatsanaAPI.insuranceExpiryDateChangedNotification, object: vehicle)
            }
            completion(vehicle)
        }.onFailure { (error) in
            failure(error)
            self.log?.error("Error save vehicle profile \(vehicleId), \(String(describing: error.errorDescription))")
        }
    }
    
    /// Save vehicle profile image. Function requestAllVehicles must be called first and the vehicle must be in the vehicle list
    ///
    /// - parameter vehicleId:  vehicle id
    /// - parameter image:      image to save
    /// - parameter completion: return vehicle
    public func saveVehicleProfileImage(vehicleId: String, image : KMImage?, completion: @escaping (_ vehicle: KTVehicle?) -> Void, failure: @escaping (_ error: Error?) -> Void = {_ in }) -> Void {
        let vehicle = vehicleWith(vehicleId: vehicleId)
        guard vehicle != nil else {
            return
        }
        
        var finalImage : KMImage!
        if image == nil {
            finalImage = KMImage(color: KMColor.white)!
        }else{
            finalImage = image
        }
        finalImage = finalImage.fixOrientation()
        
        var maxSize : CGFloat = 600
        #if os(iOS)
            let scale = UIScreen.main.scale
        #elseif os(OSX)
        let scale = (NSScreen.main?.backingScaleFactor)! as CGFloat
        #endif
        if scale > 1 {maxSize /= scale}
        
        if ((finalImage.size.width) > maxSize || (finalImage.size.height) > maxSize) {
            let factor = finalImage.size.width/finalImage.size.height;
            if (factor > 1) {
                finalImage = finalImage.scale(to: CGSize(width: maxSize, height: maxSize / factor))
            }else{
                finalImage = finalImage.scale(to: CGSize(width: maxSize * factor, height: maxSize))
            }
        }
        
        //Just put it although still not saved
        vehicle?.updateImage(finalImage)
        let path = self.baseURL().absoluteString + "vehicles/" + vehicleId + "/avatar"
        uploadImage(image: finalImage, path: path) { (success, error) in
            if success{
                completion(vehicle)
            }else{
                self.log?.error("Error save vehicle profile image \(vehicleId), \(String(describing: error))")
                failure(error)
            }
        }
    }
    
}
