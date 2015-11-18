//
//  RootViewController.h
//  ScrollViewSample
//
//  Created by 성기평 on 2015. 11. 11..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UIPageViewControllerDelegate>

@property (strong, nonatomic) UIPageViewController *pageViewController;

@end

