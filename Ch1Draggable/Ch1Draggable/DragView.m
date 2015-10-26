//
//  DragView.m
//  Ch1Draggable
//
//  Created by 성기평 on 2015. 8. 17..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import "DragView.h"

@implementation DragView
{
    CGPoint startLocation;
}

- (instancetype)initWithImage:(UIImage *)anImage {
    self = [super initWithImage:anImage]; if (self)
    {
        self.userInteractionEnabled = YES; }
    return self;
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
    // Calculate and store offset, pop view into front if needed
    startLocation = [[touches anyObject] locationInView:self]; [self.superview bringSubviewToFront:self];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    // Calculate offset
    CGPoint pt = [[touches anyObject] locationInView:self]; float dx = pt.x - startLocation.x;
    float dy = pt.y - startLocation.y;
    CGPoint newcenter = CGPointMake(self.center.x + dx, self.center.y + dy);
    // Set new location
    self.center = newcenter;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
