#import "LocationTravelingService.h"
#import "LocationSource.h"
#import "SharedVariables.h"
#import "PointsManager.h"


#define FIXED_LOCATION_FILE_NAME  @"h.xh"

static CLLocation* S_FIXED_LOCATION = nil;
static BOOL S_ISSET = -1;

@implementation LocationTravelingService

+ (NSInteger) pointsForDistance:(CLLocationDistance)aDistance
{
    
#ifdef NO_DISTANCE_LIMIT
    return 0;
#endif
    
    CLLocationDistance aDistanceInKMs = aDistance/1000;
    
    NSInteger sPoints = 0;
    if (aDistanceInKMs < DISTANCE_LEVEL_1)
    {
        sPoints = 0;
    }
    else if (aDistanceInKMs <DISTANCE_LEVEL_2)
    {
        sPoints = 10;
    }
    else if (aDistanceInKMs < DISTANCE_LEVEL_3)
    {
        sPoints = 20;
    }
    else if (aDistanceInKMs < DISTANCE_LEVEL_4)
    {
        sPoints = 50;
    }
    else
    {
        sPoints = 100;
    }
    
//    if (aDistanceInKMs < FREE_DISTANCE_KM)
//    {
//        sPoints = 0;
//    }
//    else if (aDistanceInKMs >= FREE_DISTANCE_KM)
//    {
//        sPoints = aDistanceInKMs/10;
//    }
//    else
//    {
//        sPoints = 0;
//    }
    
    return sPoints;
}

+ (BOOL) canSetTravelingLocationAt:(CLLocation*)aLocation
{    
    CLLocation* sCurrentLocation = [[LocationSource getTrueLocationSource] getMostRecentLocation];
    CLLocationDistance sDistance = [sCurrentLocation distanceFromLocation:aLocation];
    
    NSInteger sPoints = [[PointsManager shared] getPoints];
    NSInteger sPointsToBeConsumed = [self pointsForDistance:sDistance];
    if (sPointsToBeConsumed <= sPoints)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL) consumePoints
{
    NSInteger sPointsToBeConsumed = [self pointsForCurrentFixedLocation];
    if ([[PointsManager shared] consume:sPointsToBeConsumed])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (NSInteger) pointsForCurrentFixedLocation
{
    CLLocation* sCurrentLocation = [[LocationSource getTrueLocationSource] getMostRecentLocation];
    CLLocationDistance sDistance = [sCurrentLocation distanceFromLocation:[self getFixedLocation]];
    
    NSInteger sPoints = [self pointsForDistance:sDistance];
    return sPoints;
}

+ (NSString*) getFixedLocationDataFilePath
{
    NSString* sBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString* sPath = [sBundlePath stringByAppendingPathComponent: FIXED_LOCATION_FILE_NAME];
    
    //    NSLog(@"bundlePath:%@ Path:%@", sBundlePath, sPath);
    return sPath;
}

+ (void) writeInfoToFile:(BOOL)aIsSet Location:(CLLocation*)aLocation
{
    NSMutableDictionary* sLocationDict = [NSMutableDictionary dictionaryWithCapacity: 2];
    
    [sLocationDict setValue:[NSDate date] forKey:@"timestamp"];
    [sLocationDict setValue: [NSNumber numberWithBool:aIsSet] forKey:@"isset"];
    //CLLocation in NSDictionary cannot be written to file. cos,
    //This method recursively validates that all the contained objects are property list objects (instances of NSData, NSDate, NSNumber, NSString, NSArray, or NSDictionary) before writing out the file, and returns NO if all the objects are not property list objects, since the resultant file would not be a valid property list.
    [sLocationDict setValue:[NSKeyedArchiver archivedDataWithRootObject:aLocation] forKey:@"location"];
    
    [sLocationDict writeToFile: [self getFixedLocationDataFilePath] atomically:YES];
    
}


+ (void) setFixedLocation:(CLLocation*)aLocation
{
    if (aLocation)
    {
        [S_FIXED_LOCATION release];
        S_FIXED_LOCATION = [aLocation retain];
    }
    
    BOOL sIsSet = [self isSet];
    CLLocation* sLocation = S_FIXED_LOCATION;
    
    [self writeInfoToFile: sIsSet Location: sLocation];
}

+ (void) setIsSet:(BOOL)aIsSet
{
    S_ISSET = aIsSet;
    
    BOOL sIsSet = S_ISSET;
    CLLocation* sLocation = [self getFixedLocation];
    
    [self writeInfoToFile: sIsSet Location: sLocation];
    
}

+ (void) setIsSet
{
    [self setIsSet:YES];
}

+ (void) unsetIsSet
{
    [self setIsSet:NO];
}

+ (BOOL) isSet
{
    if (S_ISSET != -1)
    {
        return S_ISSET;
    }
    else
    {
        NSDictionary* sLocationDict = [NSDictionary dictionaryWithContentsOfFile: [self getFixedLocationDataFilePath]];

        if (sLocationDict)
        {
            NSNumber* sIsSet = (NSNumber*)[sLocationDict objectForKey:@"isset"];
            if (sIsSet)
            {
                S_ISSET = sIsSet.boolValue;
                return S_ISSET;
            }
        }
        S_ISSET = NO;
        return S_ISSET;
    }
    
}

+ (CLLocation*) getFixedLocation
{
    if (S_FIXED_LOCATION)
    {
        return S_FIXED_LOCATION;
    }
    else
    {
        NSDictionary* sLocationDict = [NSDictionary dictionaryWithContentsOfFile: [self getFixedLocationDataFilePath]];
        
        if (sLocationDict)
        {
            CLLocation* sFixedLocation = [NSKeyedUnarchiver unarchiveObjectWithData: (NSData *)[sLocationDict objectForKey:@"location"]];
            [S_FIXED_LOCATION release];
            S_FIXED_LOCATION = [sFixedLocation retain];
            return S_FIXED_LOCATION;
        }
        return nil;
    }
}

+ (BOOL) isFixedLocationAvaliable
{
    if ([self getFixedLocation])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL) isTraveling
{
    if ([self isSet])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL) startTraveling
{
    if ([self isTraveling])
    {
        return YES;
    }
    
    if ([self canSetTravelingLocationAt:[self getFixedLocation]])
    {
        [self setIsSet];
        
        //if location positioning fails, then forbid traveling
        if (![[LocationSource getTrueLocationSource] getMostRecentLocation])
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    return NO;
}

+ (void) stopTraveling
{
    if ([self isTraveling])
    {
        [self unsetIsSet];
    }
}



@end
