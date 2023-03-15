//
//  HTTPClientSpy.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation
import KatsanaSDK

class HTTPClientSpy: HTTPClient {
    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    private var messages = [(url: URLRequest, completion: (HTTPClient.Result) -> Void)]()
    private(set) var cancelledRequests = [URLRequest]()
    
    var requestedURLs: [URL] {
        return messages.compactMap { $0.url.url }
    }
    
    var requests: [URLRequest] {
        return messages.compactMap { $0.url }
    }
    
    func send(_ urlRequest: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((urlRequest, completion))
        return Task { [weak self] in
            self?.cancelledRequests.append(urlRequest)
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
}

