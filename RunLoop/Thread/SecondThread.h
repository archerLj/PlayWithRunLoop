//
//  SecondThread.h
//  RunLoop
//
//  Created by ArcherLj on 2019/7/9.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SecondThread : NSThread
-(NSRunLoop *)runloop;
@end

NS_ASSUME_NONNULL_END
