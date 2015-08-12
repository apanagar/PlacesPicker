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

//	#include <LSKit.h>
//#import <LSKit.h>


@interface PlacesPickerViewController : UIViewController <LSManagerDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) NSString *initialQuery;
@property (strong, nonatomic) MKMapItem *selectedMapItem;
@end

