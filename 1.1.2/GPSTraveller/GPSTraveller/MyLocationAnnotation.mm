
#import "MyLocationAnnotation.h"
#import <CoreLocation/CLGeocoder.h>

@implementation MyLocationAnnotation
@synthesize mCoordinate;

@synthesize title, subtitle;

+ (NSString*) returnEmptyStringIfNil:(NSString*)aStr
{
    if (aStr)
    {
        return aStr;
    }
    else
    {
        return @"";
    }
}


- (id) initWithTitle:(NSString*)aTitle
{
    self = [super init];
    if (self)
    {
        self.title = aTitle;
    }
    return self;
}

- (void) setMCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    mCoordinate = aCoordinate;
    
    self.subtitle = NSLocalizedString(@"Location info loading...", nil);
    
    CLLocation* sLocation = [[CLLocation alloc] initWithLatitude:mCoordinate.latitude longitude:mCoordinate.longitude];
    
    CLGeocoder* sGeocoder = [[CLGeocoder alloc] init];
    [sGeocoder reverseGeocodeLocation:sLocation completionHandler:^(NSArray *placemarks, NSError *error){
        CLPlacemark* sPlacemark = [placemarks objectAtIndex:0];
        NSString* sGeoInfo = [NSString stringWithFormat:@"%@%@%@%@%@%@", [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.country],  [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.administrativeArea],  [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.locality],  [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.subLocality],  [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.thoroughfare],  [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.subThoroughfare]];
        if (sGeoInfo.length > 0)
        {
            self.subtitle = sGeoInfo;
        }
        
    }];
    
    [sLocation release];
    [sGeocoder release];
}

- (CLLocationCoordinate2D)coordinate;
{
    return self.mCoordinate;
}

- (NSString*) getDesp;
{
    if (!self.subtitle
        || [self.subtitle isEqualToString:NSLocalizedString(@"Location info loading...", nil)])
    {
        NSString* sCoordinateInfo = [NSString stringWithFormat:@"%@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil),self.mCoordinate.longitude, NSLocalizedString(@"Latitude", nil), self.mCoordinate.latitude];
        return sCoordinateInfo;
    }
    else
    {
        return self.subtitle;
    }
}


@end