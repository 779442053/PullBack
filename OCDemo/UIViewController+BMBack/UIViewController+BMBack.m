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

#if kopenPullBack
@implementation UINavigationController (BMBack)

+ (void)load {
    Method m1 = class_getInstanceMethod([self class], @selector(viewDidLoad));
    Method m2 = class_getInstanceMethod([self class], @selector(bm_viewDidLoad));
    
    BOOL sel = class_addMethod(self, @selector(viewDidLoad), method_getImplementation(m2), method_getTypeEncoding(m2));
    
    if (!sel) {
        // 添加成功 说明本类已经实现了方法 交换即可
        method_exchangeImplementations(m1, m2);
    }else{
        // 添加成功 就替换掉方法
        class_replaceMethod(self, @selector(bm_viewDidLoad), method_getImplementation(m1), method_getTypeEncoding(m2));
    }
}

- (void)bm_viewDidLoad {
    [self bm_viewDidLoad];
    
    // 获取手势
    UIGestureRecognizer *tempGes = self.interactivePopGestureRecognizer;
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
@end
#endif

