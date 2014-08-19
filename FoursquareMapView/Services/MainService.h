//
//  MainService.h
//  FoursquareMapView
//
//  Created by Arturo Murillo on 8/19/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MainService : NSObject 

@property (strong, nonatomic, setter = location:) CLLocation *currentLocation;

+ (instancetype)sharedClient;

- (void)getNearLocationsBySearch:(NSString *)search;

- (NSString *)getLocationCompletedKey;

@end
