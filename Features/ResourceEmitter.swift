//
//  ResourceEmitter.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 07/08/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public protocol ResourceEmitter: AnyObject{
    associatedtype Resource
    var didEmitResource: ((Resource) -> Void)? { get set }
}

extension ResourceEmitter{
    public func eraseToAnyEmitter() -> AnyResourceEmitter<Resource>{
        return AnyResourceEmitter(wrappedLoader: self)
    }
}

public class AnyResourceEmitter<R>: NSObject, ResourceEmitter {
    public typealias Resource = R
    private let wrapped: Any

    public var didEmitResource: ((R) -> Void)?
    
    public init<L: ResourceEmitter>(wrappedLoader: L) where L.Resource == Resource {
        self.wrapped = wrappedLoader
        super.init()
        wrappedLoader.didEmitResource = vehicleEmitted
    }
    
    func vehicleEmitted(_ resource: R){
        didEmitResource?(resource)
    }
}
