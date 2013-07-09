
#import <CoreLocation/CLLocation.h>

//#define FREE_DISTANCE_KM    20498.4
#define FREE_DISTANCE_KM                20

#define DISTANCE_LEVEL_1                (FREE_DISTANCE_KM+0.5)         //  dist<DISTANCE_LEVEL_1:  0
#define DISTANCE_LEVEL_2                1000       //  DISTANCE_LEVEL_1<=dist<DISTANCE_LEVEL_2:  10
#define DISTANCE_LEVEL_3                5000        //  DISTANCE_LEVEL_2<=dist<DISTANCE_LEVEL_3:  20
#define DISTANCE_LEVEL_4                20498.4    //  DISTANCE_LEVEL_3<=dist<DISTANCE_LEVEL_4:  50


//#define NO_DISTANCE_LIMIT


@interface LocationTravelingService: NSObject
{

}


//+ (BOOL) canSetTravelingLocationAt:(CLLocation*)aLocation;
+ (BOOL) consumePoints;
+ (NSInteger) pointsForCurrentFixedLocation;

+ (BOOL) isFixedLocationAvaliable;
+ (BOOL) isTraveling;
+ (BOOL) startTraveling;
+ (void) stopTraveling;

+ (void) setFixedLocation:(CLLocation*)aLocation;

+ (BOOL) isSet;
+ (CLLocation*) getFixedLocation;


//private
//+ (void) setIsSet;
//+ (void) unsetIsSet;


@end
