
//
//  ZombieProxy.m
//
//  Created by gegaozhao on 2020/9/3.
//


#include <objc/runtime.h>
#import "ZombieProxy.h"

@implementation ZombieProxy

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.originClass instancesRespondToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.originClass instanceMethodSignatureForSelector:sel];
}

- (void)forwardInvocation: (NSInvocation *)invocation {
    [self sentExceptionWithSelector: invocation.selector];
}

- (Class)class {
    [self sentExceptionWithSelector: _cmd];
    return nil;
}
- (BOOL)isEqual:(id)object {
    [self sentExceptionWithSelector: _cmd];
    return NO;
}
- (NSUInteger)hash {
    [self sentExceptionWithSelector: _cmd];
    return 0;
}
- (id)self {
    [self sentExceptionWithSelector: _cmd];
    return nil;
}
- (BOOL)isKindOfClass:(Class)aClass {
    [self sentExceptionWithSelector: _cmd];
    return NO;
}
- (BOOL)isMemberOfClass:(Class)aClass {
    [self sentExceptionWithSelector: _cmd];
    return NO;
}
- (BOOL)conformsToProtocol:(Protocol *)aProtocol {
    [self sentExceptionWithSelector: _cmd];
    return NO;
}
- (BOOL)isProxy {
    [self sentExceptionWithSelector: _cmd];
    return NO;
}

- (NSString *)description {
    [self sentExceptionWithSelector: _cmd];
    return nil;
}

#pragma mark - MRC
- (instancetype)retain {
    [self sentExceptionWithSelector: _cmd];
    return  nil;
}

- (oneway void)release {
    [self sentExceptionWithSelector: _cmd];
}

- (void)dealloc {
    [self sentExceptionWithSelector: _cmd];
    [super dealloc];
}

- (NSUInteger)retainCount {
    [self sentExceptionWithSelector: _cmd];
    return 0;
}

- (struct _NSZone *)zone {
    [self sentExceptionWithSelector: _cmd];
    return  nil;
}

#pragma mark - private
- (void)sentExceptionWithSelector:(SEL)selector {
    NSArray *zombieStack = [NSThread callStackSymbols];
  
    NSString *zombieInfo = [NSString stringWithFormat:@"zombieCheck:(-[%@ %@]) was sent to a zombie object at address: %p\nzombieStack:%@", NSStringFromClass(self.originClass),NSStringFromSelector(selector), self,zombieStack];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ZombieThrowInfo" object:@{@"zombieInfo":zombieInfo}];
}

@end
