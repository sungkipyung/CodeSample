//
//  SecondCollectionViewController.m
//  
//
//  Created by 성기평 on 2015. 11. 9..
//
//

#import "SecondCollectionViewController.h"
#import "PictureCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface SecondCollectionViewController ()
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UIImage *placeHolderImage;
@end

@implementation SecondCollectionViewController

static NSString * const reuseIdentifier = @"PictureCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    self.placeHolderImage = [UIImage imageNamed:@"c.jpg"];
    
    self.images = @[
                    @"http://tv02.search.naver.net/ugc?t=470x180&q=http://cafefiles.naver.net/20131209_39/hj200900_1386579588572zMnbn_JPEG/UUUUUUUUUUUUUUUUUUUU.jpg"
                    , @"http://tv01.search.naver.net/ugc?t=470x180&q=http://blogfiles.naver.net/20110516_135/30580_13055423767884ocTC_JPEG/%C8%A3%B9%DA%B2%C92.jpg"
                    , @"http://tv02.search.naver.net/ugc?t=470x180&q=http://thumb.photo.naver.net/data16/2006/6/24/199/6%BF%F924%C0%CF-_030_1.jpg"
                    , @"http://tv02.search.naver.net/ugc?t=470x180&q=http://dbscthumb.phinf.naver.net/0618_000_1/20110503115712877_LMHJTX1M4.jpg/200330549-001.jpg?type=m1500"
                    , @"http://tv02.search.naver.net/ugc?t=470x180&q=http://thumb.photo.naver.net/20150321_202/00mkjun_14268934091514azXX_JPEG/2015-03-21-08-14-12_deco.jpg"
                    , @"http://tv01.search.naver.net/ugc?t=470x180&q=http://thumb.photo.naver.net/20140821_173/ondane52_1408624778920FxRad_JPEG/%C7%CF%C1%B6%B4%EB_109.JPG"
                    , @"http://tv01.search.naver.net/ugc?t=470x180&q=http://thumb.photo.naver.net/20120824_33/rjsekftlsqn_1345817189255Raw6N_JPEG/%BB%E7%C1%F8_858.jpg"
                    , @"http://tv01.search.naver.net/ugc?t=470x180&q=http://thumb.photo.naver.net/exphoto01/2009/7/30/122/pict0850_barkdal.jpg", @"http://tv02.search.naver.net/ugc?t=470x180&q=http://thumb.photo.naver.net/exphoto01/2010/9/24/42/%BC%AE%BB%F3-030_chb9128.jpg"
               ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    NSURL *url = [NSURL URLWithString:self.images[indexPath.row]];
    
//    [cell.pictureImageView sd_setImageWithURL: placeholderImage:self.placeHolderImage];
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:url options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        cell.pictureImageView.alpha = 0.0;
        [UIView transitionWithView:cell.pictureImageView
                          duration:3.0
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [cell.pictureImageView setImage:image];
                            cell.pictureImageView.alpha = 1.0;
                        } completion:NULL];
    }];
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
