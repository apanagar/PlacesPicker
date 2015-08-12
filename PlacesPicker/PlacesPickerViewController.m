//
//  ViewController.m
//  SwoopPlacesPicker
//
//  Created by ajay on 8/7/15.
//  Copyright (c) 2015 Optinera. All rights reserved.
//

#import "PlacesPickerViewController.h"
#import "LocationPickerView.h"
//#import "LSKit.h"
#import "LSManager.h"
#import "LSMapItem.h"
#import <objc/runtime.h>

#define kMinCapacity 5

@interface PlacesPickerViewController ()
@property (weak, nonatomic) IBOutlet LocationPickerView *locationPickerView;
@property (strong, nonatomic) IBOutlet UISearchDisplayController *searchController;
@property (strong, nonatomic) NSMutableArray *mapItems;
@end

@implementation PlacesPickerViewController


- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.searchController.navigationItem.rightBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(pressedDone:)];

//	self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@" " style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
	
//	self.navigationItem.backBarButtonItem.title = @"";
	
	// Do any additional setup after loading the view, typically from a nib.
	
	self.mapItems = [NSMutableArray array];
	for (int i = 0; i < 5; i++) {
		[self.mapItems addObject:[[MKMapItem alloc] init]];
	}
	
	CLLocation *currentLocation = [self.locationManager location];
	CLLocationCoordinate2D coordinate = [currentLocation coordinate];
	CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
	LSManager *searchManager = [LSManager sharedInstance];
	searchManager.delegate = self;
	
	if (self.initialQuery == nil){
		self.initialQuery = @"restaurants";
	}
	[searchManager startOperationForQuery:self.initialQuery atLocation:currentLocation];
	
	
	// Optional parameters
	self.locationPickerView.delegate = self;
	self.locationPickerView.shouldAutoCenterOnUserLocation = YES;
	self.locationPickerView.shouldCreateHideMapButton = YES;
	self.locationPickerView.pullToExpandMapEnabled = YES;
	self.locationPickerView.defaultMapHeight = 220.0;           // larger than normal
	self.locationPickerView.parallaxScrollFactor = 0.3;         // little slower than normal.
	
	// Optional setup
	self.locationPickerView.mapViewDidLoadBlock = ^(LocationPickerView *locationPicker) {
		locationPicker.mapView.mapType = MKMapTypeStandard;
		locationPicker.mapView.userTrackingMode = MKUserTrackingModeFollow;
	};
	self.locationPickerView.tableViewDidLoadBlock = ^(LocationPickerView *locationPicker) {
		locationPicker.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	};

}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)searchResponse:(LSMapItem *)mapItem forQuery:(NSString *)query {
	NSLog(@"%@ response for query %@", [mapItem description], query);
	
	self.mapItems = mapItem.searchResults;
	
	if ([self.mapItems count] < kMinCapacity){
		NSUInteger paddingCount = kMinCapacity - [self.mapItems count];
		for (int i=0; i < paddingCount; i++){
			[self.mapItems addObject:[[MKMapItem alloc] init]];
		}
	}
	
	[self.locationPickerView.tableView reloadData];
	[self.searchController.searchResultsTableView reloadData];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.mapItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reusable"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"reusable"];
	}
	
	MKMapItem *item = self.mapItems[indexPath.row];
	NSString *name = item.name;
	cell.textLabel.text = item.placemark.addressDictionary[@"Name"];
	
	NSString *street = item.placemark.addressDictionary[@"Street"];
	NSString *city = item.placemark.addressDictionary[@"City"];
	NSString *state = item.placemark.addressDictionary[@"State"];
	NSString *zip = item.placemark.addressDictionary[@"ZIP"];
	NSString *website = [item.url absoluteString];
	if (street && city && state && zip){
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@, %@ %@", street, city, state, zip];
	}
	else if (website) {
		cell.detailTextLabel.text = website;
	}
	else {
		cell.detailTextLabel.text = nil;
	}

	cell.detailTextLabel.textColor = [UIColor lightGrayColor];

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	if (cell.textLabel.text == nil){
		return;
	}
	
	MKMapItem *item = self.mapItems[indexPath.row];
	
	CLLocationCoordinate2D coordinate = item.placemark.location.coordinate;
	
	NSLog(@"item: %@", item);
	self.locationPickerView.mapView.centerCoordinate = coordinate;
	
	[self removeAllPinsButUserLocation];
	MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
	[annotation setCoordinate:coordinate];
	[annotation setTitle:@"Title"]; //You can set the subtitle too
	[self.locationPickerView.mapView addAnnotation:annotation];
	
	self.selectedMapItem = item;
	
	if (tableView == self.searchController.searchResultsTableView){
		[self.searchController setActive:NO animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.contentView.backgroundColor = [UIColor whiteColor];
}

#pragma mark - LocationPickerViewDelegate

/** Called when the mapView is about to be expanded (made fullscreen).
 Use this to perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
	 mapViewWillExpand:(MKMapView *)mapView
{
	self.navigationItem.title = @"Map Expanding";
}

/** Called when the mapView was expanded (made fullscreen). Use this to
 perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
	  mapViewDidExpand:(MKMapView *)mapView
{
	self.navigationItem.title = @"Map Expanded";
}

/** Called when the mapView is about to be hidden (made tiny). Use this to
 perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
   mapViewWillBeHidden:(MKMapView *)mapView
{
	self.navigationItem.title = @"Map Shrinking";
}

/** Called when the mapView was hidden (made tiny). Use this to
 perform custom animations or set attributes of the map/table. */
- (void)locationPicker:(LocationPickerView *)locationPicker
	  mapViewWasHidden:(MKMapView *)mapView
{
	self.navigationItem.title = @"Map Normal";
}

- (void)locationPicker:(LocationPickerView *)locationPicker mapViewDidLoad:(MKMapView *)mapView
{
	mapView.mapType = MKMapTypeStandard;
}

- (void)locationPicker:(LocationPickerView *)locationPicker tableViewDidLoad:(UITableView *)tableView
{
	tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	NSLog(@"end text: %@", searchBar.text);
	LSManager *searchManager = [LSManager sharedInstance];
	CLLocation *currentLocation = [self.locationManager location];
	[searchManager startOperationForQuery:searchBar.text atLocation:currentLocation];
}


- (void)removeAllPinsButUserLocation
{
	id userLocation = [self.locationPickerView.mapView userLocation];
	NSMutableArray *pins = [[NSMutableArray alloc] initWithArray:[self.locationPickerView.mapView annotations]];
	if ( userLocation != nil ) {
		[pins removeObject:userLocation]; // avoid removing user location off the map
	}
	
	[self.locationPickerView.mapView removeAnnotations:pins];
}

#pragma Done callback
- (void) pressedDone:(id)sender {
	[self.searchController setActive:NO animated:YES];
}

@end
