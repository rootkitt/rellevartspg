//
//  LocationRecord.h
//  GPSTraveller
//
//  Created by Wen Shane on 13-4-2.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface POI:NSObject
{
    NSString* mGeoInfo;
    CLLocation* mLocation;
}
@property (nonatomic, copy)     NSString* mGeoInfo;
@property (nonatomic, retain)     CLLocation* mLocation;

//distance in meters from current true location
- (double) distance;
- (NSString*) distanceDesp;

@end



@class MyLocationAnnotation;
@interface FavoritePOI : POI<NSCoding>
{
    NSDate* mRecordDate;
}
@property (nonatomic, retain)     NSDate* mRecordDate;

+ (FavoritePOI*) locationRecordWithMyLocationAnnotation:(MyLocationAnnotation*)aAnnotation;

@end



@interface HotPOI : POI
{
    NSInteger mVisits;
}

@property (nonatomic, assign) NSInteger mVisits;

@end

