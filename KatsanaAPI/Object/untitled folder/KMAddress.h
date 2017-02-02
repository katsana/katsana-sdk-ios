//
//  KMAddress.h
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 20/01/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface KMAddress : NSObject

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, strong) NSString *streetNumber;
@property (nonatomic, strong) NSString *streetName;
@property (nonatomic, strong) NSString *locality;
@property (nonatomic, strong) NSString *sublocality;
@property (nonatomic, assign) NSInteger postcode;
@property (nonatomic, strong) NSString *country;

@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSDate *updateDate;

- (CLLocationCoordinate2D)coordinate;
- (NSString*)optimizedAddress;
- (NSString*)optimizedAddressWithCountry;

@end
