//
//  YQNavigationController.m
//  Interval Timer
//
//  Created by Yu Qiao on 1/16/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

#import "YQNavigationController.h"

@interface YQNavigationController ()

@end

@implementation YQNavigationController

#pragma mark - orientation

//disable other orientation. This has to be in the root view controller.
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
