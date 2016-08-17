//
//  UIViewController+PullBack.swift
//  PullBackSwift
//
//  Created by ___liangdahong on 16/8/17.
//  Copyright © 2016年 梁大红. All rights reserved.
//  https://github.com/asiosldh/PullBack

/// false: 关闭 true: 打开

let kopenPullBack = true
import UIKit

extension UIViewController {
    public override class func initialize() {

        struct Static {
            static var token: dispatch_once_t = 0
        }
        if self !== UIViewController.self {
            return
        }
        dispatch_once(&Static.token) {
            if kopenPullBack {
                print("dispatch_once")
                let m1 = class_getInstanceMethod(self, #selector(viewDidLoad))
                let m2 = class_getInstanceMethod(self, #selector(bm_viewDidLoad))
                method_exchangeImplementations(m1, m2)
            }
        }
    }

    func bm_viewDidLoad() -> () {
        if self.isKindOfClass(UINavigationController) {
            let tempGes = (self as! UINavigationController).interactivePopGestureRecognizer
            tempGes?.enabled = false
            let arr = tempGes?.valueForKey("_targets")
            let tar = arr?.firstObject
            let _targets = tar!!.valueForKey("target");
            let sel = NSSelectorFromString("handleNavigationTransition:")
            let pan = UIPanGestureRecognizer.init(target: _targets!, action: sel)
            tempGes!.view?.addGestureRecognizer(pan)
        }
    }
}
