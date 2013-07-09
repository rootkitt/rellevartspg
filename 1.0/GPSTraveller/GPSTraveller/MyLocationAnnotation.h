
#import <MapKit/MapKit.h>

@interface MyLocationAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D mCoordinate;
}

@property (nonatomic, assign) CLLocationCoordinate2D mCoordinate;


@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;


- (id) initWithTitle:(NSString*)aTitle;
@end