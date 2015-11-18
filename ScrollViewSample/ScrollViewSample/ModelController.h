//
//  ModelController.h
//  ScrollViewSample
//
//  Created by 성기평 on 2015. 11. 11..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataViewController;

@interface ModelController : NSObject <UIPageViewControllerDataSource>

- (DataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(DataViewController *)viewController;

@end

