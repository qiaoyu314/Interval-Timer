//
//  YQEditTimerViewController.h
//  Interval Timer
//
//  Created by Yu Qiao on 12/25/13.
//  Copyright (c) 2013 Yu Qiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timer+TimerWithHelper.h"

@interface YQEditTimerViewController : UITableViewController<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>

@property  Timer *timer;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
