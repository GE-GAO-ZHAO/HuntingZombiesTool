//
//  ZombieConfig.h
//
//  Created by gegozhao on 2020/9/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HDThrowInfoBlock)(NSString *info);

@interface ZombieConfig : NSObject


// Activity time, default 30 seconds
@property (nonatomic, assign) NSTimeInterval zombieActivityTime;
// Detection range, If it is empty, it defaults to all
@property (nonatomic, copy) NSArray *classes;
// Exception callback method
@property (nonatomic, copy) HDThrowInfoBlock throwInfo;

+ (instancetype)share;

+ (void)destroyInstance;

- (void)startZombie;

- (void)stopZombie;

@end

NS_ASSUME_NONNULL_END
