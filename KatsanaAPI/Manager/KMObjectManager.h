//
//  KMObjectManager.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/14/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import <RestKit/RestKit.h>

@interface KMObjectManager : RKObjectManager

+ (instancetype) sharedManager;
+ (void)resetSharedManager;
+ (void)resetWithBaseURL:(NSString*)baseURL;

- (void) setupRequestDescriptors;
- (void) setupResponseDescriptors;

@end
