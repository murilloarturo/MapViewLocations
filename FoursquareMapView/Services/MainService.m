//
//  MainService.m
//  FoursquareMapView
//
//  Created by Arturo Murillo on 8/19/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//

#import "MainService.h"

static NSString *const getLocationCompletedKey = @"getLocationCompleted";

static NSString *const CLIENT_ID = @"MSB3H0C14BLRSSAAYGELVLAAWVKWUL5DXYVMWF2UJPUVZOMC";
static NSString *const CLIENT_SECRET = @"ZSDRDRBEZHO4DUH5TWS2DQMOUP1MMBBMEZJBNDZZVXTUFZX1";
static NSString *const servicesBaseURL = @"http://services.educatablet.com:9090/";

@implementation MainService

+ (instancetype)sharedClient{
    static MainService *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[MainService alloc] init];
        //sharedClient = [[QuizMakerService alloc] initWithBaseURL:[NSURL URLWithString:kSDFParseAPIBaseURLString]];
        //[sharedClient setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey]];
    });
    
    return sharedClient;
}

- (NSString *)getLocationCompletedKey
{
    return getLocationCompletedKey;
}

- (void)getNearLocationsBySearch:(NSString *)search
{
    NSString *location = [self getLocation];
    
    NSDictionary *parameters = @{@"client_id": CLIENT_ID,
                                 @"client_secret": CLIENT_SECRET,
                                 @"v":@"20130815",
                                 @"ll": location,
                                 @"query":search
                                 };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:@"https://api.foursquare.com/v2/venues/search" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject[@"response"]);
        
        if ([responseObject isKindOfClass:[NSDictionary class]] && responseObject[@"response"]) {
            
            NSDictionary *response = responseObject[@"response"];
            
            NSArray *venues = response[@"venues"];
            
            NSDictionary *infoData =
            [NSDictionary dictionaryWithObjectsAndKeys:venues ,@"venues", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:getLocationCompletedKey
                                                                object:nil
                                                              userInfo:infoData];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (NSString *)getLocation
{
    return (self.currentLocation ? [NSString stringWithFormat:@"%f,%f",self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude] : @"40.7, -74");
}

@end
