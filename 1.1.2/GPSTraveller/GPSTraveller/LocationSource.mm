#import "LocationSource.h"
#import "LocationTravelingService.h"


@implementation LocationSource
@synthesize mDelegate;


- (void) dealloc
{
    if (mMostRecentLocation)
    {
        [mMostRecentLocation release];
        mMostRecentLocation = nil;
    }

    [super dealloc];
}

- (CLLocation*) getMostRecentLocation
{
    return mMostRecentLocation;
}


+ (LocationSource*) getRegularLocationSource
{    
    static LocationSource* S_TravelingLocationSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        S_TravelingLocationSource = [[TravelingLocationSource alloc] init];
    });
    return S_TravelingLocationSource;

}

+ (LocationSource*) getTrueLocationSource
{
    static LocationSource* S_TrueLocationSource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        S_TrueLocationSource = [[TrueLocationSource20121229 alloc] init];
    });
    return S_TrueLocationSource;
}

@end


#pragma mark - TrueLocationSource20121229 class
@implementation TrueLocationSource20121229
@synthesize mLocationManager;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.mLocationManager = [[[CLLocationManager alloc] init] autorelease];
        self.mLocationManager.delegate = self;
        self.mLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        [self.mLocationManager startUpdatingLocation];
    }
    return self;
}


- (void) dealloc
{
    [self.mLocationManager stopUpdatingLocation];
    self.mLocationManager = nil;
    
    [super dealloc];
}

- (CLLocation*) getMostRecentLocation
{
    if (!mMostRecentLocation)
    {
        mMostRecentLocation = [self.mLocationManager.location retain];
    }
    
    return mMostRecentLocation;
}



#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (newLocation.coordinate.latitude != mMostRecentLocation.coordinate.latitude
        || newLocation.coordinate.longitude !=  mMostRecentLocation.coordinate.longitude)
    {
        [mMostRecentLocation release];
        mMostRecentLocation = [newLocation retain];

        if (self.mDelegate
            && [self.mDelegate respondsToSelector:@selector(locationSource:withNewLocation:oldLocation:)])
        {
            [self.mDelegate locationSource:self withNewLocation:newLocation oldLocation:oldLocation];
        }
    }
    
}

@end


#pragma mark - TravelingLocationSource class

@implementation TravelingLocationSource
- (id) init
{
    self = [super init];
    if (self)
    {
        //
    }
    return self;
}

- (CLLocation*) getMostRecentLocation
{
    [mMostRecentLocation release];
    mMostRecentLocation = [[LocationTravelingService getFixedLocation] retain];
    return mMostRecentLocation;
}


@end


