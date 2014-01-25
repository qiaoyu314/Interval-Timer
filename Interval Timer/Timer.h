//
//  Timer.h
//  Interval Timer
//
//  Created by Yu Qiao on 1/11/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Timer : NSManagedObject

@property (nonatomic, retain) NSNumber * warmUpLength;
@property (nonatomic, retain) NSNumber * roundLength;
@property (nonatomic, retain) NSNumber * restLength;
@property (nonatomic, retain) NSNumber * cycle;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * creationTime;
@property (nonatomic, retain) NSNumber * cooldownLength;

@end
