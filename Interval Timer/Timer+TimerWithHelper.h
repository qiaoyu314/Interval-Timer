//
//  Timer+TimerWithHelper.h
//  Interval Timer
//
//  Created by Yu Qiao on 1/11/14.
//  Copyright (c) 2014 Yu Qiao. All rights reserved.
//

#import "Timer.h"

@interface Timer (TimerWithHelper)

//these methods are designed to help to set time picker
-(NSNumber *)getTotal;
+(NSNumber *)getHours: (NSNumber *)length;
+(NSNumber *)getMinutes: (NSNumber *)length;
+(NSNumber *)getSeconds: (NSNumber *)length;
+(NSString *)getLengthInString: (NSNumber *)length;

typedef enum{
    TIMER_WARM_UP,
    TIMER_ROUND,
    TIMER_REST,
    TIMER_COOL_DOWN,
    TIMER_END
}timerState;
@end
