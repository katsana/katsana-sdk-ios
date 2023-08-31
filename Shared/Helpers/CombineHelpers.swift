//
//  CombineHelpers.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 29/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import Combine

public extension HTTPClient {
    typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>
    
    func getPublisher(urlRequest: URLRequest) -> Publisher {
        var task: HTTPClientTask?
        
        return Deferred {
            Future { completion in
                task = self.send(urlRequest, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel() })
        .eraseToAnyPublisher()
    }
}

public extension ReverseGeocodingClient {
    typealias Publisher = AnyPublisher<KTAddress, Error>
    
    func getPublisher(coordinate: (latitude: Double, longitude: Double)) -> Publisher {
        var task: ReverseGeocodingClientTask?
        return Deferred {
            Future { completion in
               task = self.getAddress(coordinate, completion: completion)
            }
        }
        .handleEvents(receiveCancel: { task?.cancel()})
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    public func caching<R: ResourceCache>(to cache: R) -> AnyPublisher<Output, Failure> where Output == R.SaveResource{
        handleEvents(receiveOutput: cache.saveIgnoringResult).eraseToAnyPublisher()
    }
}

extension Publisher {
    func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
        self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
    }
}

extension Publisher{
    func mapToArray() -> AnyPublisher<[Output], Error> {
        return self
            .map { response -> [Output] in
                return [response]
            }
            .mapError({ error in
                return error
            })
            .eraseToAnyPublisher()
    }
}

extension Publisher where Output: Collection{
    func mapToFirstElementFromArray() -> AnyPublisher<Output.Element, Error> {
        return self
            .map { response -> Output.Element in
                return response.first!
            }
            .mapError({ error in
                return error
            })
            .eraseToAnyPublisher()
    }
}

extension ResourceCache {
    public func saveIgnoringResult(_ resource: SaveResource) {
        save(resource) { _ in}
    }
}

public extension AnyLocalLoader {
    
    func loadPublisher() -> AnyPublisher<AnyLocalLoader.LoadResource, Error> {
        Deferred {
            Future(self.load)
        }
        .eraseToAnyPublisher()
    }
}

public extension LocalResourceWithKeyLoader {
    
    func loadPublisher(key: String) -> AnyPublisher<S.Resource, Error> {
        return Deferred {
            Future { completion in
                completion(Result {
                    try self.loadResource(from:key)
                })
            }
        }
        .eraseToAnyPublisher()
    }
}

private var resourceEmitterSubjects = [String: Any]()
public extension ResourceEmitter{
    func loadPublisher() -> AnyPublisher<Resource, Error> {
        let title = "\(Resource.self)"
        
        var emitterSubject = resourceEmitterSubjects[title] as? PassthroughSubject<Resource,Error>
        if emitterSubject == nil{
            emitterSubject = PassthroughSubject<Resource,Error>()
            resourceEmitterSubjects[title] = emitterSubject
        }
        
        self.didEmitResource = { resource in
            emitterSubject?.send(resource)
        }
        return emitterSubject!.eraseToAnyPublisher()
    }
}

extension Publisher {
    func caching<R: ResourceWithKeyCache>(to cache: R, using key: String) -> AnyPublisher<Output, Failure> where Output == R.R{
        handleEvents(receiveOutput: { resource in
            cache.saveIgnoringResult(resource, for: key)
        }).eraseToAnyPublisher()
    }
}

extension ResourceWithKeyCache {
    func saveIgnoringResult(_ resource: R, for key: String) {
        try? save(resource, for: key)
    }
}

extension DispatchQueue {
    static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
        ImmediateWhenOnMainQueueScheduler.shared
    }
    
    struct ImmediateWhenOnMainQueueScheduler: Scheduler {
        typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
        typealias SchedulerOptions = DispatchQueue.SchedulerOptions
        
        var now: SchedulerTimeType {
            DispatchQueue.main.now
        }
        
        var minimumTolerance: SchedulerTimeType.Stride {
            DispatchQueue.main.minimumTolerance
        }
        
        static let shared = Self()
        
        private static let key = DispatchSpecificKey<UInt8>()
        private static let value = UInt8.max
        
        private init() {
            DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
        }
        
        private func isMainQueue() -> Bool {
            DispatchQueue.getSpecific(key: Self.key) == Self.value
        }
        
        func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
            guard isMainQueue() else {
                return DispatchQueue.main.schedule(options: options, action)
            }
            
            action()
        }
        
        func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
            DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
        }
        
        func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
            DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
        }
    }
}

public typealias AnyDispatchQueueScheduler = AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>

extension AnyDispatchQueueScheduler {
    public static var immediateOnMainQueue: Self {
        DispatchQueue.immediateWhenOnMainQueueScheduler.eraseToAnyScheduler()
    }
}

extension Scheduler {
    func eraseToAnyScheduler() -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
        AnyScheduler(self)
    }
}

public struct AnyScheduler<SchedulerTimeType: Strideable, SchedulerOptions>: Scheduler where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
    private let _now: () -> SchedulerTimeType
    private let _minimumTolerance: () -> SchedulerTimeType.Stride
    private let _schedule: (SchedulerOptions?, @escaping () -> Void) -> Void
    private let _scheduleAfter: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Void
    private let _scheduleAfterInterval: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Cancellable

    init<S>(_ scheduler: S) where SchedulerTimeType == S.SchedulerTimeType, SchedulerOptions == S.SchedulerOptions, S: Scheduler {
        _now = { scheduler.now }
        _minimumTolerance = { scheduler.minimumTolerance }
        _schedule = scheduler.schedule(options:_:)
        _scheduleAfter = scheduler.schedule(after:tolerance:options:_:)
        _scheduleAfterInterval = scheduler.schedule(after:interval:tolerance:options:_:)
    }
    
    public var now: SchedulerTimeType { _now() }
    
    public var minimumTolerance: SchedulerTimeType.Stride { _minimumTolerance() }
    
    public func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _schedule(options, action)
    }

    public func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
        _scheduleAfter(date, tolerance, options, action)
    }

    public func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
        _scheduleAfterInterval(date, interval, tolerance, options, action)
    }
}



