//
//  AppDelegate.h
//  RunLoop
//
//  Created by ArcherLj on 2019/7/9.
//  Copyright © 2019 ArcherLj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RunLoopSource.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(instancetype)sharedDelegate;
-(void)registerSource:(RunLoopContext *)context;
-(void)removeSource:(RunLoopContext *)context;
@end

