//
//  ViewController.h
//  FoursquareMapView
//
//  Created by Arturo Murillo on 8/19/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "VenueViewController.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, ShowDirectionsDelegate>

@end
