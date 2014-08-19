//
//  VenueViewController.h
//  FoursquareMapView
//
//  Created by Arturo Murillo on 8/19/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShowDirectionsDelegate <NSObject>

- (void)showDirectionsSelectedRestaurant;

@end

@interface VenueViewController : UIViewController

@property (nonatomic, strong) id<ShowDirectionsDelegate> delegate;

@property (nonatomic, strong) NSDictionary *venue;

@end
