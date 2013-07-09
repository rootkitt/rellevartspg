
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationSourceDelegate <NSObject>

@optional
- (void) locationSource:(id)aLocationSource withNewLocation:(CLLocation*)aNewLocation oldLocation:(CLLocation*)aOldLocation;

@end


@interface LocationSource: NSObject
{
    CLLocation* mMostRecentLocation;
    id<LocationSourceDelegate> mDelegate;
}

@property (nonatomic, assign) id<LocationSourceDelegate> mDelegate;

- (CLLocation*) getMostRecentLocation;
+ (LocationSource*) getRegularLocationSource;
+ (LocationSource*) getTrueLocationSource;


@end


//TrueLocationSource20121229 will not intercept the system true location info if it knows the original deleate is a class of TrueLocationSource20121229.
@interface TrueLocationSource20121229: LocationSource<CLLocationManagerDelegate>
{
    CLLocationManager* mLocationManager;
}
@property (nonatomic, retain) CLLocationManager* mLocationManager;

@end


//TravelingLocationSource
@interface TravelingLocationSource: LocationSource
{
}

@end
