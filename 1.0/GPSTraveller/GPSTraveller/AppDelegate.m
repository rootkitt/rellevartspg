//
//  AppDelegate.m
//  GPSTraveller
//
//  Created by Wen Shane on 13-4-2.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

#import "AppDelegate.h"
#import "SharedVariables.h"
#import "MobClick.h"

#import "MainViewController.h"
#import "POIsViewController.h"
#import "PPRevealSideViewController.h"
#import "YouMiConfig.h"
#import "PointsManager.h"

@implementation AppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [YouMiConfig launchWithAppID: SECRET_ID_YOUMI appSecret: SECRET_KEY_YOUMI];
    [YouMiConfig setUseInAppStore:NO];//must be NO for jailbroken device
    [YouMiConfig setIsTesting:NO];

    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    UIViewController* sMainViewController = [MainViewController shared];    
    UINavigationController* sNavOfMainViewController = [[UINavigationController alloc] initWithRootViewController:sMainViewController];
//
    PPRevealSideViewController* sRootViewController = [[PPRevealSideViewController alloc] initWithRootViewController:sNavOfMainViewController];
    sRootViewController.panInteractionsWhenClosed = PPRevealSideInteractionNavigationBar|PPRevealSideInteractionContentView;
    sRootViewController.panInteractionsWhenOpened = PPRevealSideInteractionNavigationBar|PPRevealSideInteractionContentView|PPRevealSideInteractionNavigationToolBar;
    sRootViewController.tapInteractionsWhenOpened = PPRevealSideInteractionNavigationBar|PPRevealSideInteractionContentView|PPRevealSideInteractionNavigationToolBar;
    [sRootViewController setDirectionsToShowBounce:PPRevealSideDirectionNone];
    
    sRootViewController.delegate = self;

    self.window.rootViewController = sRootViewController;
    
    [sNavOfMainViewController release];
    [self.window makeKeyAndVisible];
    
    
    //UMeng SDK invocation
    [MobClick startWithAppkey:APP_KEY_UMENG reportPolicy:REALTIME channelId:CHANNEL_ID];
    
    [self checkUpdateAutomatically];
    return YES;
}

- (void) checkUpdateAutomatically
{
    [MobClick checkUpdate:NSLocalizedString(@"New Version Found", nil) cancelButtonTitle:NSLocalizedString(@"Skip", nil) otherButtonTitles:NSLocalizedString(@"Update now", nil)];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //refresh point from all ad platform
    [[PointsManager shared] refreshPoints];

    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) handleOpenClosedEventsAndEnableSubviews:(BOOL)enable
{
    for (UIView *vi in [[MainViewController shared].view subviews])
    {
        [vi setUserInteractionEnabled:enable];// this is the best way to keep functional the gestures
    }
    
}

//#pragma mark - PPRevealSideViewControllerDelegate
- (void)pprevealSideViewController:(PPRevealSideViewController *)controller willPushController:(UIViewController *)pushedController
{
    [self handleOpenClosedEventsAndEnableSubviews:NO];
    [[MainViewController shared] makeToobarEnabled:NO];
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPushController:(UIViewController *)pushedController
{
    [self handleOpenClosedEventsAndEnableSubviews:NO];
    [[MainViewController shared] makeToobarEnabled:NO];
}


- (void)pprevealSideViewController:(PPRevealSideViewController *)controller willPopToController:(UIViewController *)centerController
{
    [self handleOpenClosedEventsAndEnableSubviews:YES]; // Just to be sure in case we reuse the view
}

- (void)pprevealSideViewController:(PPRevealSideViewController *)controller didPopToController:(UIViewController *)centerController
{
    [self handleOpenClosedEventsAndEnableSubviews:YES];
    [[MainViewController shared] makeToobarEnabled:YES];

}

- (BOOL)pprevealSideViewController:(PPRevealSideViewController *)controller shouldDeactivateGesture:(UIGestureRecognizer *)gesture forView:(UIView *)view;
{
    NSString* sStr = NSStringFromClass([view.superview class]);
    if ([sStr isEqualToString:@"UIScrollView"]
        || [sStr isEqualToString:@"MKScrollView"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


@end
