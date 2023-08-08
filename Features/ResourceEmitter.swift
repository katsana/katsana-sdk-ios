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
    var didEmitVehicle: ((Resource) -> Void)? { get set }
}

extension ResourceEmitter{
    public func eraseToAnyEmitter() -> AnyResourceEmitter<Resource>{
        return AnyResourceEmitter(wrappedLoader: self)
    }
}

public class AnyResourceEmitter<R>: NSObject, ResourceEmitter {
    public typealias Resource = R
    private let wrapped: Any

    public var didEmitVehicle: ((R) -> Void)?
    
    public init<L: ResourceEmitter>(wrappedLoader: L) where L.Resource == Resource {
        self.wrapped = wrappedLoader
        super.init()
        wrappedLoader.didEmitVehicle = vehicleEmitted
    }
    
    func vehicleEmitted(_ resource: R){
        didEmitVehicle?(resource)
    }
}
