//
//  Location.m
//  FoursquareMapView
//
//  Created by Arturo Murillo on 8/19/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//

#import "Location.h"
#import <AddressBook/AddressBook.h>

@interface Location()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, assign) CLLocationCoordinate2D theCoordinate;

@end

@implementation Location

- (id)initWithName:(NSString*)name address:(NSString *)address coordinate:(CLLocationCoordinate2D)coordinate locationId:(NSString *)locationId
{
    if ((self = [super init])) {
        if ([name isKindOfClass:[NSString class]]) {
            self.name = name;
        } else {
            self.name = @"Local";
        }
        self.address = address;
        self.theCoordinate = coordinate;
        
        self.locationId = locationId;
    }
    return self;
}

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.address;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.theCoordinate;
}

- (MKMapItem *)mapItem
{
    NSDictionary *addressDict = @{(NSString*)kABPersonAddressStreetKey : self.address};
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:addressDict];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}

@end
