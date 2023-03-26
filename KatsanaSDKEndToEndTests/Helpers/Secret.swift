//
//  Secret.swift
//  KatsanaSDKEndToEndTests
//
//  Created by Wan Ahmad Lutfi on 16/03/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import Foundation

final class Secret{
    private init(){}
     
    static var baseURL: URL{
       URL(string: "https://carbon.api.katsana.com/")!
    }
    
    static var token: String{
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIyIiwianRpIjoiYTQ2YWRjOTAyMzczZGZkNzQwMGI2MjIwMzBhNGFlMjRiNjQ4NjM5OGZiYmY0NTBkNTJjMDM2YjllMWE3NTIzNWIwMTZiZjFmMDVhZDk0MzkiLCJpYXQiOjE2Nzg3Nzg5ODIuNjM0NjI4LCJuYmYiOjE2Nzg3Nzg5ODIuNjM0NjM3LCJleHAiOjE3MTA0MDEzODIuNTkzNTU4LCJzdWIiOiIyMjAiLCJzY29wZXMiOlsiKiJdfQ.L9m86u_n11Efy0LCrCzTABuoFXeAog5Y7ZuZLCLM411vyE5ZLOgisLsumjNZYl-ms7Dt4WXH8X7UftTfbK0vkoe8WWmyj5Z2H23nWKUrYgPeeGPDwr9hM06LyLf6m4eOA95IbcQ1uoDqx3ZdRAhNR51Axdo0dm-g_V7W8FFW8rUEazcJPhIj61nJk-4RURsUdHDhTY8DoZEpeThoSG81KevNj1N_bG9mxtlzQA7Gd55CetoTprqCK20XAQDHRF0bmY_lUXb33kYp_VA8X8aM9sjXFz8DZZbgKc5jJ8-Hbs5oj_k-WWBSodEhCLNYl92IiHGzlQtV3IRC4ojfdbCUuXPGecqZI4pHyCnMuljJ5JpTds61hjVQatqvFWau_ExWCUKuLOXWYCirgepMshYh6dD7uD0RmBDurSUOZdPzuHog793Zs25YWY2p2fy-JW2C7t5vIuShDHbbkkcjaITyR8_TB15hqGYnArNQ3M8Dns41I8IUTEbfoeSk3x8lCT2TiSOqhv1WHwVfqggF4Ba0O5TvuUqHUAiYy4tDc9c_bpZnOnuguH-p6vWPl6shrKZabiy5MdSyP_uMvSAuHbjgOpxNcVay-xGlly5sd8jQBfbyU0Eyas9BVUvicD__IGKXOGoJsxuulk64YBN3EwkDCsoeEk3TdbGEYKfjrNNkYe0"
    }
}
