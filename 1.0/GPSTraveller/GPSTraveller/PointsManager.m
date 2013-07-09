//
//  PointsManager.m
//  AboutSex
//
//  Created by Wen Shane on 13-5-4.
//
//

#import "PointsManager.h"
#import "AdWallManager.h"
#import "SharedVariables.h"
#import "SharedStates.h"

#define DEFAULTS_CURRENT_POINTS         @"defaults_points_manager_current_points"


@interface PointsManager()
{
    NSMutableArray* mWalls;
    WallAdpater* mUsedWall;
    NSInteger mCurrentPoints;
    UIViewController* mPresentintController;
}
@property (nonatomic, retain) NSMutableArray* mWalls;
@property (nonatomic, retain) WallAdpater* mUsedWall;
@property (nonatomic, assign) NSInteger mCurrentPoints;
@property (nonatomic, retain) UIViewController* mPresentintController;
@end

@implementation PointsManager
@synthesize mWalls;
@synthesize mUsedWall;
@synthesize mCurrentPoints;
@synthesize mPresentintController;

+ (PointsManager*) shared
{
    static PointsManager* S_PointsManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        S_PointsManager = [[self alloc] init];
    });
    return S_PointsManager;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.mWalls = [AdWallManager allWalls];
        for (WallAdpater* sWall in self.mWalls)
        {
            sWall.mDelegate = self;
        }
        
        self.mUsedWall = [AdWallManager adWall];
        self.mUsedWall.mDelegate = self;
    }
    
    return self;
}

- (void) dealloc
{    
    self.mWalls = nil;    
    self.mUsedWall = nil;
    self.mPresentintController = nil;
    [super dealloc];
}


- (BOOL) consume:(NSInteger)aPoints
{
    NSInteger sCurrentPoints = [self getPoints];
    if (sCurrentPoints >= aPoints)
    {
        NSUserDefaults* sDefaults = [NSUserDefaults standardUserDefaults];
        [sDefaults setInteger:sCurrentPoints-aPoints forKey:DEFAULTS_CURRENT_POINTS];
        [sDefaults synchronize];
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSInteger) getPoints
{
    NSUserDefaults* sDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger sCurrentPoints = [sDefaults integerForKey:DEFAULTS_CURRENT_POINTS];

    return sCurrentPoints;
}

- (void) refreshPoints
{
    for (WallAdpater* sWall in self.mWalls)
    {
        [sWall getEarnedPoints];
    }
    
    return;
}

- (BOOL) showWallFromViewController:(UIViewController*)aPresentController
{
    if (!aPresentController)
    {
        return NO;
    }
    
    self.mPresentintController = aPresentController;
        
    NSString* sInstruction = [[SharedStates getInstance] getAcuringPointsInstruction];

    UIAlertView* sAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:sInstruction  delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"I know", nil), nil];
    [sAlertView show];
    [sAlertView release];
    
    return YES;
}


-(id)presentingViewController
{
    return self.mPresentintController;
}

-(void)didFailedGetWall
{
    
    NSLog(@"----did fail get wall-----");
}

-(void)didSuccessOpenWall
{
    NSLog(@"----did get wall-----");    
}

-(void)returnedEarendPoints:(NSInteger)aPoints
{
    NSLog(@"----returnedEarnedPoints---%d--", aPoints);
    
    if (aPoints > 0 )
    {
        NSUserDefaults* sDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger sCurrentPoints = [sDefaults integerForKey:DEFAULTS_CURRENT_POINTS];
        [sDefaults setInteger:sCurrentPoints+aPoints forKey:DEFAULTS_CURRENT_POINTS];
        [sDefaults synchronize];
    }

    return;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.mUsedWall showWall];
}

////
//-(void)didGetThePoint:(int)aPoint
//{
//    self.mCurrentPoints = aPoint;
//}
//
//-(void)didRefreshThePoint:(int)aPoint
//{
//    self.mCurrentPoints = aPoint;
//    //    [self.mWall savePoint];
//}
//
//-(void)didChangedThePoint:(int)aPoint andChangedPoint:(int)aCpoint
//{
//    NSLog(@"%s",__FUNCTION__);
//    self.mCurrentPoints = aPoint;
//    
//    //    [self.mWall savePoint];
//}
//
//-(void)didReceiveMogoWallConfig
//{
//    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
//}
//
//-(void)showWallByPriority:(NSArray *)configs
//{
//    
//}



@end
