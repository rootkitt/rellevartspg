//
//  MyLocationManagerDelegate.m
//  GPSTravellerTweak
//
//  Created by Wen Shane on 13-4-2.
//
//

#import "MyLocationManagerDelegate.h"



@implementation FixedLocationData

@synthesize mTimestamp;
@synthesize mIsSet;
@synthesize mFixedLocation;

+ (FixedLocationData*) getNewInstance
{
    FixedLocationData* sInstance = [[[FixedLocationData alloc] init] autorelease];
    
    return sInstance;
}

- (void) dealloc
{
    self.mTimestamp = nil;
    self.mFixedLocation = nil;
    [super dealloc];
}


@end



/////////////////////////////////////////////////////////

@implementation LocationManager_Delegate

@synthesize mLocationManager;
@synthesize mDelegate;
@synthesize mNeedsTrueLocation;

+ (LocationManager_Delegate*) getNewInstance
{
    LocationManager_Delegate* sInstance = [[[LocationManager_Delegate alloc] init] autorelease];
    
    return sInstance;
}

- (void) setMDelegate:(id<CLLocationManagerDelegate>)aDelegate
{
    mDelegate = aDelegate;
    if (mDelegate)
    {
        NSString* sClassName = NSStringFromClass([mDelegate class]);
#ifdef DEBUG
        NSLog(@"class name: %@", sClassName);
#endif
        if ([sClassName isEqualToString: @"TrueLocationSource20121229"]) //"TrueLocationSource20121229" is the class name of the delegate who need the true location in GPSTraveller.app.
        {
            self.mNeedsTrueLocation = YES;
        }
        else
        {
            self.mNeedsTrueLocation = NO;
        }
    }
}

- (void) dealloc
{
    self.mLocationManager = nil;
    self.mDelegate = nil;
    [super dealloc];
}

@end

/////////////////////////////////////////////////////////
/*
 Map and SinaWeibo needs timestamp for new location.
 Momo needs a real new location, which hold right info on coordinate and altitude, and so on.
 for miliao and weixin, new location's coordinate is enough.
 */

#define SECONDS_OF_SINFFER_INTERVAL  5
#define DEFAULT_ALTITUDE (52.9236f)
#define DEFAULT_HORIZONTAL_ACCURACY (65.0000f)
#define DEFAULT_VERTICAL_ACCURACY (10.0000f)

@implementation MyLocationManagerDelegate
@synthesize mOriginalDelegates;
@synthesize mTimestamp;
@synthesize mFixedLocationOnoffSnifferTime;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.mOriginalDelegates = [NSMutableArray arrayWithCapacity: 5];
    }
    return self;
}

- (void) dealloc
{
    self.mOriginalDelegates = nil;
    self.mTimestamp = nil;
    [self.mFixedLocationOnoffSnifferTime invalidate];
    self.mFixedLocationOnoffSnifferTime = nil;
    [super dealloc];
}

- (NSString*) getFixedLocationDataFilePath
{
    return @"/Applications/GPSTraveller.app/h.xh";
}


- (FixedLocationData*) getFixedLocationData
{
    NSDictionary* sLocationDict = [NSDictionary dictionaryWithContentsOfFile: [self getFixedLocationDataFilePath]];
    
    if (sLocationDict)
    {
        FixedLocationData* sFixedLocationData = [FixedLocationData getNewInstance];
        sFixedLocationData.mTimestamp = (NSDate*)[sLocationDict objectForKey:@"timestamp"];
        sFixedLocationData.mIsSet = ((NSNumber*)[sLocationDict objectForKey:@"isset"]).boolValue;
        
        @try {
            CLLocation* sLocation = [NSKeyedUnarchiver unarchiveObjectWithData: (NSData *)[sLocationDict objectForKey:@"location"]];
            
            //create a fake location with default altitude, ha, va, NSDate date as timestamp, and coordinate from file.
            CLLocation* sFakeLocation = [[CLLocation alloc] initWithCoordinate:sLocation.coordinate altitude:DEFAULT_ALTITUDE horizontalAccuracy:DEFAULT_HORIZONTAL_ACCURACY verticalAccuracy:DEFAULT_VERTICAL_ACCURACY timestamp: [NSDate date]];
            
            sFixedLocationData.mFixedLocation = sFakeLocation;
            
            [sFakeLocation release];
        }
        @catch (NSException* exception) {
            NSLog(@"NSKeyedUnarchiver exceptions");
            return nil;
        }
        
        return sFixedLocationData;
    }
    return nil;
}

- (BOOL) getIsSet
{
    FixedLocationData* sFixedLocationData = [self getFixedLocationData];
    if (sFixedLocationData)
    {
        return sFixedLocationData.mIsSet;
    }
    return NO;
}

- (CLLocation*) getFixedLocation
{
    FixedLocationData* sFixedLocationData = [self getFixedLocationData];
    if (sFixedLocationData)
    {
        return sFixedLocationData.mFixedLocation;
    }
    return nil;
}

- (NSDate*) getTimestamp
{
    FixedLocationData* sFixedLocationData = [self getFixedLocationData];
    if (sFixedLocationData)
    {
        return sFixedLocationData.mTimestamp;
    }
    return nil;
}

//- (void) noticeLocationSetInfo
//{
//    if (self.mIsLocationSet)
//    {
//        NSString* sNotice = @"穿越中...";
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:sNotice 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//        [alert show];
//        [alert release];
//    }
//}

- (LocationManager_Delegate*) getLocationManagerDelegateByLocationManager:(CLLocationManager*)aLocationManager
{
#ifdef DEBUG
    NSLog(@"get loc-delegate.");
#endif
    
    for (LocationManager_Delegate* sLD in self.mOriginalDelegates)
    {
        if (sLD.mLocationManager == aLocationManager)
        {
#ifdef DEBUG
            NSLog(@"..loc-delegate got.");
#endif
            
            return sLD;
        }
    }
    
    return nil;
}

- (id<CLLocationManagerDelegate>) getOriginalDelegateByLocationManager:(CLLocationManager*)aLocationManager
{
#ifdef DEBUG
    NSLog(@"get delegate.");
#endif
    LocationManager_Delegate* sLocationManager_delegate = [self getLocationManagerDelegateByLocationManager: aLocationManager];
    if (sLocationManager_delegate)
    {
#ifdef DEBUG
        NSLog(@"..delegate got.");
#endif
        return sLocationManager_delegate.mDelegate;
    }
    else
    {
        return nil;
    }
}

- (void) addOriginalDelegate: (id<CLLocationManagerDelegate>)aDelegate LocationManager: (CLLocationManager*) aLocationManager
{
    if (!aDelegate
        || !aLocationManager)
    {
        return;
    }
    
    if (!self.mFixedLocationOnoffSnifferTime)
    {
        self.mFixedLocationOnoffSnifferTime = [NSTimer timerWithTimeInterval:SECONDS_OF_SINFFER_INTERVAL target:self selector: @selector(sniffFixedLocationSwitch) userInfo: nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.mFixedLocationOnoffSnifferTime forMode:NSDefaultRunLoopMode];
        
        //        [self.mFixedLocationOnoffSnifferTime fire];
    }
    
#ifdef DEBUG
    NSLog(@"add delegate.");
#endif
    
    [self removeOriginalDelegateByLocationManager: aLocationManager];
    
    LocationManager_Delegate* sLocationManager_delegate = [LocationManager_Delegate getNewInstance];
    sLocationManager_delegate.mLocationManager = aLocationManager;
    sLocationManager_delegate.mDelegate = aDelegate;
    
    [self.mOriginalDelegates addObject: sLocationManager_delegate];
#ifdef DEBUG
    NSLog(@"..delegate added.");
#endif
}

- (void) removeOriginalDelegateByLocationManager:(CLLocationManager*) aLocationManager
{
#ifdef DEBUG
    NSLog(@"remove delegate.");
#endif
    
    NSMutableIndexSet* sIndexesToDelete = [NSMutableIndexSet indexSet];
    NSUInteger sCurrentIndex = 0;
    
    for (LocationManager_Delegate* sLD in self.mOriginalDelegates)
    {
        if (sLD.mLocationManager == aLocationManager)
        {
            [sIndexesToDelete addIndex:sCurrentIndex];
        }
        sCurrentIndex++;
    }
#ifdef DEBUG
    NSLog(@"..delegate removed.");
#endif
    [self.mOriginalDelegates removeObjectsAtIndexes:sIndexesToDelete];
    
}

- (BOOL) needsTrueLocationForLocationManager:(CLLocationManager*) aLocationManager
{
    LocationManager_Delegate* sLocationManager_delegate = [self getLocationManagerDelegateByLocationManager: aLocationManager];
    if (sLocationManager_delegate
        && sLocationManager_delegate.mNeedsTrueLocation)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) sniffFixedLocationSwitch
{
#ifdef DEBUG
    NSLog(@"sniff...");
#endif
    FixedLocationData* sFixedLocationData = [self getFixedLocationData];
    
    if (self.mOriginalDelegates.count <= 0
        || !sFixedLocationData)
    {
        return;
    }
    
    
    NSDate* sTimestamp = sFixedLocationData.mTimestamp;
    if (!self.mTimestamp
        || (sTimestamp && ![sTimestamp isEqualToDate: self.mTimestamp]))
    {
        self.mTimestamp = sTimestamp;
        
        CLLocation* sNewLocation = nil;
        CLLocation* sOldLocation = nil;
        if (sFixedLocationData.mIsSet)
        {
#ifdef DEBUG
            NSLog(@"sniff_______fixed discovered.");
#endif
            sNewLocation = sFixedLocationData.mFixedLocation;
            sOldLocation = [[sNewLocation copy] autorelease];
        }
        else
        {
#ifdef DEBUG
            NSLog(@"sniff_______not fixed discovered.");
#endif
            LocationManager_Delegate* sLocMgr = [self.mOriginalDelegates objectAtIndex:0];
            sNewLocation = sLocMgr.mLocationManager.location;
            sOldLocation = [[sNewLocation copy] autorelease];
        }
        
        if (sNewLocation)
        {
            for (LocationManager_Delegate* sLD in self.mOriginalDelegates)
            {
                if (sLD.mDelegate
                    && sLD.mLocationManager
                    && [sLD.mDelegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)])
                {
#ifdef DEBUG
                    NSLog(@"sniff...change spreading.");
#endif
                    if (!sLD.mNeedsTrueLocation)
                    {
                        [sLD.mDelegate locationManager:sLD.mLocationManager didUpdateToLocation:sNewLocation fromLocation:sOldLocation];
                    }
                    
                }
            }
        }
    }
    else
    {
#ifdef DEBUG
        NSLog(@"sniff_____timestamp same.");
#endif
    }
}

#pragma mark -
#pragma mark Responding to Location Events
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
#ifdef DEBUG
    NSLog(@"updateToLocation.");
#endif
    LocationManager_Delegate* sLocationManager_delegate = [self getLocationManagerDelegateByLocationManager: manager];
    if (!sLocationManager_delegate)
    {
        return;
    }
    
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = sLocationManager_delegate.mDelegate;
    
    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)])
    {
        FixedLocationData* sFixedLocationData = [self getFixedLocationData];
        
        CLLocation* sNewLocation = nil;
        CLLocation* sOldLocation = nil;
        if (!sFixedLocationData
            || !sFixedLocationData.mIsSet
            || sLocationManager_delegate.mNeedsTrueLocation)
        {
            
            sNewLocation = newLocation;
            sOldLocation = oldLocation;
#ifdef DEBUG
            NSLog(@"dispatch orig location.");
#endif
        }
        else
        {
            
            CLLocation* sFixedLocation = sFixedLocationData.mFixedLocation;
            
            sNewLocation = sFixedLocation;
            sOldLocation = [[sFixedLocation copy] autorelease];
            
#ifdef DEBUG
            NSLog(@"dispatch fixed location.");
            NSLog(@"altitude:%.4f\tha:%.4f\tva:%.4f", newLocation.altitude, newLocation.horizontalAccuracy, newLocation.verticalAccuracy);
            
            NSString* sLocation = [NSString stringWithFormat:@"经度：%.4f \t 纬度：%.4f", sFixedLocation.coordinate.longitude, sFixedLocation.coordinate.latitude];
            NSLog(@"%@", sLocation);
#endif
        }
        
        [sDelegate locationManager:manager didUpdateToLocation:sNewLocation fromLocation:sOldLocation];
        
    }
    return;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return;
    }
    
    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didFailWithError:)])
    {
        [sDelegate locationManager:manager didFailWithError:error];
    }
    return;
}

#pragma mark -
#pragma mark Responding to Heading Events
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return;
    }
    
    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didUpdateHeading:)])
    {
        [sDelegate locationManager:manager didUpdateHeading:newHeading];
    }
    
    
    //    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didUpdateHeading:)])
    //    {
    //        return;
    //    }
    //
    //    [self.mOriginalDelegate locationManager:manager didUpdateHeading:newHeading];
    return;
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return NO;
    }
    
    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManagerShouldDisplayHeadingCalibration:)])
    {
        return [sDelegate locationManagerShouldDisplayHeadingCalibration:manager];
    }
    return NO;
    
    
    
    //    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManagerShouldDisplayHeadingCalibration:)])
    //    {
    //        return NO;
    //    }
    //
    //    return [self.mOriginalDelegate locationManagerShouldDisplayHeadingCalibration:manager];
}

#pragma mark -
#pragma mark Responding to Region Events
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return;
    }
    
    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didEnterRegion:)])
    {
        [sDelegate locationManager:manager didEnterRegion:region];
    }
    
    
    
    //    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didEnterRegion:)])
    //    {
    //        [self.mOriginalDelegate locationManager:manager didEnterRegion:region];
    //    }
    return;
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return;
    }
    
    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didExitRegion:)])
    {
        [sDelegate locationManager:manager didExitRegion:region];
    }
    return;
    
    //    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didExitRegion:)])
    //    {
    //        [self.mOriginalDelegate locationManager:manager didExitRegion:region];
    //    }
    //    return;
}

//- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
//{
//    [self.mOriginalDelegate locationManager:manager monitoringDidFailForRegion:region withError:error];
//    return;
//}
//
//- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
//{
//    [self.mOriginalDelegate locationManager:manager didStartMonitoringForRegion:region];
//    return;
//}

#pragma mark -
#pragma mark Responding to Authorization Changes
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    id<CLLocationManagerDelegate> sDelegate = nil;
    sDelegate = [self getOriginalDelegateByLocationManager: manager];
    if (!sDelegate)
    {
        return;
    }
    
    if (sDelegate && [sDelegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)])
    {
        [sDelegate locationManager:manager didChangeAuthorizationStatus:status];
    }
    
    return;
    
    
    //    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)])
    //    {
    //        [self.mOriginalDelegate locationManager:manager didChangeAuthorizationStatus:status];
    //    }
    //    
    //    return;
}


@end
