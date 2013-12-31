//
//  ImageAnnotation.h
//  PhotoCalendar
//
//  Created by Satoru Takahashi on 2013/12/12.
//  Copyright (c) 2013年 Satoru Takahashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ImageAnnotation : NSObject <MKAnnotation>
{
    int _imageIndex;
	CLLocationCoordinate2D _coordinate;
	NSString *_annotationSubTitle;
	NSString *_annotationTitle;
}

@property (assign, nonatomic) int imageIndex;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) NSString *annotationSubTitle;
@property (strong, nonatomic) NSString *annotationTitle;

- (NSString *)title;
- (NSString *)subtitle;

@end
