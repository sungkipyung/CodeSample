//
//  ViewController.m
//  AudioEnginePractice
//
//  Created by 성기평 on 2016. 1. 7..
//  Copyright (c) 2016년 hothead. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (nonatomic, strong) AVAudioPlayerNode *player;
@property (nonatomic, weak) AVAudioInputNode *input;
@property (nonatomic, weak) AVAudioOutputNode *output;
@property (nonatomic, weak) AVAudioMixerNode *mainMixer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.audioPlot.backgroundColor = [UIColor colorWithRed:0.984 green:0.471 blue:0.525 alpha:1.0];
    
    // Waveform color
    self.audioPlot.color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    
    // Plot type
    self.audioPlot.plotType = EZPlotTypeBuffer;
    
    
    NSError *error;
    
    AVAudioPCMBuffer *buffer;
    
//    NSFileManager *manager = [NSFileManager defaultManager];
    AVAudioEngine *engine = [self.class sharedEngine];
    
    AVAudioInputNode *input = [engine inputNode];
    input.volume = 1.0;
    AVAudioOutputNode *output = [engine outputNode];
    
    AVAudioPlayerNode *player = [[AVAudioPlayerNode alloc] init];
    player.volume = 1.0;
    
    [engine attachNode:player];
    
    AVAudioFile *file = [[AVAudioFile alloc] initForReading:[self sampleFileURL] error:&error];
    
    AVAudioMixerNode *mainMixer = [engine mainMixerNode];
    
    // input data for visualization
    [input installTapOnBus:0 bufferSize:4096 format:[input inputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
//        NSLog(@"when : %@", when);
//        NSLog(@"stride : %u\n", buffer.stride);
    }];
    
//    [player installTapOnBus:0 bufferSize:4096 format:[player inputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
//        NSLog(@"when : %@", when);
//        NSLog(@"stride : %u\n", buffer.stride);
//    }];
    
    __weak typeof (self) weakSelf = self;
    [mainMixer installTapOnBus:0 bufferSize:4096 format:[mainMixer outputFormatForBus:0] block:^(AVAudioPCMBuffer * _Nonnull buffer, AVAudioTime * _Nonnull when) {
        NSLog(@"sampleTime : %lld", (int64_t)when.sampleTime);
        NSLog(@"sampleRate : %lf", when.sampleRate);
        
        when.audioTimeStamp.mSampleTime;
        when.audioTimeStamp.mHostTime;
        when.audioTimeStamp.mRateScalar;
        when.audioTimeStamp.mWordClockTime;
        when.audioTimeStamp.mSMPTETime;
        /**
         enum {
         kAudioTimeStampSampleTimeValid      = (1 << 0),
         kAudioTimeStampHostTimeValid        = (1 << 1),
         kAudioTimeStampRateScalarValid      = (1 << 2),
         kAudioTimeStampWordClockTimeValid   = (1 << 3),
         kAudioTimeStampSMPTETimeValid       = (1 << 4)
         };
         */
        when.audioTimeStamp.mFlags;
        when.audioTimeStamp.mReserved;
        
//        NSLog(@"sampleRate : %lf", );
        NSLog(@"Format : %@", buffer.format);
        NSLog(@"stride : %u\n", buffer.stride);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // All the audio plot needs is the buffer data (float*) and the size.
            // Internally the audio plot will handle all the drawing related code,
            // history management, and freeing its own resources.
            // Hence, one badass line of code gets you a pretty plot :)
            [weakSelf.audioPlot updateBuffer:buffer.floatChannelData[0] withBufferSize:buffer.frameCapacity];
        });
    }];
    
    [engine connect:input to:mainMixer format:[input inputFormatForBus:0]];
    [engine connect:player to:mainMixer format:file.processingFormat];
    [engine connect:mainMixer to:output format:[output outputFormatForBus:0]];
    
    [player scheduleFile:file atTime:nil completionHandler:nil];
    
    BOOL engineIsStarted = [engine startAndReturnError:&error];
    
    if (error) {
        NSLog(@"error : %@", error);
        return ;
    }
    
    if (!engineIsStarted) {
        NSLog(@"Fail to start engine");
        return ;
    }
    
    [player play];
    self.player = player;
    self.input = input;
    self.output = output;
    self.mainMixer = mainMixer;
}

- (NSURL *)sampleFileURL
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"mp3"];
    NSURL *fileURL = [NSURL URLWithString:path];
    
    return fileURL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark GLOBAL ENGINE

+ (AVAudioEngine*)sharedEngine
{
    static dispatch_once_t once;
    static AVAudioEngine* result = nil;
    dispatch_once(&once, ^{
        result = [[AVAudioEngine alloc] init];
    });
    return result;
}

@end
