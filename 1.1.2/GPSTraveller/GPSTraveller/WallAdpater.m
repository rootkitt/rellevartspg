//
//  AdWall.m
//  AboutSex
//
//  Created by Wen Shane on 13-5-7.
//
//

#import "WallAdpater.h"

@interface WallAdpater()
{
    id<AdWallDelegate> mDelegate;
}

@end


@implementation WallAdpater
@synthesize mDelegate;

- (void) dealloc
{
    self.mDelegate = nil;
    
    [super dealloc];
}

- (BOOL) showWall
{
    return YES;
}

- (void) getEarnedPoints
{
    return;
}


@end
