//
//  ViewController.h
//  AudioEnginePractice
//
//  Created by 성기평 on 2016. 1. 7..
//  Copyright (c) 2016년 hothead. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZAudio/EZAudio.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet EZAudioPlot *audioPlot;

@end

