//
//  ViewController.h
//  SwoopPlacesPicker
//
//  Created by ajay on 8/7/15.
//  Copyright (c) 2015 Optinera. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LSManager.h"
#import "LocationPickerView.h"
//	#include <LSKit.h>
//#import <LSKit.h>


@interface PlacesPickerViewController : UIViewController <LSManagerDelegate, LocationPickerViewDelegate>
@property (weak, nonatomic) IBOutlet LocationPickerView *locationPickerView;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;
@property (strong, nonatomic) NSMutableArray *mapItems;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *initialQuery;
@property (strong, nonatomic) MKMapItem *selectedMapItem;

- (void) pressedDone:(id)sender;
@end

