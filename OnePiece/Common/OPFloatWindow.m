//
//  OPFloatWindow.m
//  OnePiece
//
//  Created by Duanww on 2018/8/9.
//  Copyright © 2018年 Duanww. All rights reserved.
//

#import "OPFloatWindow.h"

#define kVerticalMargin 15
#define kHorizenMargin 5

@implementation OPFloatWindow

- (instancetype)initWithFrame:(CGRect)frame contentView:(UIView *)contentView {
    if (self = [super initWithFrame:frame]) {
        [self setupWithContentView:contentView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupWithContentView:nil];
    }
    return self;
}

- (void)setupWithContentView:(UIView *)contentView {
    self.windowLevel = UIWindowLevelAlert + 1;
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    
    if (contentView) {
        [self addSubview:contentView];
    }
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    panGesture.delaysTouchesBegan = YES;
    [self addGestureRecognizer:panGesture];
}

#pragma mark - public

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = NO;
    });
}

- (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.hidden = YES;
    });
}

#pragma mark - Action

- (void)panGestureAction:(UIPanGestureRecognizer*)p {
    id<UIApplicationDelegate> delegate = UIApplication.sharedApplication.delegate;
    CGPoint panPoint = [p locationInView:delegate.window];
    
    if(p.state == UIGestureRecognizerStateBegan) {
        self.alpha = 1;
    }else if(p.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(panPoint.x, panPoint.y);
    }else if(p.state == UIGestureRecognizerStateEnded || p.state == UIGestureRecognizerStateCancelled) {
        [self layoutAnimateWithPosition:panPoint];
    }
}

- (void)layoutAnimateWithPosition:(CGPoint)postion {
    CGFloat ballWidth = self.frame.size.width;
    CGFloat ballHeight = self.frame.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat left = fabs(postion.x);
    CGFloat right = fabs(screenWidth - left);
    
    CGFloat minSpace = MIN(left, right);
    CGPoint newCenter = CGPointZero;
    CGFloat targetY = 0;
    
    //校准位置，使浮动窗口内容不显示在屏幕外
    if (postion.y < kVerticalMargin + ballHeight / 2.0) {
        targetY = kVerticalMargin + ballHeight / 2.0;
    } else if (postion.y > (screenHeight - ballHeight / 2.0 - kVerticalMargin)) {
        targetY = screenHeight - ballHeight / 2.0 - kVerticalMargin;
    } else{
        targetY = postion.y;
    }
    
    CGFloat centerXSpace = kHorizenMargin + ballWidth / 2.0;
    if (minSpace == left) {
        newCenter = CGPointMake(centerXSpace, targetY);
    } else if (minSpace == right) {
        newCenter = CGPointMake(screenWidth - centerXSpace, targetY);
    }
    
    [UIView animateWithDuration:.25 animations:^{
        self.center = newCenter;
    }];
}

@end
