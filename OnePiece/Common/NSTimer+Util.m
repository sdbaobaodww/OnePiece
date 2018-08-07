//
//  NSTimer+Util.m
//  OnePiece
//
//  Created by Duanwwu on 2016/12/15.
//  Copyright © 2016年 DZH. All rights reserved.
//

#import "NSTimer+Util.h"

@implementation NSTimer (Util)

/**
 * 暂停
 */
- (void)util_suspend
{
    [self setFireDate:[NSDate distantFuture]];
}

/**
 * 唤醒
 */
- (void)util_resume
{
    [self setFireDate:[NSDate distantPast]];
}

/**
 * 手动延迟一个周期触发
 */
- (void)util_nextFire
{
    [self setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.timeInterval]];
}

@end
