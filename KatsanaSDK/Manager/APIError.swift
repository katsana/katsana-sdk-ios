//
//  Error.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 21/10/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

import Foundation
import Siesta

enum KatsanaAPIError: Error {
    case clientError([String])
    case unknownError
    case invalidParsedObject(String)
    case invalidToken
    case error(Error)
    case notFound
}

extension KatsanaAPIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .clientError(let values):
            let text = values.joined(separator: ", ")
            return NSLocalizedString(text, comment: "Client Error")
        case .unknownError:
            return NSLocalizedString("Unknown error", comment: "Unknown Error")
        case .notFound:
            return NSLocalizedString("Not found", comment: "Not found Error")
        case .invalidParsedObject(let text):
            return NSLocalizedString("Invalid parsed object", comment: "Invalid parsed object")
        case .invalidToken:
            return NSLocalizedString("Invalid token", comment: "Invalid token")
        case .error(let error):
            if error.localizedDescription.count > 0{
                return error.localizedDescription
            }
            else if let error = error as? RequestError{
                let text = error.userMessage
                return text
            }
            return error.localizedDescription
        }
    }
}

struct SDKError {
    static let domain = "Katsana API Error Domain"
}

public extension HTTPResult{
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
            if let description = content["message"] as? String{
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
