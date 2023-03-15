//
//  UserMapperTests.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK

class UserMapperMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeJSON([:])
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try UserMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data("invalid json".utf8)

        XCTAssertThrowsError(
            try UserMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }


    func test_map_deliversItemsOn200HTTPResponseWithJSONItems() throws {
        let fleet = Fleet(fleetId: 2, name: "Main Fleet", deviceCount: 10)
        let fleet2 = Fleet(fleetId: 6, name: "Secondary Fleet", deviceCount: 2)
        
        let (item, json) = makeItem(id: 220, email: "developer-demo@katsana.com", fleets: [fleet, fleet2])
        let data = makeJSON(json)

        let result = try UserMapper.map(data, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result, item)
    }
    
    // MARK: - Helpers
        
    func makeJSON(_ item: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: item)
    }
    
    private func makeItem(id: Int,
                          email: String,
                          imageURL: String = "null",
                          plan: UserPlan? = nil,
                          fleets: [Fleet] = [],
                          createdAt: String = "2019-11-05 04:47:52",
                          updatedAt: String? = "2019-11-05 04:47:52") -> (model: KTUser, json: [String: Any]) {
        
        let item = KTUser(userId: "\(id)", email: email, imageURL: imageURL, plan: plan, fleets: fleets, createdAt: createdAt.date(gmt: 0)!, updatedAt: updatedAt?.date(gmt: 0))
        
        let fleetsDicto = makeFleetsJSONText(fleets, appending: ",")
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
        var json = convertStringToDictionary(text: text)!
        json["fleets"] = fleetsDicto
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
//        if let data = try? JSONSerialization.data(withJSONObject: ["fleets": theFleets]){
//            let text = String(data: data, encoding: String.Encoding.utf8)?.appending(appending)
//            return text
//        }else{
//            return nil
//        }
        
    }
    
    func convertStringToDictionary(text: String) -> [String:Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
}
