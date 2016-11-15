//
//  KMVehicle.m
//  KatsanaMap
//
//  Created by Wan Ahmad Lutfi on 12/15/15.
//  Copyright © 2015 bijokmind. All rights reserved.
//

#import "KMVehicle.h"

@interface KMVehicle ()

@property (nonatomic, strong) NSMutableArray *carImageBlocks;
@property (nonatomic, strong) NSMutableArray *carThumbImageBlocks;

@end

@implementation KMVehicle{
    CLLocationCoordinate2D _lastCoordinate;
    BOOL _loadingImage;
    BOOL _loadingMarkerImage;
}

+ (NSArray*)fastCodingKeys{
    return @[@"userId", @"vehicleId", @"vehicleDescription", @"vehicleNumber", @"imei", @"mode", @"avatarURLPath", @"markerURLPath", @"subscriptionEnd", @"websocket"];
}

- (NSDictionary*)jsonPatchDictionary{
    NSMutableDictionary *dicto = @{}.mutableCopy;
    if (self.vehicleDescription) dicto[@"description"] = self.vehicleDescription;
    if (self.vehicleNumber) dicto[@"vehicle_number"] = self.vehicleNumber;
    return dicto;
}


- (void)reloadDataWithVehicle:(KMVehicle*)vehicle{
    self.vehicleDescription = vehicle.description;
    self.mode = vehicle.mode;
    self.current = vehicle.current;
    self.avatarURLPath = vehicle.avatarURLPath;
    self.markerURLPath = vehicle.markerURLPath;
    self.todayMaxSpeed = vehicle.todayMaxSpeed;
//    self.speedLimit = vehicle.speedLimit;
    self.odometer = vehicle.odometer;
    self.subscriptionEnd = vehicle.subscriptionEnd;
    self.websocket = vehicle.websocket;
    self.currentAddress = vehicle.currentAddress;
    self.carImage = vehicle.carImage;
    self.maskedCarImage = vehicle.maskedCarImage;
}

- (NSString*)todayMaxSpeedString{
    return [KatsanaFormatter speedStringFromKnot:self.todayMaxSpeed];
}

- (NSMutableArray*)carImageBlocks{
    if (!_carImageBlocks) {
        _carImageBlocks = [NSMutableArray array];
    }
    return _carImageBlocks;
}

- (NSMutableArray*)carThumbImageBlocks{
    if (!_carThumbImageBlocks) {
        _carThumbImageBlocks = [NSMutableArray array];
    }
    return _carThumbImageBlocks;
}

- (void)carThumbImageWithBlock:(void (^)(KMImage *image))completion{
    if (!_carThumbImage) {
        if (_loadingMarkerImage) {
            @synchronized (self.carThumbImageBlocks) {
                [self.carThumbImageBlocks addObject:completion];
            }
            return;
        }else{
            [self.carThumbImageBlocks addObject:completion];
        }
        _loadingMarkerImage = YES;
        [[ImageRequest shared] requestImageWithPath:self.markerURLPath completion:^(KMImage * image) {
            _carThumbImage = image;
            _maskedCarImage = nil;
            _loadingMarkerImage = NO;
            
            for (ImageCompletionBlock block in self.carThumbImageBlocks) {
                block(image);
            }
            completion(image);
        } failure:^(NSError * error) {
            _loadingMarkerImage = NO;
            NSLog(@"Error get image: %@", error);
        }];
    }else{
        completion(self.carThumbImage);
    }
}

- (void)carImageWithBlock:(void (^)(KMImage *image))completion{
    if (!_carImage) {
        if (_loadingImage) {
            @synchronized (self.carImageBlocks) {
                [self.carImageBlocks addObject:completion];
            }
            return;
        }else{
            [self.carImageBlocks addObject:completion];
        }
        _loadingImage = YES;
        [[ImageRequest shared] requestImageWithPath:self.avatarURLPath completion:^(KMImage * image) {
            _carImage = image;
            _loadingImage = NO;
            
            for (ImageCompletionBlock block in self.carImageBlocks) {
                block(image);
            }
            completion(image);
        } failure:^(NSError * error) {
        }];
    }else{
        completion(self.carImage);
    }
}

- (void)currentAddressWithBlock:(void (^)(KMAddress *address))completion{
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.current.latitude, self.current.longitude);
    if (self.currentAddress && coord.latitude == _lastCoordinate.latitude && coord.longitude == _lastCoordinate.longitude && coord.latitude != 0) {
        completion(self.currentAddress);
        return;
    }
    
    if (coord.latitude !=0 && coord.longitude != 0) {
        [[KatsanaAPI shared] requestAddressFor:coord completion:^(KMAddress * address) {
            self.currentAddress = address;
            _lastCoordinate = self.current.coordinate;
            completion(address);

        } failure:^(NSError * error) {
            
        }];
    }
}

- (void)reloadBlockImage{
    for (ImageCompletionBlock block in self.carImageBlocks) {
        block(self.carImage);
    }
}

- (NSString*)description{
    return [NSString stringWithFormat:@"%@, id:%@, userId:%@, vehicleNumber:%@, vehicleDesc:%@", [super description], self.vehicleId, self.userId, self.vehicleNumber, self.vehicleDescription];
}

#pragma mark - Setter

- (void)setVehicleNumber:(NSString *)vehicleNumber{
    if (vehicleNumber.length > 0) {
        _vehicleNumber = vehicleNumber;
    }
}

- (void)setCarImage:(KMImage *)carImage{
    if (carImage && ![_carImage isEqual:carImage]) {
        _carImage = carImage;
        _carThumbImage = carImage;
        _maskedCarImage = nil;
        
        //If new image set, automatically reload blocks
        for (ImageCompletionBlock block in self.carImageBlocks) {
            block(carImage);
        }
        for (ImageCompletionBlock block in self.carThumbImageBlocks) {
            block(carImage);
        }
    }
    
}

@end
