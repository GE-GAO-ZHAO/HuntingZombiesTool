//
//  GZAppDelegate.m
//  HuntingZombiesTool
//
//  Created by 葛高召 on 12/20/2023.
//  Copyright (c) 2023 葛高召. All rights reserved.
//

#import "GZAppDelegate.h"
#import <HuntingZombiesTool/ZombieConfig.h>
#import <objc/runtime.h>
#import <mach-o/ldsyms.h>
#import <dlfcn.h>

@implementation GZAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    //当检测到野指针后的回调，由业务自行处理。可选择上报错误，也可以直接crash
    ZombieConfig.share.throwInfo = ^(NSString * _Nonnull info) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:info userInfo:nil];
    };
    
    //司机侧示例代码
    ZombieConfig.share.throwInfo = ^(NSString * _Nonnull info) {
        NSLog(info);
        //可以上报到自己分析平台
    };
    ZombieConfig.share.zombieActivityTime = 30;
    ZombieConfig.share.classes = [self ownClassesInfo];//如果这里传空，默认是扫描所有类
    [ZombieConfig.share startZombie];
    
    return YES;
}

//获取本项目非系统库的类
- (NSArray <Class>*)ownClassesInfo {
    NSMutableArray *resultArray = [NSMutableArray array];
    unsigned int classCount;
    const char **classes;
    Dl_info info;
    dladdr(&_mh_execute_header, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname, &classCount);

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(classCount, dispatch_get_global_queue(0, 0), ^(size_t iteration) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSString *className = [NSString stringWithCString:classes[iteration] encoding:NSUTF8StringEncoding];
        Class class = NSClassFromString(className);
        [resultArray addObject:class];
        dispatch_semaphore_signal(semaphore);
    });
    return resultArray.mutableCopy;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
