//
//  MainQueueDispatchDecorator.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 06/07/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(_ decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: LoginService where T == LoginService{
    func login(email: String, password: String, completion: @escaping (AccessTokenResult) -> Void) {
        decoratee.login(email: email, password: password) {[weak self] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}
