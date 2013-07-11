#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "AboutViewController.h"
//#import "TraveledLocationPickerController.h"
#import "LocationTravelingService.h"
#import "SharedVariables.h"
#import "FavoritesManager.h"
#import "UIButtonLarge.h"
#import "POIsViewController.h"
#import "PPRevealSideViewController.h"
#import "MarsCoordinator.h"
#import "SharedStates.h"
#import "PointsManager.h"
#import "MobClick.h"

#define TAG_ALERT_VIEW_GET_POINTS 1011

static MainViewController* S_MainViewController = nil;

@implementation MainViewController
@synthesize mMapView;
@synthesize mDeviceLocationBarButtonItem;
@synthesize mStartStopBarButtonItem;
@synthesize mTraveledLocationBarButtonItem;
@synthesize mGlobalLocationButton;
@synthesize mInfoBoardLabel;
@synthesize mDeviceLocationAnnotation;
@synthesize mTraveledLocationAnnotation;
@synthesize mCircle;
@synthesize mTravelingLocationSource;
@synthesize mTrueLocationSource;
@synthesize mAppearedBefore;

//@synthesize mLocationDelta;

@synthesize mIsInChina;;
@synthesize mLocationEnabled;

+ (MainViewController*) shared
{
    @synchronized([MainViewController class]){
        if(S_MainViewController == nil){
            S_MainViewController = [[self alloc]init];
        }
    }
    return S_MainViewController;
    

}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.mAppearedBefore = NO;
//        self.mIsInChina = [self isInChina];
        self.mLocationEnabled = NO;
        
        //1. setting return text for navigation controller push
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = NSLocalizedString(@"Return", nil);
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [temporaryBarButtonItem release];

        //2. set bar items on navigation bar; ver weird tool bar items setting here does not work.
        self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        UIButton* sButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sButton setFrame: CGRectMake(0, 0, 24, 24)];
        [sButton setImage: [UIImage imageNamed:@"setting24.png"] forState:UIControlStateNormal];

        sButton.showsTouchWhenHighlighted = NO;
        [sButton addTarget:self action:@selector(presentAboutController) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem* sAboutBarButton = [[UIBarButtonItem alloc]initWithCustomView:sButton];
        self.navigationItem.rightBarButtonItem = sAboutBarButton;
        [sAboutBarButton release];
        
        
        UIButton* sFavButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sFavButton setFrame: CGRectMake(0, 0, 24, 24)];
        [sFavButton setImage: [UIImage imageNamed:@"favorite24.png"] forState:UIControlStateNormal];
        sFavButton.showsTouchWhenHighlighted = NO;
        [sFavButton addTarget:self action:@selector(presentFavoriteController) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem* sFavButtonItem = [[UIBarButtonItem alloc]initWithCustomView:sFavButton];
        self.navigationItem.leftBarButtonItem = sFavButtonItem;
        [sFavButtonItem release];        
        
        //3. set annotation.
        self.mDeviceLocationAnnotation = [[[MyLocationAnnotation alloc] initWithTitle:NSLocalizedString(@"Current Location", nil)] autorelease];
        self.mTraveledLocationAnnotation = [[[MyLocationAnnotation alloc] initWithTitle:NSLocalizedString(@"Target Location", nil)] autorelease];

        //set location source
        self.mTravelingLocationSource = [LocationSource getRegularLocationSource];
        self.mTrueLocationSource = [LocationSource getTrueLocationSource];
        self.mTrueLocationSource.mDelegate = self;
        
        //test
//        [LocationTravelingService setFixedLocation:[[[CLLocation alloc] initWithLatitude: 22.516077385444596 longitude: 113.99166869960027] autorelease]];
    }
    return self;
}

- (void) dealloc
{
    self.mMapView = nil;
    self.mDeviceLocationBarButtonItem = nil;
    self.mStartStopBarButtonItem = nil;
    self.mTraveledLocationBarButtonItem = nil;
    self.mGlobalLocationButton = nil;
    self.mInfoBoardLabel = nil;
    self.mCircle = nil;
    self.mDeviceLocationAnnotation = nil;
    self.mTraveledLocationAnnotation = nil;
    self.mTravelingLocationSource = nil;
//    self.mTrueLocationSource = nil;
    
//    self.mLocationDelta = nil;
    
    [super dealloc];
}

- (void)loadView {
    

    CGRect sAppFrame = [[UIScreen mainScreen] applicationFrame];
    sAppFrame.size.height -= (44+44);

    
//    NSLog(@"y: %.1f \theight:%.1f", sAppFrame.origin.y, sAppFrame.size.height);
    
	UIView* sView = [[[UIView alloc] initWithFrame:sAppFrame] autorelease];
    sView.backgroundColor = [UIColor whiteColor];
    self.view = sView;
    
//    NSLog(@"height of self.view.bounds:%.1f",self.view.bounds.size.height);

    //self.mMapView
    MKMapView* sMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [sMapView setMapType:MKMapTypeStandard];
    sMapView.delegate = self;
    sMapView.showsUserLocation = YES;
//    [sMapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
    [sMapView.userLocation addObserver:self forKeyPath:@"location" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    
    [self.view addSubview: sMapView];
    self.mMapView = sMapView;
    [sMapView release];
    
    //self.mInfoBoard
    UIView* sInfoboardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    sInfoboardView.backgroundColor = [UIColor clearColor];
        CAGradientLayer* sBackgroundGadientLayer =[[CAGradientLayer alloc] init];
    [sBackgroundGadientLayer setBounds:sInfoboardView.bounds];
    [sBackgroundGadientLayer setPosition:sInfoboardView.center];
    [sBackgroundGadientLayer setColors:[NSArray arrayWithObjects:(id)COLOR_GRADIENT_START_INFO_BOARD.CGColor, (id)COLOR_GRADIENT_END_INFO_BOARD.CGColor,nil]];
    [sInfoboardView.layer insertSublayer:sBackgroundGadientLayer atIndex:0];
    [sBackgroundGadientLayer release];
    
    UILabel* sLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.view.bounds.size.width-5, 15)];
    sLabel.backgroundColor = [UIColor clearColor];
    sLabel.textColor = [UIColor whiteColor];
    sLabel.font = [UIFont systemFontOfSize: 13];
    sLabel.numberOfLines = 0;
    [sInfoboardView addSubview:sLabel];
    self.mInfoBoardLabel = sLabel;
    [sLabel release];
    
    [self.view addSubview:sInfoboardView];
    [sInfoboardView release];
    
}




- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* sCurrentLocationBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"current_location20.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showDeviceLocationView)];
    self.mDeviceLocationBarButtonItem = sCurrentLocationBarButtonItem;
    
    UIBarButtonItem* sSpacerBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
    
     UIBarButtonItem* sStartStopBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"play20.png"] style:UIBarButtonItemStyleDone target:self action:@selector(startOrStopTraveling)];
    self.mStartStopBarButtonItem = sStartStopBarButtonItem;

    
    UIBarButtonItem* sSpacerBarButtonItem2 =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
    
    UIBarButtonItem* sTraveledLocationBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"travelinglocation20.png"] style: UIBarButtonItemStylePlain target:self action:@selector(showTravelingLocationView)];
    self.mTraveledLocationBarButtonItem = sTraveledLocationBarButtonItem;
    
    [self setToolbarItems: [NSArray arrayWithObjects: sCurrentLocationBarButtonItem, sSpacerBarButtonItem, sStartStopBarButtonItem, sSpacerBarButtonItem2, sTraveledLocationBarButtonItem, nil] animated: YES];
    
    [sCurrentLocationBarButtonItem release];
    [sSpacerBarButtonItem release];
    [sStartStopBarButtonItem release];
    [sSpacerBarButtonItem2 release];
    [sTraveledLocationBarButtonItem release];
    
    //globalview button above mapview
    UIButton* sGlobalViewButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [sGlobalViewButton setFrame: CGRectMake(self.view.bounds.size.width-27-10, self.view.bounds.size.height-27-10, 27, 27)];
    [sGlobalViewButton setImage: [UIImage imageNamed:@"globalview20.png"] forState:UIControlStateNormal];
    sGlobalViewButton.layer.cornerRadius  = 4;
    sGlobalViewButton.backgroundColor = COLOR_FLOAT_BUTTON_ON_MAP;
    [sGlobalViewButton addTarget: self action:@selector(showGlobalView) forControlEvents: UIControlEventTouchDown];
    [self.view addSubview: sGlobalViewButton]; 
    
    self.mGlobalLocationButton = sGlobalViewButton;
    
    
    //
    UILongPressGestureRecognizer* sLongPressGenstureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnMapview:)];
    sLongPressGenstureRecognizer.minimumPressDuration = 0.4;
    [self.mMapView addGestureRecognizer:sLongPressGenstureRecognizer];
    [sLongPressGenstureRecognizer release];
    
    
    [self refreshTravelingLocationAvailablityStatus];
    [self refreshTravelingStatusNotice];


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];

    [self.navigationController setToolbarHidden:NO];
    if (!self.mAppearedBefore)
    {
//        [self refreshTravelingLocationAvailablityStatus];
//        [self refreshTravelingStatusNotice];
    }
    [self refreshWhenLocationEnabledChange];
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(preloadLeft) object:nil];
    [self performSelector:@selector(preloadLeft) withObject:nil afterDelay:0.3];

}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.revealSideViewController unloadViewControllerForSide:PPRevealSideDirectionLeft];
}

- (void) preloadLeft
{
    [self.revealSideViewController preloadViewController:[POIsViewController shared] forSide:PPRevealSideDirectionLeft withOffset:SIDEBAR_OFFSET];
}

- (void) presentFavoriteController
{
    [self.revealSideViewController pushViewController:[POIsViewController shared] onDirection:PPRevealSideDirectionLeft withOffset:SIDEBAR_OFFSET animated:YES completion:^{
    }];
}

- (void) makeToobarEnabled:(BOOL)aEnabled
{
    if (!self.mLocationEnabled)
    {
        self.mDeviceLocationBarButtonItem.enabled = NO;
    }
    else
    {
        self.mDeviceLocationBarButtonItem.enabled = aEnabled;
    }
}

- (void) refreshTravelingLocationAvailablityStatus
{
    if ([LocationTravelingService isFixedLocationAvaliable])
    {
        self.mTraveledLocationBarButtonItem.enabled = YES;
    }
    else
    {
        self.mTraveledLocationBarButtonItem.enabled = NO;
    }
}

- (void) refreshTravelingStatusNotice
{
    if ([LocationTravelingService isTraveling])
    {
        self.mStartStopBarButtonItem.image = [UIImage imageNamed:@"pause20.png"];
        self.mInfoBoardLabel.text = NSLocalizedString(@"Exploring On...", nil);
    }
    else
    {
        self.mStartStopBarButtonItem.image = [UIImage imageNamed:@"play20.png"];
        self.mInfoBoardLabel.text =  NSLocalizedString(@"Exploring Off...", nil);
    }
}

- (void) refreshWhenLocationEnabledChange
{
    if (self.mLocationEnabled)
    {
        self.mDeviceLocationBarButtonItem.enabled = YES;
        [self refreshTravelingLocationAvailablityStatus];
        self.mStartStopBarButtonItem.enabled = YES;
        self.mGlobalLocationButton.enabled = YES;
        
        [self refreshTravelingStatusNotice];
    }
    else
    {
        self.mDeviceLocationBarButtonItem.enabled = NO;
        self.mTraveledLocationBarButtonItem.enabled = NO;
        self.mStartStopBarButtonItem.enabled = NO;
        self.mGlobalLocationButton.enabled = NO;
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            self.mInfoBoardLabel.text =  NSLocalizedString(@"Location service unvailable, check your settings please.", nil);
        }
        else
        {
            self.mInfoBoardLabel.text =  NSLocalizedString(@"Positioning...", nil);
        }
    }
}

#pragma mark - mapview decoration methods
////////////////////////////////////////////////////
- (void) decorateMapview
{
    if (!self.mAppearedBefore)
    {
        [self addAnnotations];
        [self addOverlay];
        
        if ([LocationTravelingService isTraveling])
        {
            [self showTravelingLocationViewWithAnnotation:NO];
            [self selectAnnotation:self.mTraveledLocationAnnotation AfterDelay:2];
        }
        else
        {
            [self showGlobalView];
        }
                
        self.mAppearedBefore = YES;
    }
}

- (void) addAnnotations
{
    CLLocation* sDeviceLocation = [self.mTrueLocationSource getMostRecentLocation];
        
    if (sDeviceLocation)
    {
//        CLLocationCoordinate2D sAdjustedDeviceCoordinate = [self adjustLocationCoordinate: sDeviceLocation.coordinate Reverse: NO];
        CLLocationCoordinate2D sAdjustedDeviceCoordinate = [[MarsCoordinator shared] getMarsCoordinateFromRealCoordinate:sDeviceLocation.coordinate];

        self.mDeviceLocationAnnotation.mCoordinate = sAdjustedDeviceCoordinate;
        [self.mMapView addAnnotation:self.mDeviceLocationAnnotation];
    }

    CLLocation* sTravlingLocation = [self.mTravelingLocationSource getMostRecentLocation];
    
    if (sTravlingLocation)
    {
#ifdef DEBUG
        NSLog(@"_________B1:sTravlingLocation.coordinate: %@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), sTravlingLocation.coordinate.longitude, NSLocalizedString(@"Latitude", nil), sTravlingLocation.coordinate.latitude);
#endif
        
//        CLLocationCoordinate2D sAdjustedTravelingCoordinate = [self adjustLocationCoordinate: sTravlingLocation.coordinate Reverse: NO];
        CLLocationCoordinate2D sAdjustedTravelingCoordinate = [[MarsCoordinator shared] getMarsCoordinateFromRealCoordinate:sTravlingLocation.coordinate];

#ifdef DEBUG
        NSLog(@"_________B2:sAdjustedTravelingCoordinate: %@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), sAdjustedTravelingCoordinate.longitude, NSLocalizedString(@"Latitude", nil), sAdjustedTravelingCoordinate.latitude);
#endif

        
        self.mTraveledLocationAnnotation.mCoordinate  = sAdjustedTravelingCoordinate;
        [self.mMapView addAnnotation:self.mTraveledLocationAnnotation];
    }
}

- (void) addOverlay
{
    CLLocation* sDeviceLocation = [self.mTrueLocationSource getMostRecentLocation];

//    CLLocation* sAdjustedDeviceLocation = [self adjustLocation: sDeviceLocation];
    CLLocation* sAdjustedDeviceLocation = [[MarsCoordinator shared] getMarsLocationFromRealLocation:sDeviceLocation];

    
    self.mCircle = [MKCircle circleWithCenterCoordinate:sAdjustedDeviceLocation.coordinate radius:FREE_DISTANCE_KM*1000];
    
    [self.mMapView addOverlay:self.mCircle];
}


#pragma mark - about controller methods
////////////////////////////////////////////////////

- (void) presentAboutController
{
    AboutViewController* sAboutViewController = [[AboutViewController alloc] initWithStyle:UITableViewStyleGrouped];
    sAboutViewController.hidesBottomBarWhenPushed = YES;
    sAboutViewController.title = NSLocalizedString(@"Setting", nil);
    [self.navigationController pushViewController:sAboutViewController animated:YES];
    [sAboutViewController release];
    
}

#pragma mark - methods respoding to user events
////////////////////////////////////////////////////

- (void) startOrStopTraveling
{
    if ([LocationTravelingService isTraveling])
    {
        [self stopTraveling];
    }
    else
    {
        if ([LocationTravelingService isFixedLocationAvaliable])
        {
            [self startTraveling];
            NSDictionary* sDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [self.mTraveledLocationAnnotation getDesp], @"location", nil];
            [MobClick event:@"UEID_TRAVEL" attributes: sDict];
        }
        else
        {
#ifdef DEBUG
            NSLog(@"You MUST set a traveling location first.");
#endif
            NSString* sNotice = NSLocalizedString(@"You must choose a location before traveling", nil);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:sNotice 	delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
    }
}

- (void) startTraveling
{
    if ([LocationTravelingService isTraveling])
    {
        return;
    }
    
    if ([LocationTravelingService startTraveling])
    {
        [[SharedStates getInstance] playSoundForStart];

        [self showTravelingLocationView];
        [self refreshTravelingStatusNotice];
        [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];
        [[self.mMapView viewForAnnotation:self.mTraveledLocationAnnotation] setNeedsDisplay];
        
        //points consumption with notice
        [LocationTravelingService consumePoints];
        NSInteger sPoints = [LocationTravelingService pointsForCurrentFixedLocation];
        if (sPoints > 0)
        {
            [[SharedStates getInstance] showNotice:[NSString stringWithFormat:NSLocalizedString(@"This travel consumes %d points", nil), sPoints]];
        }
    }
    else
    {
        if (![[LocationSource getTrueLocationSource] getMostRecentLocation])
        {
            [[SharedStates getInstance] showNotice:NSLocalizedString(@"Location service unvailable, traveling fails", nil)];
        }
        else
        {
//            NSString* sNotice = [NSString stringWithFormat:NSLocalizedString(@"This travel needs %d points, please acuire more points", nil), [LocationTravelingService pointsForCurrentFixedLocation]];
            NSString* sNotice = [NSString stringWithFormat:NSLocalizedString(@"Points low, please acquire more", nil)];
            UIAlertView* sAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:sNotice  delegate:self cancelButtonTitle:NSLocalizedString(@"Later", nil) otherButtonTitles:NSLocalizedString(@"Acquire now", nil), nil];
            sAlertView.tag = TAG_ALERT_VIEW_GET_POINTS;
            [sAlertView show];
            [sAlertView release];
        }

        return;
    }

}

#pragma mark -
#pragma mark delegate for update checking's alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == TAG_ALERT_VIEW_GET_POINTS)
    {
        BOOL sIsGet = NO;
        if (1 == buttonIndex)
        {
            [[PointsManager shared] showWallFromViewController:self];
            sIsGet = YES;
        }
        
        NSDictionary* sDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithBool:sIsGet], @"IsGet", nil];
        [MobClick event:@"UEID_GET_POINTS_WHEN_LOW" attributes: sDict];

    }
}


- (void) stopTraveling
{
    if (![LocationTravelingService isTraveling])
    {
        return;
    }

    [LocationTravelingService stopTraveling];
    [self refreshTravelingStatusNotice];
    [self.mMapView deselectAnnotation:self.mTraveledLocationAnnotation animated:YES];
    [[self.mMapView viewForAnnotation:self.mTraveledLocationAnnotation] setNeedsDisplay];
}

- (void)longPressOnMapview:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
    {
        return;
    }
    
    CGPoint sTouchPoint = [gestureRecognizer locationInView:self.mMapView];
    CLLocationCoordinate2D sTouchMapCoordinate = [self.mMapView convertPoint:sTouchPoint toCoordinateFromView:self.mMapView];
//    CLLocationCoordinate2D sRealCoordinate = [self adjustLocationCoordinate: sTouchMapCoordinate Reverse:YES];
    CLLocationCoordinate2D sRealCoordinate = [[MarsCoordinator shared] getRealCoordinateFromMarsCoordinate:sTouchMapCoordinate];

    CLLocation* sRealLocation = [[[CLLocation alloc] initWithLatitude:sRealCoordinate.latitude longitude: sRealCoordinate.longitude] autorelease];
    
    [self travelToLocation:sRealLocation];
}

#pragma mark - utility methods
////////////////////////////////////////////////////
- (void) selectAnnotationImp:(NSTimer*)timer
{
    NSDictionary* sDict = [timer userInfo];
    
    id<MKAnnotation> sAnnotation = [sDict objectForKey:@"annotation"];
    
    if (sAnnotation)
    {
        [self.mMapView selectAnnotation:sAnnotation animated:YES];
    }
}

- (void) selectAnnotation:(id<MKAnnotation>)aAnnotation AfterDelay:(NSTimeInterval)aSeconds
{
    
    NSDictionary* sDict = [NSDictionary dictionaryWithObject: aAnnotation forKey:@"annotation"];
    NSTimer* sTimer = [[[NSTimer alloc] initWithFireDate: [NSDate dateWithTimeIntervalSinceNow:aSeconds]interval:0 target:self selector: @selector(selectAnnotationImp:) userInfo:sDict repeats:NO] autorelease];
    
    [[NSRunLoop currentRunLoop] addTimer:sTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark - view showing methods
///////////////////////////////////////////////////////////////////////////////
- (void) showTravelingLocationViewWithAnnotation:(BOOL)aAnnotaionOn
{
    if ([LocationTravelingService isFixedLocationAvaliable])
    {
        CLLocation* sLocation = [self.mTravelingLocationSource getMostRecentLocation];
        [self goToLocation: sLocation];
        if (aAnnotaionOn)
        {
            [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];
        }
    }
}

- (void) showDeviceLocationViewWithAnnotation:(BOOL)aAnnotationOn
{
    CLLocation* sLocation = [self.mTrueLocationSource getMostRecentLocation];

    [self goToLocation: sLocation];
    if (aAnnotationOn)
    {
        [self.mMapView selectAnnotation:self.mDeviceLocationAnnotation animated:YES];  
    }

}

- (void) showTravelingLocationView
{
    [self showTravelingLocationViewWithAnnotation: YES];
}

- (void) showDeviceLocationView
{
    [self showDeviceLocationViewWithAnnotation: YES];
}

-(void) showGlobalView
{
    [self.mMapView setVisibleMapRect:self.mCircle.boundingMapRect animated:YES];
    return;
}

- (void) goAndTravelToLocation:(CLLocation*)aLocation
{
    [self goToLocation:aLocation];
    
    [self travelToLocation:aLocation];
}

//travel there.
- (void) travelToLocation:(CLLocation*)aLocation
{    
    {
        //1. remove the last annotation
        [self.mMapView removeAnnotation:self.mTraveledLocationAnnotation];
        
        //2. update mTraveledLocationAnnotation's location
//        CLLocationCoordinate2D sAdjustedCoordinate2D = [self adjustLocationCoordinate:aLocation.coordinate Reverse:NO];
        CLLocationCoordinate2D sMarsCoordinate2D = [[MarsCoordinator shared] getMarsCoordinateFromRealCoordinate:aLocation.coordinate];
        self.mTraveledLocationAnnotation.mCoordinate = sMarsCoordinate2D;
        
        //3. enable travling location view button if needed
        if (![LocationTravelingService isFixedLocationAvaliable])
        {
            self.mTraveledLocationBarButtonItem.enabled = YES;
        }
        
        //4. add new annotation
        [self.mMapView addAnnotation: self.mTraveledLocationAnnotation];
        
        //5. update new fixed location.
        [LocationTravelingService setFixedLocation:aLocation];
        
        //6. select new annotation to show its annotationview
        [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];
        
        //7.stop travelling
        [self stopTraveling];
    }
    
}

- (void) goToLocation: (CLLocation*)aLocation
{
    MKCoordinateSpan sSpan;
    
    sSpan.latitudeDelta=0.005;
    sSpan.longitudeDelta=0.005;

    [self goToLocation: aLocation span: sSpan animated:YES];
}


- (void) goToLocation: (CLLocation*)aLocation span:(MKCoordinateSpan)aSpan animated:(BOOL)animated
{    
    MKCoordinateRegion sRegion;
    
//    CLLocationCoordinate2D sAdjustedCoordinate2D = [self adjustLocationCoordinate:aLocation.coordinate Reverse:NO];
    CLLocationCoordinate2D sAdjustedCoordinate2D = [[MarsCoordinator shared] getMarsCoordinateFromRealCoordinate:aLocation.coordinate];

    
    sRegion.center = sAdjustedCoordinate2D;
    sRegion.span = aSpan;
    
    [self.mMapView setRegion: sRegion animated: animated];
}





#pragma mark - LocationSourceDelegate

#pragma mark - MKMapViewDelegate methods

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    //hide annotation view for userLocation.
    MKAnnotationView *ulv = [mapView viewForAnnotation:mapView.userLocation];
    ulv.hidden = YES;
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    if ([annotation isEqual: self.mDeviceLocationAnnotation])
    {
        MKAnnotationView* sPinView = (MKAnnotationView *)[self.mMapView dequeueReusableAnnotationViewWithIdentifier:@"customAnnotationView"];
        if (!sPinView)
        {
            sPinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"customAnnotationView"] autorelease];
            //        sPinView.animatesDrop = YES;
            sPinView.canShowCallout = YES;
        }
        else
        {
            sPinView.annotation = annotation;
        }
        sPinView.image = [UIImage imageNamed:@"currenlocation24.png"];
        return sPinView;
    }
    else if ([annotation isEqual: self.mTraveledLocationAnnotation])
    {
        MKPinAnnotationView* sPinView = (MKPinAnnotationView *)[self.mMapView dequeueReusableAnnotationViewWithIdentifier:@"pinAnnotationView"];
        if (!sPinView)
        {
            sPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAnnotationView"] autorelease];
            sPinView.animatesDrop = YES;
            sPinView.canShowCallout = YES;
            sPinView.pinColor = MKPinAnnotationColorRed;
            
            UIButtonLarge* sFavoriteButton = [UIButtonLarge buttonWithType:UIButtonTypeCustom];
            [sFavoriteButton setFrame:CGRectMake(0, 0, 24, 24)];
            sFavoriteButton.mMarginInsets = UIEdgeInsetsMake(20, 20, 20, 20);

            [sFavoriteButton setImage:[UIImage imageNamed:@"favorite24"] forState:UIControlStateNormal];
            [sFavoriteButton setImage:[UIImage imageNamed:@"favorite_selected24"] forState:UIControlStateSelected];
            [sFavoriteButton addTarget:self action:@selector(favoriteButtonClicked:) forControlEvents:UIControlEventTouchDown];

            
            sPinView.rightCalloutAccessoryView = sFavoriteButton;
        }

        sPinView.annotation = annotation;
        
        CLLocationCoordinate2D sRealCoordinate = [[MarsCoordinator shared] getRealCoordinateFromMarsCoordinate:((MyLocationAnnotation*)annotation).mCoordinate];

        if ([[FavoritesManager shared] isCoordinateFavorited:sRealCoordinate])
        {
            [((UIButton*)(sPinView.rightCalloutAccessoryView)) setSelected:YES];
        }
        else
        {
            [((UIButton*)(sPinView.rightCalloutAccessoryView)) setSelected:NO];
        }
        

        return sPinView;
    }
    else
    {
        return nil;
    }
    
}

- (void) favoriteButtonClicked:(UIButton*)aButton
{
    BOOL sNewSelectedStatus = !aButton.selected;
    
    //
    FavoritePOI* sLocationRecord = [FavoritePOI locationRecordWithMyLocationAnnotation:self.mTraveledLocationAnnotation];
    
    if (sNewSelectedStatus)
    {
        if ([[FavoritesManager shared] addFavorite:sLocationRecord])
        {
            [aButton setSelected:YES];
        }
    }
    else
    {
        [[FavoritesManager shared] removeFavorite:sLocationRecord];
        [aButton setSelected:NO];
    }
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay
{
    MKCircleView* circleView = [[[MKCircleView alloc] initWithOverlay:overlay] autorelease];
    circleView.strokeColor = [UIColor blueColor];
    circleView.lineWidth = 1.0;
    circleView.lineDashPhase = 15;
    //Uncomment below to fill in the circle
//    circleView.fillColor = [UIColor redColor];
    return circleView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CLLocation* sAdjustedRegularLocation = self.mMapView.userLocation.location;
    
#ifdef DEBUG
    NSLog(@"mMapView.userLocation: %@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), sAdjustedRegularLocation.coordinate.longitude, NSLocalizedString(@"Latitude", nil), sAdjustedRegularLocation.coordinate.latitude);
#endif
    
    if (!self.mLocationEnabled
        && fabs(sAdjustedRegularLocation.coordinate.latitude) < 0.1
        && fabs(sAdjustedRegularLocation.coordinate.longitude) < 0.1)
    {
        [self refreshWhenLocationEnabledChange];
        return;
    }
    else
    {
        if (!self.mLocationEnabled)
        {
            self.mLocationEnabled = YES;
            [self refreshWhenLocationEnabledChange];
            [self decorateMapview];
        }
    }
    
}


@end
