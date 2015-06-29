//
//  SimpleObject.h
//  DelegateCrashTryCatchExample
//
//  Created by 성기평 on 2015. 6. 29..
//  Copyright (c) 2015년 hothead. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SimpleObjectDelegate <NSObject>
- (void)helloWorld;
@end

@interface SimpleObject : NSObject <SimpleObjectDelegate>

@end
