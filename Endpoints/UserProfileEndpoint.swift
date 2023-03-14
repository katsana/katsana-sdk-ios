//
//  UserEndpoint.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public enum UserProfileEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/profile")
        }
    }
}

public protocol UserService{
    func getUserProfile(completion: Result<KTUser, Error>)
}

public protocol LoginService{
    func login(email: String, password: String, completion: Result<KTUser, Error>)
    func login(token: String, completion: Result<KTUser, Error>)
//    func loginJWT(name: String, password: String, nameKey: String = "email", authPath: String = "auth", completion: @escaping () -> Void, failure: @escaping (_ error: RequestError?) -> Void = {_ in })
}




