//
//  NSObject+ZombieHook.h
//
//  Created by gegaozhao on 2020/9/3.
//

#import <Foundation/Foundation.h>

void clearZombieObjOfLive(void);

void clearAllZombieObjs(void);

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZombieHook)

// Enabling Detection
// @param classes       Detection range, default all
// @param activityTime  Activity time, default 30 seconds
+ (void)startZombieWithClasses:(NSArray *)classes withActivityTime:(NSTimeInterval)activityTime;

+ (void)stopZombie;

@end

NS_ASSUME_NONNULL_END
