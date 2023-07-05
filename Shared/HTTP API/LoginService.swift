//
//  LoginService.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 05/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol LoginService{
    func login(email: String, password: String, completion: @escaping (AccessTokenResult) -> Void)
}
