//
//  ViewController.m
//  CoreAnimationEXample
//
//  Created by 성기평 on 2015. 12. 23..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *anchorXText;
@property (weak, nonatomic) IBOutlet UITextField *anchorYText;
@property (weak, nonatomic) IBOutlet UITextField *anchorZText;

@property (weak, nonatomic) IBOutlet UITextField *xDegree;
@property (weak, nonatomic) IBOutlet UITextField *yDegree;
@property (weak, nonatomic) IBOutlet UITextField *zDegree;
@property (weak, nonatomic) IBOutlet UIView *targetView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self p_loadInfo];
}

- (void)p_loadInfo
{
    self.anchorXText.text = @(self.targetView.layer.anchorPoint.x).stringValue;
    self.anchorYText.text = @(self.targetView.layer.anchorPoint.y).stringValue;
    self.anchorZText.text = @(self.targetView.layer.anchorPointZ).stringValue;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchApplyButton:(id)sender {
    self.targetView.layer.anchorPoint = CGPointMake([self.anchorXText.text floatValue], [self.anchorYText.text floatValue]);
    self.targetView.layer.anchorPointZ = [self.anchorZText.text floatValue];
    /*
    struct CATransform3D
    {
        CGFloat m11, m12, m13, m14;
        CGFloat m21, m22, m23, m24;
        CGFloat m31, m32, m33, m34;
        CGFloat m41, m42, m43, m44;
    };
     */
//    self.targetView.layer.transform;
//    self.targetView.layer.sublayerTransform;
}
@end