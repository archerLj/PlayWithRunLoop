//
//  RunLoopSource.h
//  RunLoop
//
//  Created by ArcherLj on 2019/7/9.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////
//              -  commands 类别
/////////////////////////////////////////////////////////////////////////
// 下载图片
static NSInteger sCommandDownLoadPics = 10001;
// 压缩图片
static NSInteger sCommandZipPic = 10002;

/////////////////////////////////////////////////////////////////////////
//              -  RunLoopSource和command buffer的包装类
/////////////////////////////////////////////////////////////////////////
// 包装RunLoopSource和command buffer
@interface RunLoopSource : NSObject {
    CFRunLoopSourceRef runloopSource;
    NSMutableArray *commands; // commad buffer用来从其他线程接受数据
}

-(id)init;
-(void)addToRunLoop:(NSRunLoop *)runloop;
-(void)invalidate;

// Handle method
-(void)sourceFired;

// 给公共command buffer赋值
-(void)addCommand:(NSInteger)command withData:(id)data;
// 在某个runloop上去执行所有的commands
-(void)fireCommandsOnRunLoop:(CFRunLoopRef)runloop;
@end


/////////////////////////////////////////////////////////////////////////
//                -  input source 回调函数
/////////////////////////////////////////////////////////////////////////
// 1. 当runloop sources 被添加到runloop时回调
void RunLoopSourceScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);
// 2.当input source接收到信号时候的回调，这这里处理input source接收到信号后的处理。
void RunLoopSourcePerformRoutine(void *info);
// 3.使用CFRunLoopSourceInvalidate将input source从runloop移除后的回调
void RunLoopSourceCancelRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);


/////////////////////////////////////////////////////////////////////////
//                 - RunLoopContext只是一个包装类，用来把runloop 和 sourc传递到外部使用者
/////////////////////////////////////////////////////////////////////////

@interface RunLoopContext : NSObject {
    CFRunLoopRef runloop;
    RunLoopSource *source;
}

@property(readonly) CFRunLoopRef runloop;
@property(readonly) RunLoopSource *source;

-(id)initWithSource:(RunLoopSource *)src andLoop:(CFRunLoopRef)loop;

@end
