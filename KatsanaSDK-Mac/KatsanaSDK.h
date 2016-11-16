//
//  KatsanaSDK-Mac.h
//  KatsanaSDK-Mac
//
//  Created by Wan Ahmad Lutfi on 15/11/2016.
//  Copyright © 2016 pixelated. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for KatsanaSDK-Mac.
FOUNDATION_EXPORT double KatsanaSDK_MacVersionNumber;

//! Project version string for KatsanaSDK-Mac.
FOUNDATION_EXPORT const unsigned char KatsanaSDK_MacVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KatsanaSDK_Mac/PublicHeader.h>
typedef void (^ImageCompletionBlock)(NSImage *image);
#import <KatsanaSDK/SharedPlatform.h>
#import <KatsanaSDK/KMConstant.h>
#import <KatsanaSDK/KMObject.h>
#import <KatsanaSDK/KMCacheManager.h>
#import <KatsanaSDK/KMTimeTransformer.h>
