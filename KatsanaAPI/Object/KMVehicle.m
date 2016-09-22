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

- (void)reloadDataWithVehicle:(KMVehicle*)vehicle{
    self.vehicleDescription = vehicle.description;
    self.mode = vehicle.mode;
    self.current = vehicle.current;
    self.currentPosition = vehicle.currentPosition;
    self.avatarURLPath = vehicle.avatarURLPath;
    self.markerURLPath = vehicle.markerURLPath;
    self.todayMaxSpeed = vehicle.todayMaxSpeed;
    self.speedLimit = vehicle.speedLimit;
    self.odometer = vehicle.odometer;
    self.subscriptionEnd = vehicle.subscriptionEnd;
    self.websocket = vehicle.websocket;
    self.currentAddress = vehicle.currentAddress;
    self.carImage = vehicle.carImage;
    self.maskedCarImage = vehicle.maskedCarImage;
}

- (NSString*)todayMaxSpeedString{
    return [NSString stringWithFormat:@"%.0f km/h", self.todayMaxSpeed * KNOT_TO_KMH];
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

- (void)carThumbImageWithBlock:(void (^)(UIImage *image))completion{
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
        [[KMKatsana sharedInstance] loadImageWithURL:[NSURL URLWithString:self.avatarURLPath] success:^(UIImage *image) {
            _carThumbImage = image;
            _maskedCarImage = nil;
            _loadingMarkerImage = NO;
            
            for (ImageCompletionBlock block in self.carThumbImageBlocks) {
                block(image);
            }
        } failure:^(NSError *error) {
            _loadingMarkerImage = NO;
        }];
    }else{
        completion(self.carThumbImage);
    }
}

- (void)carImageWithBlock:(void (^)(UIImage *image))completion{
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
        [[KMKatsana sharedInstance] loadImageWithURL:[NSURL URLWithString:self.markerURLPath] success:^(UIImage *image) {
            _carImage = image;
            _loadingImage = NO;
            
            for (ImageCompletionBlock block in self.carImageBlocks) {
                block(image);
            }
        } failure:^(NSError *error) {
            _loadingImage = NO;
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
        [[KMKatsana sharedInstance] loadAddressWithLocation:coord address:^(KMAddress *address) {
            self.currentAddress = address;
            _lastCoordinate = self.current.coordinate;
            completion(address);
        } failure:^(NSError *error) {
        }];
    }
}

- (void)reloadBlockImage{
    for (ImageCompletionBlock block in self.carImageBlocks) {
        block(self.carImage);
    }
}

@end
