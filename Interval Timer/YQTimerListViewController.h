//
//  YQTimerListViewController.h
//  Interval Timer
//
//  Created by Yu Qiao on 12/22/13.
//  Copyright (c) 2013 Yu Qiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface YQTimerListViewController : UITableViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
