//
//  ViewController.m
//  ViewSample
//
//  Created by 성기평 on 2015. 9. 14..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *targetView;

@end

@implementation ViewController
- (IBAction)toggleOpacity:(id)sender {
    CAKeyframeAnimation *widthAnim = [CAKeyframeAnimation animationWithKeyPath:@"borderWidth"];
    NSArray *widthValues = @[@1.0, @10.0, @5.0, @30.0, @0.5, @15.0, @2.0, @50.0, @0.0];
    widthAnim.values = widthValues;
    widthAnim.calculationMode = kCAAnimationPaced;
    
    CAKeyframeAnimation *colorAnim = [CAKeyframeAnimation animationWithKeyPath:@"borderColor"];
    NSArray *colorValues = @[(id)[UIColor greenColor].CGColor, (id)[UIColor redColor].CGColor, (id)[UIColor blueColor].CGColor];
    colorAnim.values = colorValues;
    colorAnim.calculationMode = kCAAnimationPaced;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[widthAnim, colorAnim];
    group.duration = 5.0;
    group.delegate = self;
    [self.targetView.layer addAnimation:group forKey:@"BorderChanges"];
}

- (void)loadView
{
    [super loadView];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        NSLog(@"Animation DidStop");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
