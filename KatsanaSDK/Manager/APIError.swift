//
//  Error.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 21/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation
import Siesta

struct SDKError {
    static let domain = "Katsana API Error Domain"
}

extension HTTPResult{
    func APIError() -> Error! {
        if !ok{
            if let content = content{
                let json = JSON(data:content)
                let message = json["message"].stringValue
                let statusCode = json["status_code"].intValue
                
                let userInfo: [String : String] = [ NSLocalizedDescriptionKey :  message, NSLocalizedFailureReasonErrorKey : message]
                let error = NSError(domain: SDKError.domain, code: statusCode, userInfo: userInfo)
                return error
            }
        }
        return nil
    }
}

extension RequestError: LocalizedError {
    public var errorDescription: String {
        if let content = entity?.content as? [String: Any]{
            if let description = content["error"] as? String{
                return description
            }
            for (_, value) in content{
                if let arr = value as? [String]{
                    return arr.first!
                }
            }
        }
        else if let content = entity?.content as? [String: String]{
            if let description = content["error"]{
                return description
            }
        }
        return self.userMessage
    }
}
