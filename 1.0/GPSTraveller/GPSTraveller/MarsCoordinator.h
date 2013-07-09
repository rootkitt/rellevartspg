//
//  MarsCoordinator.h
//  GPSTraveller
//
//  Created by Wen Shane on 13-7-3.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CSqlite.h"


@interface MarsCoordinator : NSObject

+ (MarsCoordinator*) shared;

//real gps -> mars gps
-(CLLocationCoordinate2D) getMarsCoordinateFromRealCoordinate:(CLLocationCoordinate2D)aRealCoordinate2D;
- (CLLocation*) getMarsLocationFromRealLocation:(CLLocation*)aLocation;


//mars gps -> real gps
- (CLLocationCoordinate2D) getRealCoordinateFromMarsCoordinate:(CLLocationCoordinate2D)aMarsCoordinate;
- (CLLocation*) getRealLocationFromMarsLocation:(CLLocation*)aMarsLocation;

@end
