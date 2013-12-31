//
//  ImageAnnotation.m
//  PhotoCalendar
//
//  Created by Satoru Takahashi on 2013/12/12.
//  Copyright (c) 2013年 Satoru Takahashi. All rights reserved.
//

#import "ImageAnnotation.h"

@implementation ImageAnnotation

- (NSString *)title {
    return self.annotationSubTitle;
}

- (NSString *)subtitle {
    return self.annotationTitle;
}
@end
