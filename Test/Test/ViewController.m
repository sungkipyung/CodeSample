//
//  ViewController.m
//  Test
//
//  Created by 성기평 on 2016. 2. 11..
//  Copyright © 2016년 hothead. All rights reserved.
//

#import "ViewController.h"
#import "Test.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    Test *testView = [[[NSBundle bundleForClass:[Test class]] loadNibNamed:@"Test" owner:nil options:nil] firstObject];
//    testView.frame = self.containerView.bounds;
//    
//    [self.containerView addSubview:testView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
