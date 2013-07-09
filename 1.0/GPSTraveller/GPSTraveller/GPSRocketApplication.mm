#import "MainViewController.h"
#import "SharedVariables.h"
#import "MobClick.h"



@interface GPSRocketApplication: UIApplication <UIApplicationDelegate> {
	UIWindow *_window;
	MainViewController *_viewController;
}
@property (nonatomic, retain) UIWindow *window;
@end

@implementation GPSRocketApplication
@synthesize window = _window;


- (void) checkUpdateAutomatically
{
    [MobClick checkUpdate:NSLocalizedString(@"New Version Found", nil) cancelButtonTitle:NSLocalizedString(@"Skip", nil) otherButtonTitles:NSLocalizedString(@"Update now", nil)];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_viewController = [[UINavigationController alloc] initWithRootViewController: [[[MainViewController alloc] init] autorelease]];
    
	[_window addSubview:_viewController.view];
	[_window makeKeyAndVisible];
    

    //UMeng SDK invocation
    [MobClick startWithAppkey:APP_KEY_UMENG reportPolicy:REALTIME channelId:CHANNEL_ID];
    
    [self checkUpdateAutomatically];

}

- (void)dealloc {
	[_viewController release];
	[_window release];
	[super dealloc];
}




@end

// vim:ft=objc
