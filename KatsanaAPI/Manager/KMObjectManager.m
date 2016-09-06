//
//  KMObjectManager.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/14/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import "KMObjectManager.h"

static KMObjectManager *sharedManager = nil;

@implementation KMObjectManager

static NSString *privateURLPath = nil;

+ (NSString*)privateURLPath {
    if (!privateURLPath) {
        privateURLPath = [NSString string];
    }
    return privateURLPath;
}

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:[self defaultBaseURL]];
        
        sharedManager = [self managerWithBaseURL:url];
        sharedManager.requestSerializationMIMEType = RKMIMETypeJSON;
        /*
         THIS CLASS IS MAIN POINT FOR CUSTOMIZATION:
         - setup HTTP headers that should exist on all HTTP Requests
         - override methods in this class to change default behavior for all HTTP Requests
         - define methods that should be available across all object managers
         */
        
        [sharedManager setupRequestDescriptors];
        [sharedManager setupResponseDescriptors];
    });
    
    return sharedManager;
}

+ (void)resetSharedManager{
    NSURL *url = [NSURL URLWithString:[self defaultBaseURL]];
    sharedManager.HTTPClient = [AFRKHTTPClient clientWithBaseURL:url];
    
    [sharedManager.HTTPClient registerHTTPOperationClass:[AFRKJSONRequestOperation class]];
    [sharedManager setAcceptHeaderWithMIMEType:RKMIMETypeJSON];
    sharedManager.requestSerializationMIMEType = RKMIMETypeFormURLEncoded;
    
    for (RKResponseDescriptor *response in sharedManager.responseDescriptors) {
        [sharedManager removeResponseDescriptor:response];
    }
    for (RKRequestDescriptor *request in sharedManager.requestDescriptors) {
        [sharedManager removeRequestDescriptor:request];
    }
    
    [sharedManager setupRequestDescriptors];
    [sharedManager setupResponseDescriptors];
}

- (void) setupRequestDescriptors {
}

- (void) setupResponseDescriptors {
}

+ (NSString*)defaultBaseURL{
    NSString *baseURL = privateURLPath;
    if (baseURL.length == 0) {
        privateURLPath = @"https://api.katsana.com/";
        baseURL = privateURLPath;
    }
    return baseURL;
}

+ (void)resetWithBaseURL:(NSString*)baseURL{
    privateURLPath = baseURL;
    [self resetSharedManager];
}

@end
