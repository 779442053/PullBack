//
//  UIViewController+BMBack.m
//
//  Created by ___liangdahong on 16/8/16.
//  Copyright © 2016年 梁大红. All rights reserved.
//  https://github.com/asiosldh/PullBack

// NO: 关闭 YES: 打开
#define kopenPullBack YES

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation UIViewController (BMBack)

+ (void)load {
    if (kopenPullBack) {
        Method m1 = class_getInstanceMethod([self class], @selector(viewDidLoad));
        Method m2 = class_getInstanceMethod([self class], @selector(bm_viewDidLoad));
        method_exchangeImplementations(m1, m2);
    }
}

- (void)bm_viewDidLoad {
    [self bm_viewDidLoad];
    if ([self isKindOfClass:[UINavigationController class]]) {
        // 获取手势
        UIGestureRecognizer *tempGes = ((UINavigationController *)self).interactivePopGestureRecognizer;
        // 关闭此手势
        tempGes.enabled = NO;
        // 获取手势的回调数组
        NSMutableArray *muarray = [tempGes valueForKey:@"_targets"];
        
        // 获取系统的侧滑手势的回调对象和方法
        id tar = [[muarray firstObject] valueForKey:@"target"];
        SEL sel = NSSelectorFromString(@"handleNavigationTransition:");
        // 创建一个手势 添加上去
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:tar action:sel];
        [tempGes.view addGestureRecognizer:pan];
    }
}
@end
