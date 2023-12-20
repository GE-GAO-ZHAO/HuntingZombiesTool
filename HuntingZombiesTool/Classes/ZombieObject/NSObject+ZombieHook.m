//
//  NSObject+ZombieHook.h
//
//  Created by gegaozhao on 2020/9/3.
//

#import "NSObject+ZombieHook.h"
#import <objc/runtime.h>
#include <mach/mach.h>
#import "pthread.h"

#import "ZombieProxy.h"

void swizzleInstanceMethod(Class cls, SEL originSelector, SEL swizzleSelector)
{
    if (!cls) {
        return;
    }
    Method originalMethod = class_getInstanceMethod(cls, originSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzleSelector);
    
    if (class_addMethod(cls,
                        originSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        class_replaceMethod(cls,
                            swizzleSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        class_replaceMethod(cls,
                            swizzleSelector,
                            class_replaceMethod(cls,
                                                originSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
}

typedef struct ZombieObj {
    void *p;                //  Pointer to a zombie object
    Class originalClass;    //  Zombie object The original object
    NSTimeInterval addTime; //  Add Time
}ZombieObjData;

//Single-linked list manages zombie objects
typedef struct UnfreeZombie {
    ZombieObjData *data;
    struct UnfreeZombie *next;
}ZombieNode;


ZombieNode *_header; // Head node
pthread_mutex_t _nodeMutex; // Manages locks for zombie objects
static NSInteger _zombieObjCnt = 0; // Total number of zombie objects
static CFMutableSetRef _zombieClasses = nil; //Range of detection
static NSTimeInterval _zombieActivityTime = 0; // How long zombie objects live
static BOOL _zombieOpen = NO;//Enable or not

ZombieNode* creatList(void)
{
    ZombieNode *header = (ZombieNode *)malloc(sizeof(ZombieNode));
    header->data = NULL;
    header->next = NULL;
    return header;
}

void addZombieObj(void *p, Class class)
{
    pthread_mutex_lock(&_nodeMutex);
    if (!_header || !p) {
        pthread_mutex_unlock(&_nodeMutex);
        return;
    }
    ZombieNode *header = _header;
    
    ZombieObjData *data = (ZombieObjData *)malloc(sizeof(ZombieObjData));
    data->p = p;
    data->originalClass = class;
    data->addTime = [NSProcessInfo.processInfo systemUptime];
    
    ZombieNode *addNode = (ZombieNode *)malloc(sizeof(ZombieNode));
    addNode->data = data;
    addNode->next = header->next;
    header->next = addNode;
    _zombieObjCnt++;
    pthread_mutex_unlock(&_nodeMutex);
}

void clearZombieObjOfLive(void)
{
    pthread_mutex_lock(&_nodeMutex);
    if (!_header || _header->next==NULL) {
        pthread_mutex_unlock(&_nodeMutex);
        return;
    }
    ZombieNode *lastNode = _header;
    ZombieNode *currentNode = _header;
    while (currentNode->next != NULL) {
        currentNode = currentNode->next;
        ZombieObjData *data = currentNode->data;
        NSTimeInterval currentT = [NSProcessInfo.processInfo systemUptime];
        NSTimeInterval differenceTime = currentT - data->addTime;
        //How long zombie objects live
        if (differenceTime > _zombieActivityTime) {
            ZombieNode *deleteNode = currentNode;
            lastNode->next = deleteNode->next;
            currentNode = lastNode;
            free(data->p);
            free(data);
            free(deleteNode);
            _zombieObjCnt--;
        } else {
            lastNode = currentNode;
        }
    }
    pthread_mutex_unlock(&_nodeMutex);
}

void clearAllZombieObjs(void)
{
    pthread_mutex_lock(&_nodeMutex);
    if (_zombieObjCnt <= 1) {
        pthread_mutex_unlock(&_nodeMutex);
        return;
    }

    NSInteger liveNumber = 0;
    ZombieNode *lastNode = _header;
    ZombieNode *currentNode = _header;
    NSInteger i = 1;
    while (currentNode->next != NULL) {
        currentNode = currentNode->next;
        if (i > liveNumber) {
            ZombieObjData *data = currentNode->data;
            ZombieNode *deleteNode = currentNode;
            lastNode->next = deleteNode->next;
            currentNode = lastNode;
            free(data->p);
            free(data);
            free(deleteNode);
            _zombieObjCnt--;
        } else {
            lastNode = currentNode;
        }
        i++;
    }
    pthread_mutex_unlock(&_nodeMutex);
}

@implementation NSObject (ZombieHook)

#pragma mark - piblic

+ (void)startZombieWithClasses:(NSArray *)classes withActivityTime:(NSTimeInterval)activityTime {
    //Prevent multiple calls
    if (_zombieOpen){
        return;
    }
    _zombieOpen = YES;
    
    _zombieClasses = CFSetCreateMutable(NULL, 0, NULL);
    if (classes.count == 0) {
        //Copy all the classes
        unsigned int count = 0;
        Class *classSet = objc_copyClassList(&count);
        for (int i = 0; i < count; i++) {
            CFSetAddValue(_zombieClasses, (__bridge const void *)(classSet[i]));
        }
        free(classSet);
        classSet = NULL;
    } else {
        //Copy the incoming class
        for (int i = 0; i < classes.count; i++) {
            CFSetAddValue(_zombieClasses, (__bridge const void *)(classes[i]));
        }
    }
    //Setting the live Time
    if (activityTime <= 0){
        activityTime = 30;
    }
    _zombieActivityTime = activityTime;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self swizzleZombie];
    });
}

+ (void)stopZombie {
    //Prevent multiple calls to stop
    if (!_zombieOpen) {
        return;
    }
    _zombieOpen = NO;
    
    pthread_mutex_lock(&_nodeMutex);
    CFSetRemoveAllValues(_zombieClasses);
    _zombieClasses = NULL;
    pthread_mutex_unlock(&_nodeMutex);
}

+ (void)swizzleZombie {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_nodeMutex, NULL);
        _header = creatList();
        _zombieObjCnt = 0;
        [self swizzleInstanceMethod:@selector(dealloc) withSwizzleMethod:@selector(zombie_dealloc)];
    });
}

- (void)swizzleInstanceMethod:(SEL)originSelector withSwizzleMethod:(SEL)swizzleSelector {
    swizzleInstanceMethod(self.class, originSelector, swizzleSelector);
}

- (void)zombie_dealloc {
    //The original dealloc logic was not enabled
    if (!_zombieOpen) {
        [self zombie_dealloc];
        return;
    }
    Class currentClass = self.class;
//    NSLog(@"类名: %@", NSStringFromClass(currentClass));
    //The original dealloc logic is not in the detected range
    if (!CFSetContainsValue(_zombieClasses, currentClass)) {
        [self zombie_dealloc];
        return;
    }
    objc_destructInstance(self);
    object_setClass(self, [ZombieProxy class]);
    ZombieProxy *obj = (ZombieProxy *)self;
    obj.originClass = currentClass;
    addZombieObj((void *)obj, currentClass);
}

@end
