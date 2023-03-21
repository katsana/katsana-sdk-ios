//
//  LoaderHelpers.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

extension XCTestCase{
    func makeUser(id: Int,
                          email: String,
                          imageURL: String = "null",
                          plan: UserPlan? = nil,
                          fleets: [Fleet]? = nil,
                          createdAt: String = "2019-11-05 04:47:52",
                          updatedAt: String? = "2019-11-05 04:47:52") -> (model: KTUser, json: [String: Any]) {
        
        let item = KTUser(userId: "\(id)", email: email, imageURL: imageURL, plan: plan, company: nil, fleets: fleets, createdAt: createdAt.date(gmt: 0)!, updatedAt: updatedAt?.date(gmt: 0))
        
        
        let planText = plan != nil ? """
                "plan": {
                    "name": "\(plan!.name)",
                    "description": "\(plan?.description ?? "null")",
                    "level": 3,
                    "type": "platform",
                    "price": 0,
                    "billing_cycle": 12,
                    "package": {
                        "name": "KATSANA Enterprise 2 Years",
                        "category": "On Boarding",
                        "price": 110000,
                        "billing_cycle": 24
                    }
                },
        """ : ""
        
        let text = """
    {
        "id": \(id),
        "email": "\(email)",
        "address": "Planet",
        "postcode": "",
        "state": "",
        "country": "",
        "gender": "male",
        "phone_home": "",
        "phone_mobile": "60123456789",
        "fullname": "Developer's Demo Account",
        "meta": {
            "emergency": {
                "fullname": "",
                "phone": {
                    "home": "",
                    "mobile": ""
                }
            }
        },
        "avatar": \(imageURL),
        "timezone": "Asia/Kuala_Lumpur",
        "roles": [
            "Member",
            "Fleet Owner",
            "Service Manager"
        ],
        "permissions": [
            "view track",
            "edit track",
            "view fleet",
            "manage fleet",
            "create fleet"
        ],
        "created_at": "\(createdAt)",
        "updated_at": "\(updatedAt ?? "null")",
        \(planText)
        "company": {
            "name": "Katsana Demo",
            "person_in_charges": {
                "name": "Aslam",
                "phone_number": "01238763459"
            }
        }
    }
"""
        var json = try! convertStringToDictionary(text: text)
        if let fleets{
            let fleetsDicto = makeFleetsJSONText(fleets, appending: ",")
            json["fleets"] = fleetsDicto
        }
        
        return (item, json)
    }
    
    func makeFleetsJSONText(_ fleets: [Fleet], appending: String = "") -> [[String: Any]]?{
        guard fleets.count > 0 else{
            return nil
        }
        
        var theFleets = [[String: Any]]()
        
        fleets.forEach { fleet in
            let json = [
                "id": fleet.fleetId,
                "name": fleet.name,
                "devices": fleet.deviceCount,
            ].compactMapValues { $0 }
            theFleets.append(json)
        }
        return theFleets
    }
    
    func makePartialVehicle(vehicleId: Int, userId: Int, imei: String) -> (model: KTVehicle, json: [String: Any]){
        let vehicle = KTVehicle(vehicleId: vehicleId, userId: userId, imei: imei)
        
        let json = [
            "id": vehicleId,
            "user_id": userId,
            "imei": imei,
        ].compactMapValues { $0 }
        return (vehicle, json)
    }
    
    
    // MARK: Helper
    
    enum GenericError: Swift.Error{
        case invalidData
    }
    
    func convertStringToDictionary(text: String) throws -> [String:Any] {
        if let data = text.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]{
                    return json
                }
            } catch {
                throw error
            }
        }
        throw GenericError.invalidData
    }
}
