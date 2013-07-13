//
//  ADWrapperWall.m
//  AboutSex
//
//  Created by Wen Shane on 13-5-7.
//
//

#import "AdWallManager.h"
#import "YoumiWallAdapter.h"
//#import "DianruWallAdapter.h"
#import "MobClick.h"


@implementation AdWallManager


+ (WallAdpater*) adWall
{
    static WallAdpater* S_AdWall = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{        
        S_AdWall = [self adWallByType:[self getADWallType]];
        [S_AdWall retain];
    });
    
    return S_AdWall;
}

+ (NSMutableArray*) allWalls
{
    NSMutableArray* sWalls = [NSMutableArray array];
    
    WallAdpater* sYoumiWall = [self adWallByType:E_WALL_AD_TYPE_Youmi];
//    WallAdpater* sDianruWall = [self adWallByType:E_WALL_AD_TYPE_Dianru];
    
    [sWalls addObject:sYoumiWall];
//    [sWalls addObject:sDianruWall];
    
    return sWalls;
}

+ (WallAdpater*) adWallByType:(E_WALL_AD_TYPE)aType
{
    WallAdpater* sAdWall = nil;
    switch (aType)
    {
        case E_WALL_AD_TYPE_Youmi:
            sAdWall = [[[YoumiWallAdapter alloc] init] autorelease];
            break;
        default:
            sAdWall = [[[YoumiWallAdapter alloc] init] autorelease];
            break;
    }
    return sAdWall;
}

+ (E_WALL_AD_TYPE) getADWallType
{
    
    NSString* sAdName = [MobClick getConfigParams:@"UPID_AD_WALL_TYPE"];
        
    E_WALL_AD_TYPE sADType = E_WALL_AD_TYPE_Youmi;
    if (sAdName.length > 0)
    {
        if ([sAdName caseInsensitiveCompare:@"Youmi"] == NSOrderedSame)
        {
            sADType = E_WALL_AD_TYPE_Youmi;
        }
        else if ([sAdName caseInsensitiveCompare:@"Miidi"] == NSOrderedSame)
        {
//            sADType = E_WALL_AD_TYPE_Miidi;
        }
        else if ([sAdName caseInsensitiveCompare:@"Dianru"] == NSOrderedSame)
        {
//            sADType = E_WALL_AD_TYPE_Dianru;
        }
        else
        {
            sADType = E_WALL_AD_TYPE_Youmi;
        }

    }
    
    return sADType;

}


@end
