//
//  ViewController.m
//  RunLoop
//
//  Created by ArcherLj on 2019/7/9.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import "ViewController.h"
#import "SecondThread.h"
#import "RunLoopSource.h"

@interface ViewController ()
@property (nonatomic) SecondThread *secondThread;
@property (nonatomic) RunLoopSource *runloopSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.secondThread = [[SecondThread alloc] init];
    self.runloopSource = [[RunLoopSource alloc] init];
    [self.runloopSource addToRunLoop:self.secondThread.runloop];
    [self.runloopSource addCommand:sCommandZipPic withData:@(10)];
    [self.runloopSource addCommand:sCommandDownLoadPics withData:@(20)];
    [self.runloopSource fireCommandsOnRunLoop:[self.secondThread.runloop getCFRunLoop]];
    [self.secondThread start];
}


@end
