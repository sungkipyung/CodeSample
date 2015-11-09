//
//  ViewController.m
//  TabbedPageViewSample
//
//  Created by 성기평 on 2015. 11. 9..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) UIPageViewController *pageViewControl;
@property (strong, nonatomic) NSArray *viewControllers;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.pageViewControl = self.childViewControllers.firstObject;
    self.pageViewControl.dataSource = self;
    self.pageViewControl.delegate = self;
    
    UIViewController *firstVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstViewController"];
    UIViewController *secondVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondCollectionViewController"];
//    UIViewController *thirdVC;
    
    NSArray *viewControllers = @[firstVC, secondVC];
    self.viewControllers = viewControllers;
    [self.pageViewControl setViewControllers:@[firstVC]
                                   direction:UIPageViewControllerNavigationDirectionForward
                                    animated:NO
                                  completion:nil];
    
    [self.pageViewControl didMoveToParentViewController:self];
    self.view.gestureRecognizers = self.pageViewControl.gestureRecognizers;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchSegmentedControl:(UISegmentedControl *)sender {
}

- (NSInteger)p_indexOfVC:(UIViewController *)vc
{
    __block NSInteger index = NSNotFound;
    [self.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isEqual:vc]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

#pragma mark - <UIPageViewControllerDataSource>
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self p_indexOfVC:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    
    if (index == 0) {
        return self.viewControllers[1];
    }
    
    return self.viewControllers[0];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self p_indexOfVC:viewController];
    if (index == NSNotFound) {
        return nil;
    }
    if (index == 1) {
        return self.viewControllers[0];
    }
    
    return self.viewControllers[1];
}
@end
