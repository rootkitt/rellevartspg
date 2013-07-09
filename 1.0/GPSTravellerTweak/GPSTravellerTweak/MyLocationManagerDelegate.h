//
//  MyLocationManagerDelegate.h
//  GPSTravellerTweak
//
//  Created by Wen Shane on 13-4-2.
//
//

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>


#undef DEBUG


@interface FixedLocationData : NSObject
{
    NSDate* mTimestamp;
    BOOL mIsSet;
    CLLocation* mFixedLocation;
}
@property (nonatomic, retain)   NSDate* mTimestamp;
@property (nonatomic, assign)   BOOL mIsSet;
@property (nonatomic, retain)   CLLocation* mFixedLocation;


@end



//////
@interface LocationManager_Delegate : NSObject
{
    CLLocationManager* mLocationManager;
    id<CLLocationManagerDelegate> mDelegate;
    BOOL mNeedsTrueLocation;
}
@property (nonatomic, retain) CLLocationManager* mLocationManager;
@property (nonatomic, retain) id<CLLocationManagerDelegate> mDelegate;
@property (nonatomic, assign) BOOL mNeedsTrueLocation;

+ (LocationManager_Delegate*) getNewInstance;
@end

///////

@interface MyLocationManagerDelegate : NSObject<CLLocationManagerDelegate>
{
    NSMutableArray* mOriginalDelegates;
    NSDate* mTimestamp;
    NSTimer* mFixedLocationOnoffSnifferTime;
}

@property (nonatomic, retain) NSMutableArray* mOriginalDelegates;
@property (nonatomic, retain) NSDate* mTimestamp;
@property (nonatomic, retain) NSTimer* mFixedLocationOnoffSnifferTime;



- (void) addOriginalDelegate: (id<CLLocationManagerDelegate>)aDelegate LocationManager: (CLLocationManager*) aLocationManager;
//- (void) removeOriginalDelegate:(id<CLLocationManagerDelegate>)aDelegate;
- (void) removeOriginalDelegateByLocationManager:(CLLocationManager*) aLocationManager;

- (BOOL) needsTrueLocationForLocationManager:(CLLocationManager*) aLocationManager;

- (CLLocation*) getFixedLocation;
- (FixedLocationData*) getFixedLocationData;
@end
