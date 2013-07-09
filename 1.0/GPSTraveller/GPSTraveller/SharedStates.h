//
//  SharedStates.h
//  GPSTraveller
//
//  Created by Wen Shane on 13-7-5.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedStates : NSObject


+ (SharedStates*)getInstance;

- (NSString*) getUUID;
- (NSString*) getAcuringPointsInstruction;
- (void) showNotice:(NSString*)aNotice;
- (void) playSoundForStart;
@end
