//
//  ZombieConfig.h
//
//  Created by gegaozhao on 2020/9/3.
//

#import "ZombieConfig.h"
#import "NSObject+ZombieHook.h"

@interface ZombieConfig ()

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation ZombieConfig

static dispatch_once_t onceToken;
static ZombieConfig *share;

+ (instancetype)share {
    dispatch_once(&onceToken, ^{
        share = [[ZombieConfig alloc] init];
    });
    return share;
}

+ (void)destroyInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        onceToken = 0;
        share = nil;
    });
}

- (void)dealloc {
    NSLog(@"===ZombieConfig dealloc===");
}

#pragma mark - pulic api
- (void)startZombie {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(throwInfo:) name:@"ZombieThrowInfo" object:nil];
    
    [NSObject startZombieWithClasses:self.classes withActivityTime:self.zombieActivityTime];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW,0);

    if (!self.timer) {
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 5.0 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(self.timer, ^{
            [self clearZombie];
        });
        dispatch_resume(self.timer);
    }
}

- (void)stopZombie {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self invalidate];
    [NSObject stopZombie];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        clearAllZombieObjs();
    });
}

- (void)invalidate {
    if (self.timer) {
        dispatch_source_cancel(self.timer);
    }
}

#pragma mark - privicy Memory Manager
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        clearAllZombieObjs();
    });
}

// Periodically clear zombie objects
- (void)clearZombie {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        clearZombieObjOfLive();
    });
}

- (void)throwInfo:(NSNotification *)obj {
    NSDictionary *dict = obj.object;
    NSString *info = [dict objectForKey:@"zombieInfo"];
    
    if (self.throwInfo && info.length > 0) {
        self.throwInfo(info);
    }
}

@end
