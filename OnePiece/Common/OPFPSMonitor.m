//
//  OPFPSMonitor.m
//  OnePiece
//
//  Created by Duanww on 2018/8/9.
//  Copyright © 2018年 Duanww. All rights reserved.
//

#import "OPFPSMonitor.h"

@interface OPFPSMonitor ()

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSTimeInterval lastTime;
@property (nonatomic, strong) CADisplayLink * displayLink;
@property (nonatomic, copy) void(^fpsBlock)(NSInteger fps);

@end

@implementation OPFPSMonitor

- (void)startFPSMonitorWithBlock:(void(^)(NSInteger fps))block {
    self.fpsBlock = block;
    if (self.displayLink) {
        return;
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector: @selector(monitor:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    
    if (@available(iOS 10.0, *)) {
        self.displayLink.preferredFramesPerSecond = 60;
    } else {
        self.displayLink.frameInterval = 1;
    }
    
    self.lastTime = self.displayLink.timestamp;
}

- (void)stopFPSMonitor {
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        self.fpsBlock = nil;
    }
}

#pragma mark - DisplayLink

- (void)monitor: (CADisplayLink *)link {
    _count ++;
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) {
        return;
    }
    _lastTime = link.timestamp;
    NSInteger fps =(NSInteger)round(_count / delta);
    _count = 0;
    
    if(self.fpsBlock){
        self.fpsBlock(fps);
    }
}

@end
