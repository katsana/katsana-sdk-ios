//
//  HTTPClient.swift
//  Shared
//
//  Created by Wan Ahmad Lutfi on 13/03/2023.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    @discardableResult
    func send(_ urlRequest: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask
}

