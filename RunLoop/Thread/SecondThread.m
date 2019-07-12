//
//  SecondThread.m
//  RunLoop
//
//  Created by ArcherLj on 2019/7/9.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import "SecondThread.h"

@implementation SecondThread

-(NSRunLoop *)runloop {
    return [NSRunLoop currentRunLoop];;
}

-(void)start {

    while (true) {
        CFRunLoopRunResult result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
    }
}

@end


