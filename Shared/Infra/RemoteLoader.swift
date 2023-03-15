//
//  RemoteLoader.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 14/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public typealias ResourceResultClosure<Resource> = (Result<Resource, Error>) -> Void

public struct HTTPResponseError: Error{
    let statusCode: Int
    let message: String
}

public class RemoteLoader<Resource> {
    private let client: HTTPClient
    private let url: URL
    private let mapper: Mapper
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case invalidHTTPResponse(HTTPResponseError)
    }
    
    public typealias Result = Swift.Result<Resource, Swift.Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    
    public init(url: URL,client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.send(URLRequest(url: url)) {[weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success((let data, let response)):
                if let errorResponse = self.mapInvalidHTTPResponseError(data, from: response){
                    completion(.failure(errorResponse))
                }else{
                    completion(self.map(data, from: response))
                }
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            return .success(try mapper(data,response))
        } catch {
            return .failure(Error.invalidData)
        }
    }
}

extension RemoteLoader{
    private func mapInvalidHTTPResponseError(_ data:Data, from response: HTTPURLResponse) -> HTTPResponseError?{
        let status = response.statusCode
        guard (200...299).contains(status) else {
            do{
                let json = try JSON(data: data)
                let message = json["message"].string
                return HTTPResponseError(statusCode: status, message: message ?? "Unknown error")
            }
            catch{
                return HTTPResponseError(statusCode: status, message: "Unknown error")
            }
            
        }
        return nil
    }
    
}
