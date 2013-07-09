//
//  YoumiAdWall.m
//  AboutSex
//
//  Created by Wen Shane on 13-5-7.
//
//

#import "YoumiWallAdapter.h"
#import "YouMiWall.h"

@interface YoumiWallAdapter()
{
    YouMiWall* wall;
}

@property (nonatomic, retain) YouMiWall *wall;

@end

@implementation YoumiWallAdapter
@synthesize wall;

- (id) init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestPointSuccess:) name:YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION object:nil];

        self.wall = [[YouMiWall new] autorelease];
        [self.wall requestOffers:YES];
    }
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.wall = nil;
    
    [super dealloc];
}


- (BOOL) showWall
{
    [self.wall showOffers: YouMiWallAnimationTransitionPushFromBottom];
    
    return YES;
}

- (void) getEarnedPoints
{
    [self.wall requestEarnedPointsWithTimeInterval:45 repeatCount:3];
    return;
}



#pragma mark - YouMiWallDelegate
- (void)didReceiveOffers:(YouMiWall *)adWall
{
    NSLog(@"--Youmi---did receive offers");
    if ([self.mDelegate respondsToSelector:@selector(didOpenWall:)])
    {
        [self.mDelegate didOpenWall:YES];
    }

}

- (void)didFailToReceiveOffers:(YouMiWall *)adWall error:(NSError *)error
{
    NSLog(@"--Youmi---did fail to receive offers");
    if ([self.mDelegate respondsToSelector:@selector(didOpenWall:)])
    {
        [self.mDelegate didOpenWall:NO];
    }

}

- (void)requestPointSuccess:(NSNotification *)note
{
    NSLog(@"--!!!!--Youmi---did receive earned points");

    NSDictionary *info = [note userInfo];
    NSInteger sPoints = 0;
    NSArray *records = [info valueForKey:YOUMI_WALL_NOTIFICATION_USER_INFO_EARNED_POINTS_KEY];
    for (NSDictionary *oneRecord in records)
    {
        NSInteger earnedPoint = [(NSNumber *)[oneRecord objectForKey:kOneAccountRecordPoinstsOpenKey] integerValue];
        sPoints += earnedPoint;
        
        // 可以在此获得其它信息，比如 用户标识符: kOneAccountRecordUserIDOpenKey
    }
    NSLog(@"--!!!!--Youmi---did receive earned %d points", sPoints);

    if (sPoints > 0)
    {
        [self.mDelegate returnedEarendPoints:sPoints];
    }
}

//- (void)didReceiveEarnedPoints:(YouMiWall *)adWall info:(NSArray *)info
//{
//    NSLog(@"--!!!!--Youmi---did receive earned points");
//
//    if ([self.mDelegate respondsToSelector:@selector(returnedEarendPoints:)])
//    {
//        NSInteger sPoints = 0;
//        for (NSDictionary* sDict in info)
//        {
//            NSInteger sEarnedPoint = ((NSNumber*)[sDict objectForKey:kOneAccountRecordPoinstsOpenKey]).integerValue;
//            sPoints += sEarnedPoint;
//        }
//        
//        NSLog(@"--!!!!--Youmi---did receive earned %d points", sPoints);
//        if (sPoints > 0)
//        {
//
//            [self.mDelegate returnedEarendPoints:sPoints];
//        }
//    }
//}
//
//- (void)didFailToReceiveEarnedPoints:(YouMiWall *)adWall error:(NSError *)error
//{
//    NSLog(@"--Youmi---did fail to receive earned points");
//}


@end
