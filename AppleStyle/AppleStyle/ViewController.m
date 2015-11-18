//
//  ViewController.m
//  AppleStyle
//
//  Created by 성기평 on 2015. 11. 18..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import "ViewController.h"
#import "TextTableViewCell.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) CGFloat previousScrollViewYOffset;
@property (nonatomic, strong) NSArray *items;
@end
#define top_view_max_height 150
@implementation ViewController
- (void)loadView {
    [super loadView];
    self.followButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.followButton.layer.cornerRadius = 5;
    self.followButton.layer.borderWidth = 0.5;
    self.followButton.titleEdgeInsets = UIEdgeInsetsZero;
    
    self.tableView.delegate = self;
//    self.tableView.decelerationRate = 0.2;
//    [self.tableView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)]];
    NSMutableArray *newItems = [NSMutableArray array];
    for (int i = 0; i < 30; i++) {
        [newItems addObject:[NSNumber numberWithInt:i].stringValue];
    }
    self.items = newItems;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (scrollView.dragging == NO) {
//        return ;
//    }
    UITableView *tableView = scrollView;
    NSIndexPath *firstIndexPath = [tableView indexPathForCell:tableView.visibleCells.firstObject];
    NSIndexPath *lastIndexPath = [tableView indexPathForCell:tableView.visibleCells.lastObject];
    
    if (scrollView.contentOffset.y < 0) {
        return ;
    }
    
    if (firstIndexPath.row == 0) {
        
        [UIView animateWithDuration:0.3 animations:^{
            self.topViewHeight.constant = top_view_max_height;
            [self.view layoutIfNeeded];
        }];
        return ;
    }
    
    if (lastIndexPath.row == self.items.count - 1) {
        return ;
    }
    
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGFloat scrollDiff = scrollOffset - self.previousScrollViewYOffset;
    
    [UIView animateWithDuration:0.3 animations:^{
        if (scrollDiff > 0) {
            self.topViewHeight.constant = MAX(self.topViewHeight.constant - scrollDiff, 0);
        } else {
            self.topViewHeight.constant = MIN(self.topViewHeight.constant - scrollDiff, top_view_max_height);
        }
        [self.view layoutIfNeeded];
    }];
//
    self.previousScrollViewYOffset = scrollOffset;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell"];
    
    [cell.label setText:self.items[indexPath.row]];
    return cell;
}

@end
