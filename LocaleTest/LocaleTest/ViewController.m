//
//  ViewController.m
//  LocaleTest
//
//  Created by 성기평 on 2016. 3. 17..
//  Copyright © 2016년 hothead. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lael;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.lael.text = [[NSLocale preferredLanguages] firstObject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
