//
//  AboutViewController.m
//  AboutSex
//
//  Created by Shane Wen on 12-7-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "UMFeedback.h"
#import "SharedVariables.h"
#import "NSURL+WithChanelID.h"

#import "MobClick.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomCellBackgroundView.h"
#import "UMFeedbackViewController.h"
#import "SharedStates.h"
#import "PointsManager.h"
#import "UserInstructionController.h"

#define MAX_TIME_OF_UPDATE_CHECK    7
#define TIME_OF_CHECK_RESULTS_BEFORE_DISAPPEAR  1.7
#define AboutViewController_TAG_FOR_LEFT_VERSION_TITLE_LABEL 1110
#define AboutViewController_TAG_FOR_RIGHT_VERSION_NUMBER_LABEL 1111

#define HEIGHT_HEADER_VIEW   110
#define HEIGHT_FOOTER_VIEW   100

@interface AboutViewController ()
{
    BOOL mIsCheckingUpdate;
    NSTimer* mUpdateCheckOuttimeTimer;
    NSString* mPathForUpdate;
}

@property (nonatomic, assign) BOOL mIsCheckingUpdate;
@property (nonatomic, retain) NSTimer* mUpdateCheckOuttimeTimer;
@property (nonatomic, retain)     NSString* mPathForUpdate;

- (void)updateCheckCallBack:(NSDictionary *)appInfo;
- (void) showNewUpdateInfoOnMainThread:(id) aAppInfo;


@end

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = YES;
    self.tableView.tableFooterView = [self tableFooterView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[PointsManager shared] refreshPoints];
    
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

- (void) presentPointsInstructionController
{
    UserInstructionController* sUserInstructionController = [[UserInstructionController alloc] init];
    sUserInstructionController.title = NSLocalizedString(@"User Instructions", nil);
    [self.navigationController pushViewController:sUserInstructionController animated:YES];
    [sUserInstructionController release];
}

- (void)showFeedbackViewController
{
    UMFeedbackViewController *feedbackViewController = [[UMFeedbackViewController alloc] initWithNibName:@"UMFeedbackViewController" bundle:nil];
    feedbackViewController.appkey = APP_KEY_UMENG;
    [self.navigationController pushViewController:feedbackViewController animated:YES];
    [feedbackViewController release];
}

- (void) presentPointsGetterController
{
    [[PointsManager shared] showWallFromViewController:self];
}

- (UIView*) tableFooterView
{
    UILabel* sFooterView =[[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30)] autorelease];
    
    NSString* sAppName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString* sVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleVersion"];
    sFooterView.text = [NSString stringWithFormat:@"%@ %@", sAppName, sVersion];
    sFooterView.font = [UIFont systemFontOfSize:15];
    sFooterView.textColor = [UIColor grayColor];
    sFooterView.textAlignment = UITextAlignmentCenter;
    sFooterView.backgroundColor = [UIColor clearColor];
    
    
    return sFooterView;
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
            return 3;
        case 2:
            return 2;
        default:
            return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return NSLocalizedString(@"Points", nil);
        case 1:
            return NSLocalizedString(@"About", nil);
        default:
            return @"";
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sSection = [indexPath section];
    NSInteger sRow = [indexPath row];
    
    static NSString* sCellIdentifier = @"cell";
    UITableViewCell* sCell = [tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
    if (!sCell)
    {
        sCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sCellIdentifier] autorelease];        
    }
    
    if (0 == sSection)
    {
        if (0 == sRow)
        {
            sCell.textLabel.text = NSLocalizedString(@"My Points", nil);
            sCell.detailTextLabel.text = [NSString stringWithFormat:@"%d  ", [[PointsManager shared] getPoints]];
            sCell.selectionStyle = UITableViewCellSelectionStyleNone;
            sCell.accessoryType = UITableViewRowAnimationNone;
        }
        else if (1 == sRow)
        {
            sCell.textLabel.text = NSLocalizedString(@"Acuire Points", nil);
            sCell.detailTextLabel.text = nil;
            sCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            sCell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        else
        {
            //
        }

    }
    else if (1 == sSection)
    {
        if (0 == sRow)
        {
            sCell.textLabel.text = NSLocalizedString(@"User Instructions", nil);
            sCell.detailTextLabel.text = nil;
            sCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            sCell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        else if (1 == sRow)
        {
            sCell.textLabel.text = NSLocalizedString(@"Check for update", nil);
            sCell.detailTextLabel.text = nil;
            sCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            sCell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        else if (2 == sRow)
        {
            sCell.textLabel.text = NSLocalizedString(@"User Feedback", nil);
            sCell.detailTextLabel.text = nil;
            sCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            sCell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        else
        {
            //
        }
    }
    else
    {
        //nothing to do.
    }

    return sCell;
}

#pragma mark -
#pragma mark methods for delegate interface
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger sSection = [indexPath section];
    NSInteger sRow = [indexPath row];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (sSection == 1)
    {
        if (sRow == 0)
        {
            [self presentPointsInstructionController];
        }
        else if (sRow == 1)
        {
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
        else if (sRow == 2)
        {
            [self showFeedbackViewController];
        }

        else 
        {
            //nothing done.
        }
    }
    else if (sSection == 0)
    {
        if (sRow == 0)
        {
            return;
        }
        else if (sRow == 1)
        {
            [self presentPointsGetterController];
            [MobClick event:@"UEID_GET_POINTS_ACTIVE"];
        }
    }
    else 
    {
        //nothing done.
    }
    
    return;
}

#pragma mark -
#pragma mark methods for delegate interface
- (void)updateCheckCallBack:(NSDictionary *)appInfo
{
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
            NSURL *sURL = [NSURL MyURLWithString:self.mPathForUpdate];
            [[UIApplication sharedApplication] openURL:sURL];
        }
    }
}

- (void)appUpdate:(NSDictionary *)appInfo {
    NSLog(@"自定义更新 %@",appInfo);
} 

@end
