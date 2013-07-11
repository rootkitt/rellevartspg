//
//  FavoriteViewController.m
//  GPSTraveller
//
//  Created by Wen Shane on 13-4-2.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

#import "POIsViewController.h"
#import "MainViewController.h"
#import "FavoritesManager.h"
#import "SharedVariables.h"
#import "PPRevealSideViewController.h"
#import "AFNetworking.h"
#import "NSURL+WithChanelID.h"
#import "POI.h"
#import <QuartzCore/QuartzCore.h>

#define TAG_GEO_INFO_LABEL 111
#define TAG_COORDINATE_LABEL 112

@interface POIsViewController ()
{
    NSMutableArray* mFavoriteItems;
    NSMutableArray* mHotItems;
    UITableView* mTableView;
    BOOL mIsLoadingHots;
}

@property (nonatomic, retain) NSMutableArray* mFavoriteItems;
@property (nonatomic, retain) NSMutableArray* mHotItems;
@property (nonatomic, retain) UITableView* mTableView;
@property (nonatomic, assign) BOOL mIsLoadingHots;
@end

@implementation POIsViewController
@synthesize mFavoriteItems;
@synthesize mHotItems;
@synthesize mTableView;
@synthesize mIsLoadingHots;

+ (UIViewController*) shared
{
    static UIViewController* S_POIsViewController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        S_POIsViewController = [[self alloc] init];
    });
    return S_POIsViewController;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"POIs", nil);
        self.mFavoriteItems = [NSMutableArray array];
        self.mHotItems = [NSMutableArray array];
        self.mIsLoadingHots = NO;
    }
    return self;
}

- (void) dealloc
{
    self.mTableView = nil;
    self.mFavoriteItems = nil;
    self.mHotItems = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect sFrame = self.view.bounds;
    sFrame.size.width -= SIDEBAR_OFFSET;
    UITableView* sTableView = [[UITableView alloc] initWithFrame:sFrame style:UITableViewStylePlain];
    sTableView.dataSource = self;
    sTableView.delegate = self;
    sTableView.rowHeight = 65;
    sTableView.bounces = NO;
    self.mTableView = sTableView;
    [self.view addSubview:sTableView];
    
    
//    UIButton* sButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [sButton setFrame: CGRectMake(0, 0, 24, 24)];
//    [sButton setImage: [UIImage imageNamed:@"right24.png"] forState:UIControlStateNormal];
//    sButton.showsTouchWhenHighlighted = NO;
//    [sButton addTarget:self action:@selector(presentMainView) forControlEvents:UIControlEventTouchDown];
//    UIBarButtonItem* sDoneButtonItem = [[UIBarButtonItem alloc]initWithCustomView:sButton];
//    self.navigationItem.rightBarButtonItem = sDoneButtonItem;
//    [sDoneButtonItem release];
    
    // Uncomment the following line to preserve selection between presentations.
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//     self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshFavorites];
    if (!self.mIsLoadingHots
        &&self.mHotItems.count <= 0)
    {
        [self loadHotItems];
    }

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [self setEditing:NO animated:YES];
}

- (void) loadHotItems
{
    self.mIsLoadingHots = YES;
    
    NSString* sURLStr = URL_GET_HOT_POIS;
    NSURL *url = [NSURL MyURLWithString: sURLStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:10];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self loadSucessfully:JSON];
    } failure:^( NSURLRequest *request , NSHTTPURLResponse *response , NSError *error , id JSON ){
        [self loadFailed:error];
    }];
    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
    [operation start];

}

- (void) refreshFavorites
{
    self.mFavoriteItems = [NSMutableArray arrayWithArray:[[FavoritesManager shared] getAllFavorites]];
    //
    [self.mTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadSucessfully:(id)aJSONObj
{
    if (![aJSONObj isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    for (NSDictionary* sItemDict in (NSArray*)[aJSONObj objectForKey:@"items"])
    {
        HotPOI* sHotPOI = [[HotPOI alloc] init];
        
        CLLocationCoordinate2D sCoordinate;
        sCoordinate.latitude = ((NSNumber*)[sItemDict objectForKey:@"latitude"]).doubleValue;
        sCoordinate.longitude = ((NSNumber*)[sItemDict objectForKey:@"longitude"]).doubleValue;

        sHotPOI.mLocation = [[[CLLocation alloc] initWithLatitude:sCoordinate.latitude longitude:sCoordinate.longitude] autorelease];
        sHotPOI.mGeoInfo = (NSString*) [sItemDict objectForKey:@"geoInfo"];
        
        sHotPOI.mVisits = ((NSNumber*)[sItemDict objectForKey:@"visits"]).integerValue;
        
        [self.mHotItems addObject:sHotPOI];
        [sHotPOI release];        
    }
    [self.mTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    self.mIsLoadingHots = NO;
}

- (void) loadFailed:(NSError*)aError
{
    self.mIsLoadingHots = NO;
    return;
}

- (UIView*) headerViewWithNotice:(NSString*)sNotice
{
    UILabel* sNoDataNoticeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
    sNoDataNoticeLabel.textAlignment = UITextAlignmentCenter;
    sNoDataNoticeLabel.textColor = [UIColor grayColor];
    sNoDataNoticeLabel.text = sNotice;
    sNoDataNoticeLabel.font = [UIFont systemFontOfSize:15];
    
    return sNoDataNoticeLabel;
}

#pragma mark - Table view data source
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return [NSString stringWithFormat:@"%@(%d)", NSLocalizedString(@"Favorites", nil), self.mFavoriteItems.count];
    }
    else if (1 == section)
    {
        return [NSString stringWithFormat:@"%@(%d)", NSLocalizedString(@"The Hot", nil), self.mHotItems.count];
    }
    else
    {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (0 == section)
    {
        return self.mFavoriteItems.count;
    }
    else if (1 == section)
    {
        return self.mHotItems.count;
    }
    else
    {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ( indexPath.section == 0)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel* sGeoInfoLabel = nil;
        UILabel* sDistanceLabel = nil;
        if (!cell)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
            
            
            CGFloat sX = 5;
            CGFloat sY = 2;
            CGFloat sWidth = tableView.bounds.size.width-sX;
            CGFloat sHeight = 40;
            sGeoInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(sX, sY, sWidth, sHeight)];
            sGeoInfoLabel.font = [UIFont systemFontOfSize:15];
            sGeoInfoLabel.backgroundColor = [UIColor clearColor];
            sGeoInfoLabel.numberOfLines = 0;
            sGeoInfoLabel.tag = TAG_GEO_INFO_LABEL;
            
            [cell.contentView addSubview:sGeoInfoLabel];
            [sGeoInfoLabel release];
            
//            sX = 170;
            sY += sHeight+2;
            sWidth = 14;
            sHeight = 14;
            
            UIImageView* sImageView = [[UIImageView alloc] initWithFrame:CGRectMake(sX, sY+2, 10, 10)];
            sImageView.image = [UIImage imageNamed:@"plane16"];
            [cell.contentView addSubview:sImageView];
            [sImageView release];
            
            sX += sWidth+5;
            sWidth = 150;
            sHeight = 14;
            sDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(sX, sY, sWidth, sHeight)];
            sDistanceLabel.font = [UIFont systemFontOfSize:12];
            sDistanceLabel.backgroundColor = [UIColor whiteColor];
            sDistanceLabel.textColor = [UIColor grayColor];
            sDistanceLabel.tag = TAG_COORDINATE_LABEL;
            [cell.contentView addSubview:sDistanceLabel];
            [sDistanceLabel release];
        }
        else
        {
            sGeoInfoLabel = (UILabel*)[cell.contentView viewWithTag:TAG_GEO_INFO_LABEL];
            sDistanceLabel = (UILabel*)[cell.contentView viewWithTag:TAG_COORDINATE_LABEL];
        }
        
        
        if (indexPath.section == 0)
        {
            FavoritePOI* sLocation = (FavoritePOI*)[self.mFavoriteItems objectAtIndex:indexPath.row];
            
            
            if (sLocation.mGeoInfo.length > 0 )
            {
                sGeoInfoLabel.text = sLocation.mGeoInfo;
            }
            else
            {
                sGeoInfoLabel.text = NSLocalizedString(@"No geo info yet", nil);
            }
            
            sDistanceLabel.text = [sLocation distanceDesp];

        }
        else if (indexPath.section == 1)
        {
            HotPOI* sLocation = (HotPOI*)[self.mHotItems objectAtIndex:indexPath.row];
            
            
            if (sLocation.mGeoInfo.length > 0 )
            {
                sGeoInfoLabel.text = sLocation.mGeoInfo;
            }
            else
            {
                sGeoInfoLabel.text = NSLocalizedString(@"No geo info yet", nil);
            }
            
//            NSString* sCooridinateStr = [NSString stringWithFormat:@"%@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), sLocation.mLocation.coordinate.longitude, NSLocalizedString(@"Latitude", nil), sLocation.mLocation.coordinate.latitude];
            sDistanceLabel.text = [sLocation distanceDesp];
        }
        
        
        return cell;

    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0)
    {
        return YES;
    }
    else if (indexPath.section == 1)
    {
        return NO;
    }
    else
    {
        return NO;       
    }
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
//        FavoritePOI* sLocation = [[self.mFavoriteItems objectAtIndex:indexPath.row] retain];
        FavoritePOI* sLocation = [[[self.mFavoriteItems objectAtIndex:indexPath.row] retain] autorelease];
        [self.mFavoriteItems removeObject:sLocation];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        [[FavoritesManager shared] removeFavorite:sLocation];
        

        [self refreshFavorites];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.mTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    POI* sPOI = nil;
    if (indexPath.section == 0)
    {
        sPOI = [[[self.mFavoriteItems objectAtIndex:indexPath.row] retain] autorelease];
    }
    else if (indexPath.section == 1)
    {
        sPOI = [self.mHotItems objectAtIndex:indexPath.row];
    }

    [self.revealSideViewController popViewControllerAnimated:YES];
  
    MKCoordinateSpan sSpan;
    sSpan.latitudeDelta=0.05;
    sSpan.longitudeDelta=0.05;
    
    [[MainViewController shared] goToLocation:sPOI.mLocation span:sSpan animated:YES];
}

@end
