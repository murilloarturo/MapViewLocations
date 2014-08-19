//
//  ViewController.m
//  FoursquareMapView
//
//  Created by Arturo Murillo on 8/19/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//

#import "ViewController.h"
#import "MainService.h"
#import "Location.h"
#import "Constants.h"
#import "MBProgressHUD.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSArray *venues;

@property (strong, nonatomic) id notificationObserver;
//Manager to get current location
@property CLLocationManager *locationManager;

@property (strong, nonatomic) Location *selectedLocation;

@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) MBProgressHUD *progressView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setNotificationListeners];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.mapView.delegate= self;
    
    [self.mapView setShowsUserLocation:YES];
    
    [self setCurrentLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self removeNotificationListeners];
    
    [super viewDidDisappear:animated];
}

#pragma mark Notification Listeners
- (void)setNotificationListeners
{
    self.notificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:[[MainService sharedClient] getLocationCompletedKey] object:nil queue:nil usingBlock:^(NSNotification *notification) {
        [self plotVenues:[[notification userInfo] objectForKey:@"venues"]];
        
        //[self.progressView hide:YES];
    }];
}

- (void)removeNotificationListeners
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.notificationObserver];
}

- (void)plotVenues:(NSArray *)data {
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        [self.mapView removeAnnotation:annotation];
    }
    
    for (NSDictionary *row in data) {
        NSNumber * latitude = [[row valueForKey:@"location"] valueForKey:@"lat"];
        NSNumber * longitude = [[row valueForKey:@"location"] valueForKey:@"lng"];
        NSString * name = [row valueForKey:@"name"];
        NSString * address = [[[row valueForKey:@"location"] valueForKey:@"formattedAddress"] componentsJoinedByString: @" "];
        NSString *venueId = [row valueForKey:@"id"];
        
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = latitude.doubleValue;
        coordinate.longitude = longitude.doubleValue;
        Location *annotation = [[Location alloc] initWithName:name address:address coordinate:coordinate locationId:venueId] ;
        
        [self.mapView addAnnotation:annotation];
	}
    
    self.venues = data;
}

#pragma mark mapView Methods
- (IBAction)zoomIn:(id)sender {
    MKUserLocation *userLocation = self.mapView.userLocation;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (
                                        userLocation.location.coordinate, 10000, 10000);
    
    [self.mapView setRegion:region animated:NO];
}

- (IBAction)changeMapType:(id)sender {
    if (self.mapView.mapType == MKMapTypeStandard)
        self.mapView.mapType = MKMapTypeSatellite;
    else
        self.mapView.mapType = MKMapTypeStandard;
}

- (void)updateUserLocation
{
    //MKUserLocation *userLocation = self.mapView.userLocation;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (
                                        self.currentLocation.coordinate, 10000, 10000);
    
    [self.mapView setRegion:region animated:NO];
}

#pragma mark Location Methods
- (void)setCurrentLocation
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

#pragma mark CLLocationManager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    [[MainService sharedClient] location:[locations objectAtIndex:0]];
    [self.locationManager stopUpdatingLocation];
    NSLog(@"Detected Location : %f, %f", [[MainService sharedClient] currentLocation].coordinate.latitude, [[MainService sharedClient] currentLocation].coordinate.longitude);
    
    self.currentLocation = [locations objectAtIndex:0];
    
    [self updateUserLocation];
    
    //self.progressView = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //self.progressView.labelText = @"Cargando locales...";
    
    [[MainService sharedClient] getNearLocationsBySearch:@"sushi"];
    
}

#pragma mark MapView Delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"Location";
    if ([annotation isKindOfClass:[Location class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:PINIMAGE];
        } else {
            annotationView.annotation = annotation;
        }
        
        // Add to mapView:viewForAnnotation: after setting the image on the annotation view
        
        UIButton *infoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        
        [infoButton setImage:[UIImage imageNamed:@"directions.png"] forState:UIControlStateNormal];
        
        annotationView.rightCalloutAccessoryView = infoButton;
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    Location *location = (Location *)view.annotation;
    self.selectedLocation = location;
    
    [self showDirectionsSelectedRestaurant];
    
    //[self performSegueWithIdentifier:@"ShowVenueSegue" sender:location];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"ShowVenueSegue"]) {
        Location *location = (Location *)sender;
        
        return ([self getVenueWithId:location.locationId] ? YES : NO);
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowVenueSegue"]) {
        Location *location = (Location *)sender;
        
        self.selectedLocation = location;
        
        VenueViewController *venueViewController = segue.destinationViewController;
        
        venueViewController.delegate = self;
        venueViewController.venue = [self getVenueWithId:location.locationId];
    }
}

- (NSDictionary *)getVenueWithId:(NSString *)venueId
{
    for (NSDictionary *venue in self.venues) {
        if ([[venue valueForKey:@"id"] isEqualToString:venueId]) {
            return venue;
        }
    }
    
    return nil;
}

- (void)showDirectionsSelectedRestaurant
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    request.source = [MKMapItem mapItemForCurrentLocation];
    
    request.destination = [self.selectedLocation mapItem];
    request.requestsAlternateRoutes = NO;
    MKDirections *directions =
    [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle error
             [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                         message:error.userInfo[@"NSLocalizedDescription"]
                                        delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil] show];
         } else {
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
        
        for (MKRouteStep *step in route.steps)
        {
            NSLog(@"%@", step.instructions);
        }
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 5.0;
    return renderer;
}

- (MKMapItem *)mapItem
{
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.currentLocation.coordinate
                              addressDictionary:nil];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = @"Current Location";
    
    return mapItem;
}

@end
