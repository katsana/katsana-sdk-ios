//
//  SharedTestHelpers.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 23/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation


extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }

    func adding(minutes: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .minute, value: minutes, to: self)!
    }

    func adding(days: Int, calendar: Calendar = Calendar(identifier: .gregorian)) -> Date {
        return calendar.date(byAdding: .day, value: days, to: self)!
    }
}

enum GenericError: Swift.Error{
    case invalidData
}

func convertStringToDictionary(text: String) throws -> [String:Any] {
    if let data = text.data(using: .utf8) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            if let json = json as? [String:AnyObject]{
                return json
            }else{
                print("sf")
            }
        } catch {
            throw error
        }
    }
    throw GenericError.invalidData
}

func convertStringToArray(text: String) throws -> [Any] {
    if let data = text.data(using: .utf8) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            if let json = json as? [AnyObject]{
                return json
            }
        } catch {
            throw error
        }
    }
    throw GenericError.invalidData
}
