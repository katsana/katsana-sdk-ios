//
//  UserMapper.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class UserMapper{
    private struct Root: Decodable {
        let id: Int
        let email: String
        
        var user: KTUser {
            KTUser(email: email)
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map(_ data: Data, from response: HTTPURLResponse) throws -> KTUser {
        guard response.isOK else{
            throw Error.invalidData
        }
        
        do{
            let root = try JSONDecoder().decode(Root.self, from: data)
            return root.user
        }
        catch{
            throw Error.invalidData
        }
        

        
    }
}
