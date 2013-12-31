//
//  ViewController.m
//  BSYS20131216
//
//  Created by Satoru Takahashi on 2013/12/16.
//  Copyright (c) 2013年 Satoru Takahashi. All rights reserved.
//

#import "ViewController.h"
#import "ImageAnnotation.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface ViewController ()
{
@private
	ALAssetsLibrary *_assetsLibrary;
    NSMutableArray *_assetsArray;
    int _imageIndex;
    CLLocationCoordinate2D _previousLocation;
}
@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSMutableArray *assetsArray;
@property (assign, nonatomic) int imageIndex;
@property (assign, nonatomic) CLLocationCoordinate2D previousLocation;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    srand((unsigned) time(NULL));

    self.mapView.delegate = self;
    self.assetsLibrary = [[ALAssetsLibrary alloc] init]; //assetsLibraryを解放するとALAssetも解放されるので注意
    self.assetsArray = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D initialLocation;
    initialLocation.latitude = 0;
    initialLocation.longitude = 0;
    self.previousLocation = initialLocation;
    ALAssetsLibraryGroupsEnumerationResultsBlock resultBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
            NSLog(@"album=%@", groupName);
            [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                if (asset) {
                    CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
                    if (location.coordinate.latitude != 0 || location.coordinate.longitude != 0) {
                        [self.assetsArray addObject:asset];
                    }
                }
            }];
        } else {
            NSLog(@"no group");
        }
    };
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
                                      usingBlock:resultBlock
                                    failureBlock:^(NSError *error) { NSLog(@"ERROR!!!");}];

    [NSTimer scheduledTimerWithTimeInterval:0 target: self
                                   selector:@selector(ticker:) userInfo: nil
                                    repeats: NO ];

}

- (void)ticker:(NSTimer*)timer
{
    if ([self.assetsArray count] > 0) {
        [self selectImage];
    } else {
        [NSTimer scheduledTimerWithTimeInterval:0.1 target: self
                                       selector:@selector(ticker:) userInfo: nil
                                        repeats: NO ];
    }
}

-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id)annotation
{
    MKAnnotationView *annotationView;
    NSString* identifier = @"Pin";
    annotationView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if(nil == annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    }
    
    ALAsset *asset = [self.assetsArray objectAtIndex:((ImageAnnotation *)annotation).imageIndex];
    UIImage *image = [[UIImage alloc] initWithCGImage:asset.thumbnail scale:1 orientation:UIImageOrientationUp];
    annotationView.image = image;
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    annotationView.annotation = annotation;
    
    return annotationView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    view.transform = CGAffineTransformMakeScale(0, 0);
    view.alpha = 1;
    [UIView animateWithDuration:2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.5, 1.5);
                     } completion:^(BOOL finished) {
                         [self selectImage];
                         [UIView animateWithDuration:0.5
                                               delay:0.5
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              view.transform = CGAffineTransformMakeScale(0, 0);
                                              view.alpha = 0;
                                          } completion:^(BOOL finished) {
                                              [self.mapView removeAnnotation:view.annotation];
                                          }];
                     }];
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
}

- (void)selectImage
{
    self.imageIndex = rand() % [self.assetsArray count];
    ALAsset *asset = [self.assetsArray objectAtIndex:self.imageIndex];
    ImageAnnotation *annotation = [[ImageAnnotation alloc] init];
    annotation.imageIndex = self.imageIndex;
    CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
    annotation.coordinate = location.coordinate;
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:true];
    
    MKCoordinateRegion region = self.mapView.region;
    
    ALAsset *selectedAsset = [self.assetsArray objectAtIndex:self.imageIndex];
    CLLocation *selectedLocation = [selectedAsset valueForProperty:ALAssetPropertyLocation];
    
    region.center = selectedLocation.coordinate;
    region.span.latitudeDelta = ABS(self.previousLocation.latitude - selectedLocation.coordinate.latitude) * 2 * 1.2;
    region.span.longitudeDelta = ABS(self.previousLocation.longitude - selectedLocation.coordinate.longitude) * 2 * 1.2;
    [self.mapView setRegion:region animated:true];
    
    self.previousLocation = selectedLocation.coordinate;
}

@end
