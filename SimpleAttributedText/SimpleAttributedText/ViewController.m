//
//  ViewController.m
//  SimpleAttributedText
//
//  Created by 성기평 on 2015. 9. 9..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchTagButton:(id)sender
{
//    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    NSString *text = @"<a href=\"app://scheme/path\">#HelloWorld</a>";
    [self setHtmlText:text withFontHelveticaSize:10 withTextView:self.textView];
}

- (void)setHtmlText:(NSString *)text withFontHelveticaSize:(CGFloat)size withTextView:(UITextView *)textView
{
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[text dataUsingEncoding:NSUnicodeStringEncoding]
                                                                            options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    textView.attributedText = attributedString;
    
    UIFontDescriptor *fontDescriptorHelvetica = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                 @{
                                                   @"NSFontFamilyAttribute" : @"HelveticaNeue",
                                                   @"NSFontFaceAttribute" : @"Regular"
                                                   }];
    textView.font = [UIFont fontWithDescriptor:fontDescriptorHelvetica size:size];
}

@end
