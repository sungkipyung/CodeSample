//
//  Test.m
//  Test
//
//  Created by 성기평 on 2016. 2. 11..
//  Copyright © 2016년 hothead. All rights reserved.
//

#import "Test.h"

@interface Test()
@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;
@end

@implementation Test

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self load];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self load];
    }
    return self;
}

- (void)load
{
    UIView *view = [[[NSBundle bundleForClass:[self class]] loadNibNamed:@"Test" owner:self options:nil] firstObject];
    view.frame = self.bounds;
    [self addSubview:view];
    
    self.leftLabel.text = @"works";
    self.rightLabel.text =  @":)";
}

- (void)setCornerRadius:(NSInteger)cornerRadius
{
    [self.layer setCornerRadius:cornerRadius];
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = YES;
    _cornerRadius = cornerRadius;
}

@end
