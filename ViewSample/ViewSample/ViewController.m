//
//  ViewController.m
//  ViewSample
//
//  Created by 성기평 on 2015. 9. 14..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)loadView
{
    [super loadView];
    [self.textView setTextContainerInset:UIEdgeInsetsZero];
    [self.textView setContentInset:UIEdgeInsetsZero];
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
