//
//  UIButtonLarge.m
//  AboutSex
//
//  Created by Shane Wen on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIButtonLarge.h"

@implementation UIButtonLarge

@synthesize mMarginInsets;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.mMarginInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect largerFrame = CGRectMake(0 - self.mMarginInsets.left, 0 - self.mMarginInsets.top, self.frame.size.width + self.mMarginInsets.left+self.mMarginInsets.right, self.frame.size.height + self.mMarginInsets.top+self.mMarginInsets.bottom);
    return (CGRectContainsPoint(largerFrame, point) == 1) ? self : nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
