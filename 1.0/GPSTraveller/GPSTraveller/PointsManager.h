//
//  PointsManager.h
//  AboutSex
//
//  Created by Wen Shane on 13-5-4.
//
//

#import <Foundation/Foundation.h>
#import "AdWallManager.h"


@interface PointsManager : NSObject<AdWallDelegate>

+ (PointsManager*) shared;

- (BOOL) consume:(NSInteger)aPoints;

- (NSInteger) getPoints;

- (void) refreshPoints;

- (BOOL) showWallFromViewController:(UIViewController*)aPresentController;
@end
