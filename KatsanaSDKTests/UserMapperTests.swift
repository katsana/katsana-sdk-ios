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
        let (item, json) = makeItem(id: 220, email: "developer-demo@katsana.com")
        let data = makeJSON(json)

        let result = try UserMapper.map(data, from: HTTPURLResponse(statusCode: 200))

        XCTAssertEqual(result.email, item.email)
    }
    
    // MARK: - Helpers
        
    func makeJSON(_ item: [String: Any]) -> Data {
        return try! JSONSerialization.data(withJSONObject: item)
    }
    
    private func makeItem(id: Int, email: String) -> (model: KTUser, json: [String: Any]) {
        let item = KTUser(userID: "\(id)", email: email)
        
        let text = "{\"id\":\(id),\"email\":\"\(email)\",\"address\":\"Planet\",\"postcode\":\"\",\"state\":\"\",\"country\":\"\",\"gender\":\"male\",\"phone_home\":\"\",\"phone_mobile\":\"60123456789\",\"fullname\":\"Developer's Demo Account\",\"meta\":{\"emergency\":{\"fullname\":\"\",\"phone\":{\"home\":\"\",\"mobile\":\"\"}}},\"avatar\":null,\"timezone\":\"Asia Kuala_Lumpur\",\"roles\":[\"Member\",\"Fleet Owner\",\"Service Manager\"],\"permissions\":[\"view track\",\"edit track\",\"view fleet\",\"manage fleet\",\"create fleet\",\"create fleet manager\",\"create driver\",\"view policy\",\"create policy\",\"view advance policy\",\"create advance policy\",\"view report\",\"view maintenance\",\"create maintenance\",\"edit maintenance\",\"notification maintenance\",\"view stream\",\"view compliance\",\"edit compliance\"],\"created_at\":\"2019-11-05 04:47:52\",\"updated_at\":\"2023-02-14 03:26:17\",\"fleets\":[{\"id\":26,\"name\":\"Main Fleet\",\"devices\":3},{\"id\":27,\"name\":\"TSH Test\",\"devices\":6},{\"id\":28,\"name\":\"Temperature\",\"devices\":2},{\"id\":30,\"name\":\"Door Sensor\",\"devices\":2},{\"id\":31,\"name\":\"ETIQA 1\",\"devices\":0},{\"id\":34,\"name\":\"RFID Tag\",\"devices\":8},{\"id\":37,\"name\":\"Test 21\",\"devices\":1},{\"id\":39,\"name\":\"EV ALL\",\"devices\":7}],\"plan\":{\"name\":\"KATSANA Enterprise\",\"description\":\"KATSANA Enterprise\",\"level\":3,\"type\":\"platform\",\"price\":0,\"billing_cycle\":12,\"package\":{\"name\":\"KATSANA Enterprise 2 Years\",\"category\":\"On Boarding\",\"price\":110000,\"billing_cycle\":24}},\"company\":{\"name\":\"Katsana Demo\",\"person_in_charges\":{\"name\":\"Aslam\",\"phone_number\":\"01238763459\"}}}"
        let json = convertStringToDictionary(text: text)!
        
        return (item, json)
    }
    
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
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
