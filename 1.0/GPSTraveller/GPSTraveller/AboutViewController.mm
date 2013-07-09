//
//  AboutViewController.m
//  AboutSex
//
//  Created by Shane Wen on 12-7-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
//#import "UMFeedback.h"
#import "SharedVariables.h"

#import "MobClick.h"
#import "UMFeedback.h"
#import "SVProgressHUD.h"

#import "CustomCellBackgroundView.h"
//#import "CopyrightView.h"

#define MAX_TIME_OF_UPDATE_CHECK    7
#define TIME_OF_CHECK_RESULTS_BEFORE_DISAPPEAR  1.7
#define AboutViewController_TAG_FOR_LEFT_VERSION_TITLE_LABEL 1110
#define AboutViewController_TAG_FOR_RIGHT_VERSION_NUMBER_LABEL 1111


@implementation AboutViewController

@synthesize mIsCheckingUpdate;
@synthesize mUpdateCheckOuttimeTimer;
@synthesize mPathForUpdate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void) loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    
    UIView* sView = [[UIView alloc] initWithFrame:applicationFrame];
    sView.backgroundColor = [UIColor whiteColor];
    self.view = sView;
    [sView release];
    
    CGFloat sPosX = 0;
    CGFloat sPosY = 30;
    
    //0. icon
    UIImage* sImage = [UIImage imageNamed:@"Icon-72.png"];
    UIImageView* sImageView = [[UIImageView alloc]initWithImage:sImage];
    sImageView.center = CGPointMake(self.view.center.x, sImageView.center.y+sPosY);
    [self.view addSubview:sImageView];
    
    [sImageView release];
    
    sPosX =43;
    sPosY = sImageView.frame.origin.y+sImageView.frame.size.height+5;
    //1. intro
    UILabel* sIntroLabel = [[UILabel alloc] initWithFrame:CGRectMake(sPosX, sPosY, 270, 400)];
    sIntroLabel.numberOfLines = 0;
    NSString* sBundleDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    sIntroLabel.text = sBundleDisplayName;
    sIntroLabel.backgroundColor = [UIColor clearColor];
//    sIntroLabel.textAlignment = UITextAlignmentCenter;
    sIntroLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:17];
    [sIntroLabel sizeToFit];
    sIntroLabel.center = CGPointMake(self.view.center.x, sIntroLabel.center.y);
    [self.view addSubview:sIntroLabel];
    [sIntroLabel release];
    
    //2. contacts and review links
    sPosX = 0;
    sPosY = sIntroLabel.frame.origin.y+ sIntroLabel.frame.size.height+10;
    UITableView* sTableView = [[UITableView alloc]initWithFrame:CGRectMake(sPosX, sPosY, self.view.bounds.size.width, self.view.bounds.size.height-sPosY) style:UITableViewStyleGrouped];
    
//    //[setBackgroundView:nil] only works on ios 6, and setBackgroundColor:[UIColor clearColor] works on ios 5 only.
    [sTableView setBackgroundView:nil];
    [sTableView setBackgroundColor:[UIColor clearColor]];
    sTableView.bounces = NO;

    sTableView.dataSource = self;
    sTableView.delegate = self;
    
    [self.view addSubview:sTableView];
    
    [sTableView release];
    
//    CopyrightView* sCopyRightView = [CopyrightView getView];
//    
//
//    
//    sCopyRightView.frame = CGRectMake(0, self.view.bounds.size.height-self.navigationController.navigationBar.bounds.size.height-sCopyRightView.bounds.size.height, sCopyRightView.bounds.size.width, sCopyRightView.bounds.size.height);
//
//    [self.view addSubview:sCopyRightView];
//    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIButton* sButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sButton setFrame: CGRectMake(0, 0, 24, 24)];
    [sButton setImage: [UIImage imageNamed:@"left24.png"] forState:UIControlStateNormal];
    sButton.showsTouchWhenHighlighted = NO;
    [sButton addTarget:self action:@selector(popCurrentViewController) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem* sDoneButtonItem = [[UIBarButtonItem alloc]initWithCustomView:sButton];
    self.navigationItem.leftBarButtonItem = sDoneButtonItem;
    [sDoneButtonItem release];

    
}

- (void) popCurrentViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) dealloc
{
    [self.mUpdateCheckOuttimeTimer invalidate];
    self.mUpdateCheckOuttimeTimer = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark methods for datasource interface

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 2;
        case 1:
            return 1;
        default:
            return 0;
    }
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    switch (section)
//    {
//        case 0:
//            return @"产品改进讨论区";
//        case 1:
//            return nil;
//        default:
//            return nil;
//    }
//
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sSection = [indexPath section];
    NSInteger sRow = [indexPath row];

    UITableViewCell* sCell = [tableView dequeueReusableCellWithIdentifier:@"common"];
    if (!sCell)
    {
        sCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"common"] autorelease];
  
        sCell.selectionStyle = UITableViewCellSelectionStyleGray;
//        CustomCellBackgroundView* sBGView = [CustomCellBackgroundView backgroundCellViewWithFrame:sCell.frame Row:[indexPath row] totalRow:[tableView numberOfRowsInSection:[indexPath section]] borderColor:SELECTED_CELL_COLOR fillColor:SELECTED_CELL_COLOR tableViewStyle:tableView.style];
//        sCell.selectedBackgroundView = sBGView;
    }
    
    if (0 == sSection )
    {
        if (0 == sRow)
        {
            sCell.textLabel.text = NSLocalizedString(@"Version", nil);
            sCell.detailTextLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
            sCell.accessoryType = UITableViewCellAccessoryNone;
            sCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            sCell.textLabel.text = NSLocalizedString(@"Check for update", nil);
            sCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (1 == sSection)
    {
        sCell.textLabel.text =  NSLocalizedString(@"Feedback", nil);
        sCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        //nothing done here.
    }
    
    return sCell;
}

#pragma mark -
#pragma mark methods for delegate interface

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 20;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (0  == section)
//    {
//        UILabel* sHeaderLabel = [[[UILabel alloc]init] autorelease];
//        sHeaderLabel.frame = CGRectMake(0, 0, 100, 200);
//        sHeaderLabel.text = @"产品改进讨论区..";
//        sHeaderLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Medium" size:15];
//        [sHeaderLabel sizeToFit];
//        return sHeaderLabel;
//    }
//    return nil;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sSection = [indexPath section];
    NSInteger sRow = [indexPath row];
    
    if (sSection == 0)
    {
        if (sRow == 0)
        {
            return;
            
        }
        else if (sRow == 1)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            if (!self.mIsCheckingUpdate)
            {
                self.mIsCheckingUpdate = YES;
                [SVProgressHUD showWithStatus:NSLocalizedString(@"Checking", nil) maskType:SVProgressHUDMaskTypeClear];
                [SVProgressHUD setBackgroudColorForHudView:[UIColor blackColor]];
    
                [MobClick checkUpdateWithDelegate:self selector:@selector(updateCheckCallBack:)];

                
                //set outtime timer
                if(self.mUpdateCheckOuttimeTimer
                   && [self.mUpdateCheckOuttimeTimer isValid])
                {
                    [self.mUpdateCheckOuttimeTimer invalidate];
                }
                
                NSTimer* sTimer = [[NSTimer alloc]initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:MAX_TIME_OF_UPDATE_CHECK]  interval:1 target:self selector:@selector(updateCheckOuttimerHandler) userInfo:nil repeats:NO];
                self.mUpdateCheckOuttimeTimer  = sTimer;
                [sTimer release];
                [[NSRunLoop currentRunLoop] addTimer:self.mUpdateCheckOuttimeTimer forMode:NSDefaultRunLoopMode];
                
            }
        }
        else
        {
            //nothing done.
        }
    }
    else if (sSection == 1)
    {
        if (sRow == 0)
        {
            [tableView deselectRowAtIndexPath: indexPath animated:NO];

            UIViewController* sViewController = [[UIViewController alloc]init];
            [UMFeedback showFeedback:self withAppkey:APP_KEY_UMENG];
            [sViewController release];
        }
    }
    else
    {
        //nothing done.
    }

    return;
}

- (void)updateCheckCallBack:(NSDictionary *)appInfo
{
    //    NSEnumerator* sEnum = [appInfo keyEnumerator];
    //
    //    id sKey;
    //    while (sKey = [sEnum nextObject]) {
    //        NSLog(@"%@-%@:\t %@", [sKey class], sKey, [appInfo objectForKey:sKey]);
    //    }
    
    if (self.mIsCheckingUpdate)
    {
        if (self.mUpdateCheckOuttimeTimer
            && [self.mUpdateCheckOuttimeTimer isValid])
        {
            [self.mUpdateCheckOuttimeTimer invalidate];
        }
        
        BOOL sNeedUpdate = ((NSNumber*)[appInfo objectForKey:@"update"]).boolValue;
        CGFloat sCurVersion = [(NSString*)[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"] doubleValue];
        CGFloat sNewVersion = [((NSString*)[appInfo objectForKey:@"version"]) doubleValue];
        if (sNeedUpdate
            && sNewVersion>sCurVersion)
        {
            //note that the display of alertview must take place on main thread, otherwise it loads very slowly.
            [self performSelectorOnMainThread:@selector(showNewUpdateInfoOnMainThread:) withObject:appInfo waitUntilDone:NO];
            [SVProgressHUD dismiss];

        }
        else
        {
            [SVProgressHUD dismissWithSuccess:NSLocalizedString(@"No updates found", nil) afterDelay: TIME_OF_CHECK_RESULTS_BEFORE_DISAPPEAR];
        }
        self.mIsCheckingUpdate = NO;
    }
    
    return;
}

- (void) showNewUpdateInfoOnMainThread:(id) aAppInfo
{
    
    NSDictionary* sAppInfo = (NSDictionary*)aAppInfo;
    
    
    NSString* sVersionStr = (NSString*)[sAppInfo objectForKey:@"version"];
    NSString* sUpdateLogStr = (NSString*)[sAppInfo objectForKey:@"update_log"];
    self.mPathForUpdate = (NSString*) [sAppInfo objectForKey:@"path"];
    
    
    NSString* sAlertViewTitle = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"New Version Found", nil), sVersionStr];
    UIAlertView* sAlertView = [[UIAlertView alloc] initWithTitle:sAlertViewTitle message:sUpdateLogStr  delegate:self cancelButtonTitle:NSLocalizedString(@"Ignore", nil) otherButtonTitles:NSLocalizedString(@"Update now", nil), nil];
    [sAlertView show];
    [sAlertView release];
    
}

- (void) updateCheckOuttimerHandler
{
    if (self.mIsCheckingUpdate)
    {
        self.mIsCheckingUpdate = NO;
        [SVProgressHUD dismissWithError:NSLocalizedString(@"Update checking error", nil) afterDelay: TIME_OF_CHECK_RESULTS_BEFORE_DISAPPEAR];
    }
}

#pragma mark -
#pragma mark delegate for update checking's alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == buttonIndex)
    {
        if (self.mPathForUpdate)
        {
            NSURL *sURL = [NSURL URLWithString:self.mPathForUpdate];
            [[UIApplication sharedApplication] openURL:sURL];
        }
    }
}

- (void)appUpdate:(NSDictionary *)appInfo {
    NSLog(@"自定义更新 %@",appInfo);
} 

@end
