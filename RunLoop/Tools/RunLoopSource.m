//
//  RunLoopSource.m
//  RunLoop
//
//  Created by ArcherLj on 2019/7/9.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import "RunLoopSource.h"
#import "AppDelegate.h"

/**
 要使输入源有用，需要对他进行操作，从另一个线程发出信号，输入源的重点是将关联的线程休眠，直到有事情做为止。这需要让应用程序中的其他线程知道输入源并有办法与之通信。
 
 通知消费者输入源的方式之一就是在输入源首次安装到其runloop时发出的注册回调；你可以使用任意数量的消费者（客户端）来注册输入源，或者只需要将其注册到某个中央代理商，然后将输入源发送给感兴趣的其他消费者。这里我们只模拟了AppDelegate一个客户端。
 */

@implementation RunLoopSource
// init 中创建RunloopSource以及command buffer： commands
-(id)init {
    CFRunLoopSourceContext context = {
        0,
        (__bridge void *)(self),
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        &RunLoopSourceScheduleRoutine,
        &RunLoopSourceCancelRoutine,
        &RunLoopSourcePerformRoutine
    };
    
    runloopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    commands = [[NSMutableArray alloc] init];
    
    return self;
}

-(void)invalidate {
    CFRunLoopSourceInvalidate(runloopSource);
    [commands removeAllObjects];
}

// 将runloopsource添加到当前runloop
-(void)addToRunLoop:(NSRunLoop *)runloop {
    
    CFRunLoopRef cfRl = [runloop getCFRunLoop];
    CFRunLoopAddSource(cfRl, runloopSource, kCFRunLoopDefaultMode);
}

-(void)addCommand:(NSInteger)command withData:(id)data {
    NSArray *commandItem = @[@(command), data];
    [commands addObject:commandItem];
}

/**
 当消费者把数据放到command buffer之后，一定要给runloopsource发送信号，并显示的唤醒runloop。
 给runloop source发送信号告诉runloop source已经准备好了。一定要记得显示唤醒runloop，否则，如果runloop在休眠的话，就会导致执行延时.
 
 注意：永远不要使用SIGHUP等进程级别的信号去通知自定义source，唤醒runloop的core foundation方法并不是信号安全的，一定不要在你的应用中使用。
 */
-(void)fireCommandsOnRunLoop:(CFRunLoopRef)runloop {
    CFRunLoopSourceSignal(runloopSource);
    CFRunLoopIsWaiting(runloop);
}

-(void)sourceFired {
    NSLog(@"Thread now: %@", [[NSThread currentThread] name]);
    for (NSArray *commandItem in commands) {
        NSInteger command =  [commandItem[0] integerValue];
        id data = commandItem[1];
        if (command == sCommandDownLoadPics) {
            [self downloadPicsWithData:data];
        } else if (command == sCommandZipPic) {
            [self zipPicWithData:data];
        }
    }
}

-(void)downloadPicsWithData:(id)data {
    NSLog(@"download pics with data: %@", data);
}

-(void)zipPicWithData:(id)data {
    NSLog(@"zip pic with data: %@", data);
}
@end

/////////////////////////////////////////////////////////////////////////
//              回调
/////////////////////////////////////////////////////////////////////////
// 1. 当runloop sources 被添加到runloop时回调
// 因为这里input source只有一个客户端(主线程)，所以它在添加到runloop的回调中，将自己注册到主线程的application delegate中
// 后面application delagea想和input source通信的时候，就使用RunLoopContext中的对象就可以了
void RunLoopSourceScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode) {
    RunLoopSource *obj = (__bridge RunLoopSource *)info; // info是创建source的时候传入的
    AppDelegate *del = [AppDelegate sharedDelegate];
    RunLoopContext *theContext = [[RunLoopContext alloc] initWithSource:obj andLoop:rl];
    
    [del performSelectorOnMainThread:@selector(registerSource:) withObject:theContext waitUntilDone:NO];
}

// 2. input source接受到信号后的回调
void RunLoopSourcePerformRoutine(void *info) {
    RunLoopSource *source = (__bridge RunLoopSource *)info;
    [source sourceFired]; // 接受到信号，马上触发source被触发的处理函数
}

// 3.使用CFRunLoopSourceInvalidate将input source从runloop移除后的回调
// 在这个回调里告诉你的client，input source失效了，让他们移除对应的引用
// 这里我们在这个回调里给appDelegate注册一个通知方法，让他在input source失效的时候调用对应的方法
void RunLoopSourceCancelRoutine(void *info, CFRunLoopRef rl, CFStringRef mode) {
    RunLoopSource *source = (__bridge RunLoopSource *)info;
    AppDelegate *del = [AppDelegate sharedDelegate];
    RunLoopContext *context = [[RunLoopContext alloc] initWithSource:source andLoop:rl];
    
    [del performSelectorOnMainThread:@selector(removeSource:) withObject:context waitUntilDone:YES];
}


/////////////////////////////////////////////////////////////////////////
//              -  RunLoopContext
/////////////////////////////////////////////////////////////////////////
@implementation RunLoopContext

-(id)initWithSource:(RunLoopSource *)src andLoop:(CFRunLoopRef)loop {
    self = [super init];
    if (self) {
        runloop = loop;
        source = src;
    }
    return self;
}

-(CFRunLoopRef)runloop {
    return runloop;
}

-(RunLoopSource *)source {
    return source;
}
@end
