//
//  Insurer.swift
//  KatsanaSDK
//
//  Created by Wan Ahmad Lutf Wan Md Hatta on 14/12/2017.
//  Copyright © 2017 pixelated. All rights reserved.
//

open class KTInsurer {
    public let country: String
    public let name: String
    public let partner: Bool
    
    init(name: String, country: String, partner: Bool = false) {
        self.country = country
        self.partner = partner
        self.name = name
    }
}
