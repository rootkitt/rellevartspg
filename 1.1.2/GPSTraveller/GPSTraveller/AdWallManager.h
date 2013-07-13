//
//  ADWrapperWall.h
//  AboutSex
//
//  Created by Wen Shane on 13-5-7.
//
//

#import <Foundation/Foundation.h>
#import "WallAdpater.h"

typedef enum _E_WALL_AD_TYPE
{
    E_WALL_AD_TYPE_Youmi,
//    E_WALL_AD_TYPE_Miidi,
//    E_WALL_AD_TYPE_Dianru,
    
    
}E_WALL_AD_TYPE;


@interface AdWallManager : NSObject


+ (WallAdpater*) adWall;

+ (NSMutableArray*) allWalls;


@end
