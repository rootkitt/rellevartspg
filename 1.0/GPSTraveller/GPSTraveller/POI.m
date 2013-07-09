//
//  LocationRecord.m
//  GPSTraveller
//
//  Created by Wen Shane on 13-4-2.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

#import "POI.h"
#import "MyLocationAnnotation.h"
#import "MainViewController.h"
#import "MarsCoordinator.h"
#import "LocationSource.h"

@implementation POI
@synthesize mGeoInfo;
@synthesize mLocation;


- (void) dealloc
{
    self.mGeoInfo = nil;
    self.mLocation = nil;
    
    [super dealloc];
}

- (double) distance
{
    CLLocation* sCurrentLocation = [[LocationSource getTrueLocationSource] getMostRecentLocation];
    if (!sCurrentLocation)
    {
        return -1;
    }
    CLLocationDistance sDistanceInMeters = [self.mLocation distanceFromLocation:sCurrentLocation];
    return sDistanceInMeters;
}

- (NSString*) distanceDesp
{
    NSString* sDistanceDesp = nil;
    double sDistaneMeters = [self distance];
    if (sDistaneMeters < 0)
    {
        return NSLocalizedString(@"Unknown", nil);
    }
    
    if (sDistaneMeters < 1000)
    {
        sDistanceDesp = [NSString stringWithFormat:@"%.1f %@", sDistaneMeters, NSLocalizedString(@"meter(s)", nil)];
    }
    else
    {
        double sDistanceKMs = sDistaneMeters/1000;
        sDistanceDesp = [NSString stringWithFormat:@"%.1f %@", sDistanceKMs, NSLocalizedString(@"km(s)", nil)];
    }
    
    return sDistanceDesp;
}

@end


@implementation FavoritePOI
@synthesize mRecordDate;

+ (FavoritePOI*) locationRecordWithMyLocationAnnotation:(MyLocationAnnotation*)aAnnotation
{
    FavoritePOI* sLocationRecord = [[[FavoritePOI alloc] init] autorelease];
    
    sLocationRecord.mRecordDate = [NSDate date];
    sLocationRecord.mGeoInfo = aAnnotation.subtitle;
    
//    CLLocationCoordinate2D sTrueCoordinate = [[MainViewController shared] adjustLocationCoordinate:aAnnotation.mCoordinate Reverse:YES];
    CLLocationCoordinate2D sTrueCoordinate = [[MarsCoordinator shared] getRealCoordinateFromMarsCoordinate:aAnnotation.mCoordinate];
                                              
    sLocationRecord.mLocation = [[[CLLocation alloc] initWithLatitude:sTrueCoordinate.latitude longitude:sTrueCoordinate.longitude] autorelease];
    
    return sLocationRecord;

}

- (id) initWithCoder:(NSCoder *)aCoder
{
    self.mGeoInfo = [aCoder decodeObjectForKey:@"geoInfo"];
    self.mLocation = [aCoder decodeObjectForKey:@"location"];
    self.mRecordDate = [aCoder decodeObjectForKey:@"recordDate"];
    
    return self;
}

- (void) dealloc
{
    self.mRecordDate = nil;
    
    [super dealloc];
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.mGeoInfo forKey:@"geoInfo"];
    [aCoder encodeObject:self.mLocation forKey:@"location"];
    [aCoder encodeObject:self.mRecordDate forKey:@"recordDate"];
}


@end

@implementation HotPOI
@synthesize mVisits;


@end
