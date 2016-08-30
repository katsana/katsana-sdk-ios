//
//  KMAddress.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 20/01/2016.
//  Copyright © 2016 bijokmind. All rights reserved.
//

#import "KMAddress.h"

@implementation KMAddress

- (NSString*)optimizedAddress{
    NSMutableArray *address = [NSMutableArray array];
    if (self.streetNumber) {
        [address addObject:self.streetNumber];
    }
    if (self.streetName) {
        [address addObject:self.streetName];
    }
    if (self.sublocality) {
        [address addObject:self.sublocality];
    }
    NSString *str = [address componentsJoinedByString:@", "];
    if (str.length == 0) {
        return self.address;
    }
    
    return str;
}

- (NSString*)optimizedAddressWithCountry{
    NSMutableArray *address = [NSMutableArray array];
    if (self.streetNumber) {
        [address addObject:self.streetNumber];
    }
    if (self.streetName) {
        [address addObject:self.streetName];
    }
    if (self.sublocality) {
        [address addObject:self.sublocality];
    }
    
    NSString *check = [address componentsJoinedByString:@""];
    if (check.length == 0) {
        return self.address;
    }
    if (check.length <=3) {
        return @"";
    }
    
    if (self.country) {
        [address addObject:self.country];
    }
    
    NSString *str = [address componentsJoinedByString:@", "];
    
    return str;
}

- (CLLocationCoordinate2D)coordinate{
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (BOOL)isEqual:(KMAddress*)object{
    if (self.class == object.class) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.latitude, self.longitude);
        CLLocationCoordinate2D otherCoord = CLLocationCoordinate2DMake(object.latitude, object.longitude);
        
        if (CLCOORDINATES_EQUAL2(coord, otherCoord)) {
            return YES;
        }
    }
    return NO;
}

@end
