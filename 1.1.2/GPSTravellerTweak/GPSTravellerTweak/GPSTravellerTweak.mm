#line 1 "/Users/seeskyline/workplace/GitHub/GPSTraveller/GPSTravellerTweak/GPSTravellerTweak/GPSTravellerTweak.xm"





#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "MyLocationManagerDelegate.h"

#define DEBUG


static MyLocationManagerDelegate* mMyDelegate = nil;


#include <logos/logos.h>
#include <substrate.h>
@class CLLocationManager; 
static id (*_logos_meta_orig$_ungrouped$CLLocationManager$sharedInstance)(Class, SEL); static id _logos_meta_method$_ungrouped$CLLocationManager$sharedInstance(Class, SEL); static void (*_logos_meta_orig$_ungrouped$CLLocationManager$initialize)(Class, SEL); static void _logos_meta_method$_ungrouped$CLLocationManager$initialize(Class, SEL); static void (*_logos_orig$_ungrouped$CLLocationManager$setDelegate$)(CLLocationManager*, SEL, id<CLLocationManagerDelegate>); static void _logos_method$_ungrouped$CLLocationManager$setDelegate$(CLLocationManager*, SEL, id<CLLocationManagerDelegate>); static CLLocation* (*_logos_orig$_ungrouped$CLLocationManager$location)(CLLocationManager*, SEL); static CLLocation* _logos_method$_ungrouped$CLLocationManager$location(CLLocationManager*, SEL); static void (*_logos_orig$_ungrouped$CLLocationManager$dealloc)(CLLocationManager*, SEL); static void _logos_method$_ungrouped$CLLocationManager$dealloc(CLLocationManager*, SEL); 

#line 16 "/Users/seeskyline/workplace/GitHub/GPSTraveller/GPSTravellerTweak/GPSTravellerTweak/GPSTravellerTweak.xm"



static id _logos_meta_method$_ungrouped$CLLocationManager$sharedInstance(Class self, SEL _cmd) {
	NSLog(@"+[<CLLocationManager: %p> sharedInstance]", self);

	return _logos_meta_orig$_ungrouped$CLLocationManager$sharedInstance(self, _cmd);
}


static void _logos_meta_method$_ungrouped$CLLocationManager$initialize(Class self, SEL _cmd)  {
	if (!mMyDelegate)
	{
		mMyDelegate = [[MyLocationManagerDelegate alloc] init];
	}
	_logos_meta_orig$_ungrouped$CLLocationManager$initialize(self, _cmd);
}


static void _logos_method$_ungrouped$CLLocationManager$setDelegate$(CLLocationManager* self, SEL _cmd, id<CLLocationManagerDelegate> aDelegate) {
	if (aDelegate)
	{
	#ifdef DEBUG
	NSLog(@"setDelegate:not nil");
	#endif
	
		[mMyDelegate addOriginalDelegate:aDelegate LocationManager: self];

    	_logos_orig$_ungrouped$CLLocationManager$setDelegate$(self, _cmd, mMyDelegate); 
	}
	else
	{
	#ifdef DEBUG
	NSLog(@"setDelegate:nil");
	#endif
	
		[mMyDelegate removeOriginalDelegateByLocationManager:self];
		_logos_orig$_ungrouped$CLLocationManager$setDelegate$(self, _cmd, aDelegate);
	}
}


static CLLocation* _logos_method$_ungrouped$CLLocationManager$location(CLLocationManager* self, SEL _cmd) {
 



	
	if (!mMyDelegate
		|| [mMyDelegate needsTrueLocationForLocationManager:self])
	{
		return _logos_orig$_ungrouped$CLLocationManager$location(self, _cmd);
	}
	else
	{
		FixedLocationData* sFixedLocationData = [mMyDelegate getFixedLocationData];
		if (sFixedLocationData
			&& sFixedLocationData.mIsSet)
		{
		#ifdef DEBUG
		NSLog(@"location:fixed");
		#endif
			return sFixedLocationData.mFixedLocation;
		}
		else
		{
		#ifdef DEBUG
		NSLog(@"location:orig");
		#endif
		
			return _logos_orig$_ungrouped$CLLocationManager$location(self, _cmd);	
		}
	}
}


static void _logos_method$_ungrouped$CLLocationManager$dealloc(CLLocationManager* self, SEL _cmd)  {
	[mMyDelegate removeOriginalDelegateByLocationManager:self];
	_logos_orig$_ungrouped$CLLocationManager$dealloc(self, _cmd);
}


static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$CLLocationManager = objc_getClass("CLLocationManager"); Class _logos_metaclass$_ungrouped$CLLocationManager = object_getClass(_logos_class$_ungrouped$CLLocationManager); MSHookMessageEx(_logos_metaclass$_ungrouped$CLLocationManager, @selector(sharedInstance), (IMP)&_logos_meta_method$_ungrouped$CLLocationManager$sharedInstance, (IMP*)&_logos_meta_orig$_ungrouped$CLLocationManager$sharedInstance);MSHookMessageEx(_logos_metaclass$_ungrouped$CLLocationManager, @selector(initialize), (IMP)&_logos_meta_method$_ungrouped$CLLocationManager$initialize, (IMP*)&_logos_meta_orig$_ungrouped$CLLocationManager$initialize);MSHookMessageEx(_logos_class$_ungrouped$CLLocationManager, @selector(setDelegate:), (IMP)&_logos_method$_ungrouped$CLLocationManager$setDelegate$, (IMP*)&_logos_orig$_ungrouped$CLLocationManager$setDelegate$);MSHookMessageEx(_logos_class$_ungrouped$CLLocationManager, @selector(location), (IMP)&_logos_method$_ungrouped$CLLocationManager$location, (IMP*)&_logos_orig$_ungrouped$CLLocationManager$location);MSHookMessageEx(_logos_class$_ungrouped$CLLocationManager, @selector(dealloc), (IMP)&_logos_method$_ungrouped$CLLocationManager$dealloc, (IMP*)&_logos_orig$_ungrouped$CLLocationManager$dealloc);} }
#line 98 "/Users/seeskyline/workplace/GitHub/GPSTraveller/GPSTravellerTweak/GPSTravellerTweak/GPSTravellerTweak.xm"
