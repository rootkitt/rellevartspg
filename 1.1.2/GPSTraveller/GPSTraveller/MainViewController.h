
#import <CoreLocation/CLLocation.h>
#import <MapKit/MapKit.h>
#import "LocationSource.h"
#import "MyLocationAnnotation.h"

//MKReverseGeocoderDelegate
//CLGeocoder
@interface MainViewController: UIViewController<MKMapViewDelegate, LocationSourceDelegate>
{
    MKMapView* mMapView;
    
    UIBarButtonItem* mDeviceLocationBarButtonItem;
    UIBarButtonItem* mStartStopBarButtonItem;
    UIBarButtonItem* mTraveledLocationBarButtonItem;
    UIButton* mGlobalLocationButton;
    
    UILabel* mInfoBoardLabel;
    
    MyLocationAnnotation*  mDeviceLocationAnnotation;
    MyLocationAnnotation*  mTraveledLocationAnnotation;
    
    MKCircle* mCircle;

    LocationSource* mTravelingLocationSource;
    LocationSource* mTrueLocationSource;
    
    BOOL mAppearedBefore;
    
//    CLLocation* mLocationDelta;
    
    BOOL mIsInChina;
    BOOL mLocationEnabled;
}

@property (nonatomic, retain)  MKMapView* mMapView;
@property (nonatomic, retain)  UIBarButtonItem* mDeviceLocationBarButtonItem;
@property (nonatomic, retain)  UIBarButtonItem* mStartStopBarButtonItem;
@property (nonatomic, retain)  UIBarButtonItem* mTraveledLocationBarButtonItem;
@property (nonatomic, retain)  UIButton* mGlobalLocationButton;
@property (nonatomic, retain)  UILabel* mInfoBoardLabel;

@property (nonatomic, retain)  MyLocationAnnotation*  mDeviceLocationAnnotation;
@property (nonatomic, retain)  MyLocationAnnotation*  mTraveledLocationAnnotation;

@property (nonatomic, retain)  MKCircle* mCircle;

@property (nonatomic, retain)  LocationSource* mTravelingLocationSource;
@property (nonatomic, retain)  LocationSource* mTrueLocationSource;

@property (nonatomic, assign)  BOOL mAppearedBefore;

//@property (nonatomic, retain)  CLLocation* mLocationDelta;

@property (nonatomic, assign)  BOOL mIsInChina;

@property (nonatomic, assign)  BOOL mLocationEnabled;


- (void) decorateMapview;
- (void) addAnnotations;
- (void) addOverlay;

- (void) refreshTravelingLocationAvailablityStatus;
- (void) refreshTravelingStatusNotice;

//utility methods
- (void) selectAnnotation:(id<MKAnnotation>)aAnnotation AfterDelay:(NSTimeInterval)aSeconds;
//- (BOOL) isInChina;


//view showing
- (void) showTravelingLocationView;
- (void) showDeviceLocationView;
- (void) showGlobalView;
- (void) showTravelingLocationViewWithAnnotation:(BOOL)aAnnotaionOn;

- (void) goToLocation: (CLLocation*)aLocation;
- (void) goToLocation: (CLLocation*)aLocation span:(MKCoordinateSpan)aSpan animated:(BOOL)animated;

//location set control
//- (BOOL) canSetTravelingLocationAt:(CLLocation*)aLocation;


//go and travel to a new travelling location
- (void) goAndTravelToLocation:(CLLocation*)aLocation;


//location drift fix.
//- (CLLocationCoordinate2D) adjustLocationCoordinate:(CLLocationCoordinate2D)aCLLocationCoordinate2D Reverse:(BOOL)aReverse;
//- (CLLocation*) adjustLocation:(CLLocation*)aLocation;

+ (MainViewController*) shared;
- (void) makeToobarEnabled:(BOOL)aEnabled;

@end
