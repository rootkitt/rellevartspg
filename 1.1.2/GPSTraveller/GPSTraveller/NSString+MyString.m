//
//  NSString+MyString.m
//  AboutSex
//
//  Created by Shane Wen on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+MyString.h"

@implementation NSString (MyString)


- (unsigned int) indexOfChar: (char) aChar options:(NSStringCompareOptions)mask
{
    // you could experiment with this, I suspect linear searching each 
    // character would be about as fast as it can get.
    NSString *substring = [NSString stringWithFormat: @"%c", aChar];
    NSRange range = [self rangeOfString: substring options:mask];
    return range.location;
}

- (NSString *) stringReducedToWidth:(CGFloat)width withFont:(UIFont *)font
{
    
    if ([self sizeWithFont:font].width <= width)
        return self;
    
    NSMutableString *string = [NSMutableString string];
    
    for (NSInteger i = 0; i < [self length]; i++) {
        
        [string appendString:[self substringWithRange:NSMakeRange(i, 1)]];
        
        if ([string sizeWithFont:font].width > width) {
            
            if ([string length] == 1)
                return nil;
            
            [string deleteCharactersInRange:NSMakeRange(i, 1)];
            
            break;
        }
    }
    
    return string;
}

- (BOOL)containsString:(NSString *)string
               options:(NSStringCompareOptions)options
{
    NSRange rng = [self rangeOfString:string options:options];
    return rng.location != NSNotFound;
}

- (BOOL)containsString:(NSString *)string
{
    return [self containsString:string options:0];
}

@end
