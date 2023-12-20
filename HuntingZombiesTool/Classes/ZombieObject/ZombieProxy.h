//
//  ZombieProxy.h
//
//  Created by gegaozhao on 2020/9/3.
//

#import <Foundation/Foundation.h>

@interface ZombieProxy : NSProxy

@property (nonatomic, assign) Class originClass;

@end
