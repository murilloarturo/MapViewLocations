//
//  VenueViewController.m
//  FoursquareMapView
//
//  Created by Arturo Murillo on 8/19/14.
//  Copyright (c) 2014 Arturo Murillo. All rights reserved.
//

#import "VenueViewController.h"
#import "Constants.h"

@interface VenueViewController ()

@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@end

@implementation VenueViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.exitButton setFrame:CGRectMake(self.view.frame.size.width, 0, self.exitButton.frame.size.width, self.exitButton.frame.size.height)];
    
    UIButton *exitButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 60, 60)];
    
    [exitButton setImage:[UIImage imageNamed:EXITMAGE] forState:UIControlStateNormal];
    
    [exitButton addTarget:self action:@selector(exit:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view.superview addSubview:exitButton];
    
    [super viewWillAppear:animated];
}
- (void)exit:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)showDirections:(id)sender
{
    if (self.delegate) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate showDirectionsSelectedRestaurant];
        }];
    }
}

@end
