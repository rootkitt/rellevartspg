//
//  AdWall.h
//  AboutSex
//
//  Created by Wen Shane on 13-5-7.
//
//

#import <Foundation/Foundation.h>


@protocol AdWallDelegate <NSObject>

@required
- (UIViewController*) presentingViewController;

@optional
-(void)didOpenWall:(BOOL)aSuccess;
-(void)returnedEarendPoints:(NSInteger)aPoints;

@end



@interface WallAdpater : NSObject

@property (nonatomic, assign) id<AdWallDelegate> mDelegate;
- (BOOL) showWall;
- (void) getEarnedPoints;

@end
