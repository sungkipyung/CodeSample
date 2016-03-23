//
//  main.m
//  InspectingCoreAudio'sFileFormatSupport
//
//  Created by 성기평 on 2016. 2. 1..
//  Copyright © 2016년 hothead. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        AudioFileTypeAndFormatID fileTypeAndFormat;     // 1
//        fileTypeAndFormat.mFileType = kAudioFileAIFFType;
        fileTypeAndFormat.mFileType = kAudioFileWAVEType;
        
        fileTypeAndFormat.mFormatID = kAudioFormatLinearPCM;
        
        OSStatus audioErr = noErr;
        
        UInt32 infoSize = 0;                            // 2
        
        // 3
        audioErr = AudioFileGetGlobalInfoSize(kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat, sizeof (fileTypeAndFormat), &fileTypeAndFormat, &infoSize);
        
        assert (audioErr == noErr);
        
        //4
        AudioStreamBasicDescription *asbds = malloc (infoSize);
        //5
        audioErr = AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AvailableStreamDescriptionsForFormat, sizeof (fileTypeAndFormat), &fileTypeAndFormat, &infoSize, asbds);
        
        assert (audioErr == noErr);
        
        int asbdCount = infoSize / sizeof(AudioStreamBasicDescription);
        // 6
        for (int i = 0; i < asbdCount; i++) {
            UInt32 format4cc = CFSwapInt32HostToBig(asbds[i].mFormatID); // 7
            
            NSLog(@"%d: mformatId : %4.4s, mFormatFlags : %d, mBitsPerChannel : %d", i, (char*)&format4cc, asbds[i].mFormatFlags, asbds[i].mBitsPerChannel); // 8
        }
        
        free(asbds); // 9
        
    }
    return 0;
}
