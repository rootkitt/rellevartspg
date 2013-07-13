//
//  NSString+MyString.h
//  AboutSex
//
//  Created by Shane Wen on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MyString)


- (unsigned int) indexOfChar: (char) aChar options:(NSStringCompareOptions)mask;
- (NSString *) stringReducedToWidth:(CGFloat)width withFont:(UIFont *)font;

- (BOOL)containsString:(NSString *)string;
- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options;


@end
