//
//  TestHelpers.swift
//  SharedTests
//
//  Created by Wan Ahmad Lutfi on 13/03/2023.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyURLRequest() -> URLRequest {
    return URLRequest(url: URL(string: "http://any-url.com")!) 
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func makeJSON(_ item: [String: Any]) -> Data {
    return try! JSONSerialization.data(withJSONObject: item)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
