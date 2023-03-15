//
//  KatsanaServiceFactory.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutfi on 15/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

public class KatsanaServiceFactory{
    let baseURL: URL
    let client: HTTPClient
    
    public init(baseURL: URL, client: HTTPClient) {
        self.baseURL = baseURL
        self.client = client
    }
    
    public func makeUserProfileLoader(includes params: [String]? = nil) -> RemoteLoader<KTUser>{
        let url = UserProfileEndpoint.get(includes: params).url(baseURL: baseURL)
        return RemoteLoader(url: url, client: client, mapper: UserMapper.map)
    }
    
}
