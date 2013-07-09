
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
    
    NSString* sCoordinateInfo = [NSString stringWithFormat:@"%@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), self.coordinate.longitude, NSLocalizedString(@"Latitude", nil), self.coordinate.latitude];
    self.subtitle = sCoordinateInfo;
    
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

@end