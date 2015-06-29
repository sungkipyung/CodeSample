//
//  ViewController.m
//  DelegateCrashTryCatchExample
//
//  Created by 성기평 on 2015. 6. 29..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import "ViewController.h"
#import "SimpleObject.h"


@interface ViewController ()

@property (nonatomic, strong) SimpleObject *obj;
@property (nonatomic, assign) id<SimpleObjectDelegate>delegate;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.obj = [[SimpleObject alloc] init];
    self.delegate = self.obj;
    NSLog(@"self.delegate address : %ud", self.delegate);
}


 //overcome crash
- (void)setObj:(SimpleObject *)obj
{
    _obj = obj;
    self.delegate = obj;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)actionDelegateCall:(id)sender {
    @try {
        NSLog(@"self.delegate address : %ud", self.delegate);
        [self.delegate helloWorld]; // what the hell !!!
        // delegate must live longer than me!
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {
        NSLog(@"Overcome Exception");
    }
    
}
- (IBAction)actionDeallocObj:(id)sender {
    NSLog(@"self.delegate address : %ud", self.obj);
    NSLog(@"self.delegate address : %ud", self.delegate);

    self.obj = nil;
    NSLog(@"self.delegate address : %ud", self.obj);
    NSLog(@"self.delegate address : %ud", self.delegate);
}

@end
